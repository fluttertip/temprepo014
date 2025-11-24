import 'package:flutter/foundation.dart';
import '../domain/user.dart';
import '../domain/auth_repository.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthProvider(this._authRepository) {
    _listenToAuthChanges();
    _initializeAuth();
  }

  AuthState _state = AuthState.initial;
  User? _user;
  String? _errorMessage;

  AuthState get state => _state;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  void _listenToAuthChanges() {
    _authRepository.authStateChanges.listen(
  (User? user) {
    print('Auth state changed: ${user?.email ?? 'null'}');
    _user = user;
    _state = user != null ? AuthState.authenticated : AuthState.unauthenticated;
    _errorMessage = null; // clear previous error
    notifyListeners();
  },
  onError: (error) {
    print('Auth state change error: $error');
    _setState(AuthState.error, 'Authentication error: $error');
  },
);

    // _authRepository.authStateChanges.listen(
    //   (User? user) {
    //     print('Auth state changed: ${user?.email ?? 'null'}');
    //     _user = user;
    //     if (_state == AuthState.loading) {
    //       _state = user != null
    //           ? AuthState.authenticated
    //           : AuthState.unauthenticated;
    //       _errorMessage = null;
    //       notifyListeners();
    //     }
    //   },
    //   onError: (error) {
    //     print('Auth state change error: $error');
    //     if (_state == AuthState.loading) {
    //       _setState(AuthState.error, 'Authentication error: $error');
    //     }
    //   },
    // );
  }

  Future<void> _initializeAuth() async {
    final result = await _authRepository.getCurrentUser();
    result.fold(
      (failure) => _setState(AuthState.error, failure.message),
      (user) => _setState(
        user != null ? AuthState.authenticated : AuthState.unauthenticated,
        null,
        user,
      ),
    );
  }

  Future<void> signInWithGoogle() async {
    print('Starting Google Sign-In...');
    _setState(AuthState.loading, null);

    try {
      final result = await _authRepository.signInWithGoogle();
      result.fold(
  (failure) => _setState(AuthState.error, failure.message),
  (user) => _setState(AuthState.authenticated, null, user),
);

      // result.fold(
      //   (failure) {
      //     print('Sign-in failed: ${failure.message}');
      //     _setState(AuthState.error, failure.message);
      //   },
      //   (user) {
      //     print('Sign-in successful: ${user.email}');
      //     // Don't set state here, let authStateChanges handle it
      //     _errorMessage = null;
      //   },
      // );
    } catch (e) {
      print('Sign-in exception: $e');
      _setState(AuthState.error, 'Sign in failed: ${e.toString()}');
    }
  }

  Future<void> switchRole(String newRole) async {
    if (_user == null) return;

    _setState(AuthState.loading, null);

    final result = await _authRepository.updateUserRole(_user!.id, newRole);
    result.fold(
      (failure) => _setState(AuthState.error, failure.message),
      (updatedUser) => _setState(AuthState.authenticated, null, updatedUser),
    );
  }

  Future<void> checkAuthStatus() async {
    _setState(AuthState.loading, null);

    final result = await _authRepository.getCurrentUser();
    result.fold(
      (failure) => _setState(AuthState.error, failure.message),
      (user) => _setState(
        user != null ? AuthState.authenticated : AuthState.unauthenticated,
        null,
        user,
      ),
    );
  }

  Future<void> signOut() async {
    _setState(AuthState.loading, null);

    final result = await _authRepository.signOut();
    result.fold(
      (failure) => _setState(AuthState.error, failure.message),
      (_) => _setState(AuthState.unauthenticated, null, null),
    );
  }

  void _setState(AuthState newState, String? errorMessage, [User? user]) {
    _state = newState;
    _errorMessage = errorMessage;
    if (user != null) _user = user;
    notifyListeners();
  }

  void clearError() {
  _errorMessage = null;
  _state = _user != null ? AuthState.authenticated : AuthState.unauthenticated;
  notifyListeners();
}

}
