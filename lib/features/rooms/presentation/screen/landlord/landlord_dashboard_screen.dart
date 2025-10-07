import 'package:flutter/material.dart';
import 'package:mvproomrentandbook/core/constants/app_theme.dart';
import 'package:mvproomrentandbook/features/auth/presentation/auth_provider.dart';
import 'package:mvproomrentandbook/features/bookings/domain/booking.dart';
import 'package:mvproomrentandbook/features/bookings/presentation/provider/booking_provider.dart';
import 'package:mvproomrentandbook/features/rooms/presentation/provider/room_provider.dart';
import 'package:provider/provider.dart';

// Landlord screens
class LandlordDashboardScreen extends StatefulWidget {
  const LandlordDashboardScreen({super.key});

  @override
  State<LandlordDashboardScreen> createState() =>
      _LandlordDashboardScreenState();
}

class _LandlordDashboardScreenState extends State<LandlordDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<RoomProvider>().loadMyRooms(user.id);
        context.read<BookingProvider>().loadLandlordBookings(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<AuthProvider, RoomProvider, BookingProvider>(
      builder: (context, authProvider, roomProvider, bookingProvider, child) {
        final user = authProvider.user;
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Container(
          color: Colors.white,
          child: SingleChildScrollView(
            // padding: const EdgeInsets.all(AppSizes.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Card
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Colors.grey.withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.paddingL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back, ${user.displayName}!',
                          style: AppTextStyles.heading2,
                        ),
                        const SizedBox(height: AppSizes.paddingS),
                        Text(
                          'Manage your rental properties and bookings',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          
                const SizedBox(height: AppSizes.paddingM),
          
                // Statistics Row
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Total Rooms',
                        value: roomProvider.myRooms.length.toString(),
                        icon: Icons.home,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingM),
                    Expanded(
                      child: _StatCard(
                        title: 'Available',
                        value: roomProvider.myRooms
                            .where((room) => room.isAvailable)
                            .length
                            .toString(),
                        icon: Icons.check_circle,
                        color: AppColors.successColor,
                      ),
                    ),
                  ],
                ),
          
                const SizedBox(height: AppSizes.paddingM),
          
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Total Bookings',
                        value: bookingProvider.landlordBookings.length.toString(),
                        icon: Icons.book,
                        color: AppColors.infoColor,
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingM),
                    Expanded(
                      child: _StatCard(
                        title: 'Pending',
                        // value: bookingProvider
                        //     .getBookingsByStatus(AppConstants.pendingStatus, true)
                        //     .length
                        //     .toString(),
                        value: bookingProvider
                            .getBookingsByStatus(
                              BookingStatus.pending,
                              true,
                            ) // Changed from AppConstants.pendingStatus to BookingStatus.pending
                            .length
                            .toString(),
                        icon: Icons.pending,
                        color: AppColors.warningColor,
                      ),
                    ),
                  ],
                ),
          
                const SizedBox(height: AppSizes.paddingL),
          
                // Recent Bookings
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent Bookings', style: AppTextStyles.heading3),
                    TextButton(
                      onPressed: () {
                        // Navigate to bookings tab
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),
          
                const SizedBox(height: AppSizes.paddingS),
          
                if (bookingProvider.landlordBookings.isEmpty)
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Colors.grey.withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                    elevation: 1,
                    child: Padding(
                      padding: EdgeInsets.all(AppSizes.paddingL),
                      child: Center(child: Text('No bookings yet')),
                    ),
                  )
                else
                  ...bookingProvider.landlordBookings.take(3).map((booking) {
                    return Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Colors.grey.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                      elevation: 1,
                      margin: const EdgeInsets.symmetric(
                        vertical: AppSizes.paddingS,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryColor,
                          child: Text(
                            booking.tenantName[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(booking.roomTitle),
                        subtitle: Text(
                          '${booking.tenantName} • ${booking.status}',
                        ),
                        trailing: Text(
                          'NPR ${booking.totalAmount.toStringAsFixed(0)}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.15), width: 1),
      ),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color),
                Text(
                  value,
                  style: AppTextStyles.heading2.copyWith(color: color),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingS),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
