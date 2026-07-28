import 'dart:async';

import 'package:flutter/foundation.dart';

import '../domain/auth_repository.dart';
import '../domain/user.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

/// v2 cleanup: single source of truth from the auth stream (v1 had a race
/// where both the stream listener and `_initializeAuth` set state). No prints.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repo) {
    _sub = _repo.authStateChanges.listen(
      (user) => _apply(
        user != null ? AuthState.authenticated : AuthState.unauthenticated,
        user: user,
      ),
      onError: (Object e) => _apply(AuthState.error, error: e.toString()),
    );
  }

  final AuthRepository _repo;
  StreamSubscription<User?>? _sub;

  AuthState _state = AuthState.initial;
  User? _user;
  String? _errorMessage;

  AuthState get state => _state;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  Future<void> checkAuthStatus() async {
    _apply(AuthState.loading);
    final result = await _repo.getCurrentUser();
    result.fold(
      (f) => _apply(AuthState.unauthenticated),
      (user) => _apply(
        user != null ? AuthState.authenticated : AuthState.unauthenticated,
        user: user,
        clearUser: user == null,
      ),
    );
  }

  Future<void> signInWithGoogle() async {
    _apply(AuthState.loading);
    final result = await _repo.signInWithGoogle();
    result.fold(
      (f) => _apply(AuthState.error, error: f.message),
      (user) => _apply(AuthState.authenticated, user: user),
    );
  }

  Future<void> switchRole(String newRole) async {
    final current = _user;
    if (current == null || current.activeRole == newRole) return;
    // Optimistic update for an instant toggle; revert on failure.
    _apply(AuthState.authenticated, user: current.copyWith(activeRole: newRole));
    final result = await _repo.updateUserRole(current.id, newRole);
    result.fold(
      (f) => _apply(AuthState.authenticated, user: current, error: f.message),
      (updated) => _apply(AuthState.authenticated, user: updated),
    );
  }

  Future<void> signOut() async {
    _apply(AuthState.loading);
    final result = await _repo.signOut();
    result.fold(
      (f) => _apply(AuthState.error, error: f.message),
      (_) => _apply(AuthState.unauthenticated, clearUser: true),
    );
  }

  void clearError() {
    _errorMessage = null;
    _state = _user != null ? AuthState.authenticated : AuthState.unauthenticated;
    notifyListeners();
  }

  void _apply(
    AuthState state, {
    User? user,
    String? error,
    bool clearUser = false,
  }) {
    _state = state;
    _errorMessage = error;
    if (clearUser) {
      _user = null;
    } else if (user != null) {
      _user = user;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
