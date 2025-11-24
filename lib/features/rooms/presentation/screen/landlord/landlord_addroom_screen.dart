import 'package:flutter/material.dart';
import 'package:kothakhoj/core/constants/app_constants.dart';
import 'package:kothakhoj/core/constants/app_theme.dart';
import 'package:kothakhoj/features/auth/presentation/auth_provider.dart';
import 'package:kothakhoj/features/rooms/domain/room.dart';
import 'package:kothakhoj/features/rooms/presentation/provider/room_provider.dart';
import 'package:kothakhoj/shared/widgets/common_widgets.dart';
import 'package:provider/provider.dart';

class LandlordAddRoomScreen extends StatefulWidget {
  const LandlordAddRoomScreen({super.key});

  @override
  State<LandlordAddRoomScreen> createState() => _LandlordAddRoomScreenState();
}

class _LandlordAddRoomScreenState extends State<LandlordAddRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  String? _selectedLocation;
  String? _selectedType;
  final List<String> _selectedFeatures = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(color: Colors.white),
              child: const Text(
                'Add New Room',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: AppSizes.paddingM,
                  right: AppSizes.paddingM,
                  top: AppSizes.paddingXL,
                  bottom: AppSizes.paddingM,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        // decoration: const InputDecoration(
                        //   labelText: 'Room Title *',
                        //   hintText: 'e.g., Cozy Single Room in Thamel',
                        // ),
                        decoration: InputDecoration(
                          labelText: 'Room Title *',
                          hintText: 'e.g., Cozy Single Room in Thamel',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey.withOpacity(0.2),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey.withOpacity(0.2),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.05),
                        ),
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Title is required' : null,
                      ),

                      const SizedBox(height: AppSizes.paddingM),

                      // Location and Type (responsive)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 600) {
                            // Stack vertically on small screens
                            return Column(
                              children: [
                                DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: 'Location *',
                                    border: OutlineInputBorder(),
                                  ),
                                  initialValue: _selectedLocation,
                                  validator: (value) => value == null
                                      ? 'Location is required'
                                      : null,
                                  items: AppConstants.kathmanduLocations.map((
                                    location,
                                  ) {
                                    return DropdownMenuItem<String>(
                                      value: location,
                                      child: Text(location),
                                    );
                                  }).toList(),
                                  onChanged: (value) =>
                                      setState(() => _selectedLocation = value),
                                ),
                                const SizedBox(height: AppSizes.paddingM),
                                DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: 'Room Type *',
                                    border: OutlineInputBorder(),
                                  ),
                                  initialValue: _selectedType,
                                  validator: (value) =>
                                      value == null ? 'Type is required' : null,
                                  items: AppConstants.roomTypes.map((type) {
                                    return DropdownMenuItem<String>(
                                      value: type,
                                      child: Text(type),
                                    );
                                  }).toList(),
                                  onChanged: (value) =>
                                      setState(() => _selectedType = value),
                                ),
                              ],
                            );
                          } else {
                            // Row on wide screens
                            return Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(
                                      labelText: 'Location *',
                                      border: OutlineInputBorder(),
                                    ),
                                    initialValue: _selectedLocation,
                                    validator: (value) => value == null
                                        ? 'Location is required'
                                        : null,
                                    items: AppConstants.kathmanduLocations.map((
                                      location,
                                    ) {
                                      return DropdownMenuItem<String>(
                                        value: location,
                                        child: Text(location),
                                      );
                                    }).toList(),
                                    onChanged: (value) => setState(
                                      () => _selectedLocation = value,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSizes.paddingM),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(
                                      labelText: 'Room Type *',
                                      border: OutlineInputBorder(),
                                    ),
                                    initialValue: _selectedType,
                                    validator: (value) => value == null
                                        ? 'Type is required'
                                        : null,
                                    items: AppConstants.roomTypes.map((type) {
                                      return DropdownMenuItem<String>(
                                        value: type,
                                        child: Text(type),
                                      );
                                    }).toList(),
                                    onChanged: (value) =>
                                        setState(() => _selectedType = value),
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),

                      const SizedBox(height: AppSizes.paddingM),

                      // Address
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Full Address *',
                          hintText: 'e.g., Thamel, Ward No. 29, Kathmandu',
                        ),
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Address is required'
                            : null,
                        maxLines: 2,
                      ),

                      const SizedBox(height: AppSizes.paddingM),

                      // Price
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Monthly Rent (NPR) *',
                          hintText: 'e.g., 15000',
                          prefixText: 'NPR ',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Price is required';
                          }
                          if (double.tryParse(value!) == null) {
                            return 'Enter valid price';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: AppSizes.paddingM),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description *',
                          hintText: 'Describe your room...',
                          alignLabelWithHint: true,
                        ),
                        maxLines: 4,
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Description is required'
                            : null,
                      ),

                      const SizedBox(height: AppSizes.paddingM),

                      // Features
                      Text('Features', style: AppTextStyles.heading3),
                      const SizedBox(height: AppSizes.paddingS),
                      Wrap(
                        spacing: AppSizes.paddingS,
                        runSpacing: AppSizes.paddingS,
                        children: AppConstants.roomFeatures.map((feature) {
                          final isSelected = _selectedFeatures.contains(
                            feature,
                          );
                          return FilterChip(
                            label: Text(feature),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedFeatures.add(feature);
                                } else {
                                  _selectedFeatures.remove(feature);
                                }
                              });
                            },

                            // selectedColor: AppColors.primaryColor.withOpacity(
                            //   0.3,
                            // ),
                            // checkmarkColor: AppColors.primaryColor,
                            backgroundColor: Colors.white,
                            selectedColor: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1),
                            checkmarkColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            side: BorderSide(
                              color: isSelected
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.3)
                                  : Colors.grey.withOpacity(0.2),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: AppSizes.paddingXL),

                      // Add Room Button
                      Consumer2<AuthProvider, RoomProvider>(
                        builder: (context, authProvider, roomProvider, child) {
                          return SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              text: 'Add Room',
                              isLoading:
                                  roomProvider.state == RoomState.loading,
                              onPressed: () =>
                                  _addRoom(authProvider, roomProvider),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addRoom(
    AuthProvider authProvider,
    RoomProvider roomProvider,
  ) async {
    if (!_formKey.currentState!.validate()) return;

    final user = authProvider.user!;
    final now = DateTime.now();

    final room = Room(
      id: '', // Will be set by repository
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      type: _selectedType!,
      location: _selectedLocation!,
      address: _addressController.text.trim(),
      price: double.parse(_priceController.text),
      features: _selectedFeatures,
      imageUrls: [], // Skip images for MVP
      ownerId: user.id,
      ownerName: user.displayName,
      ownerPhone: user.phoneNumber,
      isAvailable: true,
      rating: null,
      reviewCount: 0,
      createdAt: now,
      updatedAt: now,
    );

    final success = await roomProvider.createRoom(room);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Room added successfully!'),
          backgroundColor: AppColors.successColor,
        ),
      );
      _clearForm();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(roomProvider.errorMessage ?? 'Failed to add room'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _addressController.clear();
    _priceController.clear();
    setState(() {
      _selectedLocation = null;
      _selectedType = null;
      _selectedFeatures.clear();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
