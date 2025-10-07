import 'package:flutter/material.dart';
import 'package:mvproomrentandbook/features/auth/presentation/auth_provider.dart';
import 'package:mvproomrentandbook/features/bookings/domain/booking.dart';
import 'package:mvproomrentandbook/features/bookings/presentation/provider/booking_provider.dart';
import 'package:provider/provider.dart';

class LandlordBookingManagementScreen extends StatefulWidget {
  const LandlordBookingManagementScreen({super.key});

  @override
  State<LandlordBookingManagementScreen> createState() =>
      _LandlordBookingManagementScreenState();
}

class _LandlordBookingManagementScreenState
    extends State<LandlordBookingManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBookings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadBookings() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bookingProvider = Provider.of<BookingProvider>(
      context,
      listen: false,
    );

    if (authProvider.user != null) {
      bookingProvider.loadLandlordBookings(authProvider.user!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Booking Requests',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).colorScheme.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Accepted'),
            Tab(text: 'Others'),
          ],
        ),
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bookingProvider, child) {
          if (bookingProvider.state == BookingState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (bookingProvider.state == BookingState.error) {
            return _buildErrorState();
          }

          final allBookings = bookingProvider.landlordBookings;

          if (allBookings.isEmpty) {
            return _buildEmptyState();
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildBookingList(allBookings),
              _buildBookingList(
                bookingProvider.getBookingsByStatus(
                  BookingStatus.pending,
                  true,
                ),
              ),
              _buildBookingList(
                bookingProvider.getBookingsByStatus(
                  BookingStatus.accepted,
                  true,
                ),
              ),
              _buildBookingList([
                ...bookingProvider.getBookingsByStatus(
                  BookingStatus.rejected,
                  true,
                ),
                ...bookingProvider.getBookingsByStatus(
                  BookingStatus.cancelled,
                  true,
                ),
              ]),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
            const SizedBox(height: 24),
            const Text(
              'Failed to Load Requests',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Something went wrong while loading booking requests',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadBookings,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            const Text(
              'No Booking Requests',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'When tenants book your rooms, their requests will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingList(List<Booking> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No bookings in this category',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadBookings(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return _buildBookingRequestCard(booking);
        },
      ),
    );
  }

  Widget _buildBookingRequestCard(Booking booking) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.15), // Add subtle border
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03), // Very light shadow
            offset: const Offset(0, 1),
            blurRadius: 6,
          ),
        ],
      ),
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   borderRadius: BorderRadius.circular(16),
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.black.withOpacity(0.05),
      //       offset: const Offset(0, 2),
      //       blurRadius: 10,
      //     ),
      //   ],
      // ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(
                0.03,
              ), // Very light background instead of primary color
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            // decoration: BoxDecoration(
            //   color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
            //   borderRadius: const BorderRadius.vertical(
            //     top: Radius.circular(16),
            //   ),
            // ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    booking.tenantName.isNotEmpty
                        ? booking.tenantName[0].toUpperCase()
                        : 'T',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.tenantName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tenant Request',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(booking.status),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Room info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?ixlib=rb-4.0.3',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.roomTitle,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  booking.roomLocation,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rs. ${booking.roomPrice.toStringAsFixed(0)}/month',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Request details
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Request Date',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                _formatDate(booking.createdAt),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          if (booking.tenantPhone != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Contact',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  booking.tenantPhone!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      if (booking.message != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Message from tenant:',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          booking.message!,
                          style: const TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                if (booking.responseDate != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getStatusColor(booking.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getStatusColor(booking.status).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getStatusIcon(booking.status),
                          color: _getStatusColor(booking.status),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'You responded on ${_formatDate(booking.responseDate!)}',
                          style: TextStyle(
                            color: _getStatusColor(booking.status),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Action buttons
                if (booking.status == BookingStatus.pending) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showDetailDialog(
                            booking,
                            BookingStatus.rejected,
                          ),
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text('Reject'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showDetailDialog(
                            booking,
                            BookingStatus.accepted,
                          ),
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Accept'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showBookingDetails(booking),
                      icon: const Icon(Icons.info_outline, size: 18),
                      label: const Text('View Details'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BookingStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor(status).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _getStatusColor(status),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            status.name.toUpperCase(),
            style: TextStyle(
              color: _getStatusColor(status),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.accepted:
        return Colors.green;
      case BookingStatus.rejected:
        return Colors.red;
      case BookingStatus.cancelled:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Icons.pending;
      case BookingStatus.accepted:
        return Icons.check_circle;
      case BookingStatus.rejected:
        return Icons.cancel;
      case BookingStatus.cancelled:
        return Icons.block;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  void _showDetailDialog(Booking booking, BookingStatus newStatus) {
    final isAccepting = newStatus == BookingStatus.accepted;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '${isAccepting ? 'Accept' : 'Reject'} Booking Request',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tenant info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          child: Text(
                            booking.tenantName[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.tenantName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (booking.tenantPhone != null)
                                Text(
                                  booking.tenantPhone!,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Room info
              Text(
                'Room: ${booking.roomTitle}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                'Location: ${booking.roomLocation}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              Text(
                'Rent: Rs. ${booking.roomPrice.toStringAsFixed(0)}/month',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 16),

              // Confirmation message
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isAccepting
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isAccepting
                        ? Colors.green.withOpacity(0.3)
                        : Colors.red.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  isAccepting
                      ? 'By accepting this request, you confirm that the room is available for rent and you agree to proceed with this tenant.'
                      : 'By rejecting this request, the tenant will be notified that their booking was not approved.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isAccepting ? Colors.green[700] : Colors.red[700],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _updateBookingStatus(booking, newStatus),
            style: ElevatedButton.styleFrom(
              backgroundColor: isAccepting ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(isAccepting ? 'Accept Request' : 'Reject Request'),
          ),
        ],
      ),
    );
  }

  void _showBookingDetails(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Booking Details',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Status', booking.status.name.toUpperCase()),
              _buildDetailRow('Tenant', booking.tenantName),
              if (booking.tenantPhone != null)
                _buildDetailRow('Phone', booking.tenantPhone!),
              _buildDetailRow('Room', booking.roomTitle),
              _buildDetailRow('Location', booking.roomLocation),
              _buildDetailRow(
                'Rent',
                'Rs. ${booking.roomPrice.toStringAsFixed(0)}/month',
              ),
              _buildDetailRow('Request Date', _formatDate(booking.createdAt)),
              if (booking.responseDate != null)
                _buildDetailRow(
                  'Response Date',
                  _formatDate(booking.responseDate!),
                ),
              if (booking.message != null) ...[
                const SizedBox(height: 8),
                const Text(
                  'Message:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  booking.message!,
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _updateBookingStatus(Booking booking, BookingStatus status) async {
    Navigator.pop(context);

    try {
      final success = await Provider.of<BookingProvider>(
        context,
        listen: false,
      ).updateBookingStatus(booking.id, status);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking ${status.name} successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to update booking status');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update booking: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
