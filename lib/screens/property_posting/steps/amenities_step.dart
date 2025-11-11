import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../models/property_form_data.dart';
import 'media_upload_step.dart';
import '../../../services/amenities_service.dart';

class AmenitiesStep extends StatefulWidget {
  @override
  _AmenitiesStepState createState() => _AmenitiesStepState();
}

class _AmenitiesStepState extends State<AmenitiesStep> {
  final AmenitiesService _amenitiesService = AmenitiesService();
  Map<String, List<Map<String, dynamic>>> _groupedAmenities = {};
  final Map<int, bool> _selectedById = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAmenities();
  }

  Widget _buildAmenityChip({required int id, required String name, required bool selected}) {
    return GestureDetector(
      onTap: () => _toggleAmenityById(id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1B5993) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF1B5993) : Colors.grey.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: selected ? Colors.white : const Color(0xFF1B5993),
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : const Color(0xFF1B5993),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadAmenities() async {
    final formData = context.read<PropertyFormData>();
    final propertyTypeId = formData.propertyTypeId;
    if (propertyTypeId == null) {
      setState(() {
        _loading = false;
        _error = 'Missing property type';
      });
      return;
    }

    try {
      final grouped = await _amenitiesService.fetchAmenitiesByPropertyType(
        propertyTypeId: propertyTypeId,
      );
      setState(() {
        _groupedAmenities = grouped;
        // initialize selection map
        for (final items in grouped.values) {
          for (final item in items) {
            final id = (item['id'] as num).toInt();
            _selectedById[id] = formData.amenities.contains(id.toString());
          }
        }
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  int get _selectedCount => _selectedById.values.where((v) => v).length;

  void _toggleAmenityById(int id) {
    setState(() {
      _selectedById[id] = !(_selectedById[id] ?? false);
    });
    final formData = context.read<PropertyFormData>();
    final selected = _selectedById.entries
        .where((e) => e.value)
        .map((e) => e.key.toString())
        .toList();
    formData.updateAmenities(selected);
  }

  void _selectAll() {
    setState(() {
      for (final items in _groupedAmenities.values) {
        for (final item in items) {
          final id = (item['id'] as num).toInt();
          _selectedById[id] = true;
        }
      }
    });
    final formData = context.read<PropertyFormData>();
    final allIds = _selectedById.keys.map((e) => e.toString()).toList();
    formData.updateAmenities(allIds);
  }

  void _clearAll() {
    setState(() {
      for (final id in _selectedById.keys) {
        _selectedById[id] = false;
      }
    });
    final formData = context.read<PropertyFormData>();
    formData.updateAmenities([]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF1B5993),
            size: 16,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                    color: const Color(0xFF1B5993),
                borderRadius: BorderRadius.circular(8.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.star,
                    color: Colors.white,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'AMENITIES SELECTION',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1B5993),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
          ],
        ),
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20.r),
            bottomRight: Radius.circular(20.r),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(2.0.h),
          child: Container(
            height: 2.0.h,
            decoration: BoxDecoration(
              color: const Color(0xFF1B5993),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.r),
                bottomRight: Radius.circular(20.r),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            
            // Process Indicator
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F4FD),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF20B2AA).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Color(0xFF20B2AA),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          '5',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Amenities Selection',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF20B2AA),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Main Question
            const Text(
              'Select Property Amenities',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1B5993),
                height: 1.2,
              ),
            ),
            
            const SizedBox(height: 8),
            
            const Text(
              'Choose all amenities available at your property.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF616161),
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Available Amenities Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with icon
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B5993).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.star,
                          color: Color(0xFF1B5993),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Available Amenities',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1B5993),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  const Text(
                    'Select all amenities available at your property',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF616161),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Pro Tip
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E8),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lightbulb_outline,
                          color: Color(0xFF4CAF50),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Pro Tip: Select all amenities that are currently available at your property to attract the right buyers',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Selection Status and Controls
                  Row(
                    children: [
                      Text(
                        '$_selectedCount selected',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1B5993),
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: _selectAll,
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Select All'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B5993),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: _clearAll,
                        icon: const Icon(Icons.clear, size: 16),
                        label: const Text('Clear All'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1B5993),
                          side: const BorderSide(color: Color(0xFF1B5993)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_error != null)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'Failed to load amenities: $_error',
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  else ...[
                    for (final entry in _groupedAmenities.entries) ...[
                      const SizedBox(height: 16),
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1B5993),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          for (final amenity in entry.value)
                            _buildAmenityChip(
                              id: (amenity['id'] as num).toInt(),
                              name: amenity['name'] as String,
                              selected: _selectedById[(amenity['id'] as num).toInt()] ?? false,
                            ),
                        ],
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      
      // Navigation Buttons
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(24.0.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1B5993),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: const Color(0xFF1B5993),
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              child: const Text('Back to Listing Details'),
            ),
            ElevatedButton.icon(
              onPressed: () => _nextStep(context),
              icon: const Icon(Icons.star, size: 16),
              label: Text('Create Listing ($_selectedCount amenities)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5993),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _nextStep(BuildContext context) {
    final formData = context.read<PropertyFormData>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: formData,
          child: MediaUploadStep(),
        ),
      ),
    );
  }
}
