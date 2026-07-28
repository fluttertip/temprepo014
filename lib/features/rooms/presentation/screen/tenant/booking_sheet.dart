import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/utils.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../auth/presentation/auth_provider.dart';
import '../../../../bookings/domain/booking.dart';
import '../../../../bookings/presentation/provider/booking_provider.dart';
import '../../../domain/room.dart';

/// Booking request sheet. v2: phone validation via ValidationUtils, keyboard
/// insets handled, a clear summary row, and single-tap submit with inline
/// loading. Prefills the tenant's saved phone number when available.
class BookingSheet extends StatefulWidget {
  const BookingSheet({super.key, required this.room});
  final Room room;

  @override
  State<BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<BookingSheet> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _message = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user?.phoneNumber != null) _phone.text = user!.phoneNumber!;
  }

  @override
  void dispose() {
    _phone.dispose();
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Request to book', style: context.text.titleLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(room.title,
                    style: context.text.bodyMedium
                        ?.copyWith(color: context.scheme.onSurfaceVariant)),
                const SizedBox(height: AppSpacing.xl),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Your phone number',
                    hintText: '98XXXXXXXX',
                    prefixIcon: Icon(Icons.phone_rounded),
                  ),
                  validator: ValidationUtils.validatePhone,
                ),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: _message,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Message (optional)',
                    hintText: 'Move-in date, questions…',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: context.scheme.primaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Monthly rent', style: context.text.titleSmall),
                      Text('Rs ${room.price.toStringAsFixed(0)}',
                          style: context.text.titleMedium
                              ?.copyWith(color: context.scheme.primary)),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: 'Send request',
                  isLoading: _submitting,
                  onPressed: _submit,
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final bookings = context.read<BookingProvider>();
    final user = auth.user;
    if (user == null) return;

    setState(() => _submitting = true);
    final now = DateTime.now();
    final booking = Booking(
      id: '',
      roomId: widget.room.id,
      tenantId: user.id,
      landlordId: widget.room.ownerId,
      roomTitle: widget.room.title,
      roomLocation: widget.room.location,
      roomPrice: widget.room.price,
      tenantName: user.displayName,
      tenantPhone: _phone.text.trim(),
      status: BookingStatus.pending,
      totalAmount: widget.room.price,
      message: _message.text.trim().isEmpty ? null : _message.text.trim(),
      createdAt: now,
      updatedAt: now,
    );

    final ok = await bookings.createBooking(booking);
    if (!mounted) return;
    setState(() => _submitting = false);
    Navigator.pop(context);
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? 'Booking request sent!'
            : bookings.errorMessage ?? 'Could not send request'),
      ),
    );
  }
}