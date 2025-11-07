import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/customer_properties_service.dart';
import '../models/customer_property.dart';
import '../core/theme/app_theme.dart';
import 'listing_detail_screen.dart';
import '../core/services/geocoding_service.dart';
import 'package:latlong2/latlong.dart';
import 'update_property_screen.dart';
import '../services/whatsapp_service.dart';
import '../services/call_service.dart';
import 'ownership_selection_screen.dart';
import 'property_listings_screen.dart';
import 'main_wrapper.dart';
import '../ui/widgets/app_icons.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  final CustomerPropertiesService _service = CustomerPropertiesService();
  final GeocodingService _geocodingService = GeocodingService();
  List<CustomerProperty> _properties = [];
  List<CustomerProperty> _filteredProperties = [];
  bool _isLoading = true;
  String? _error;
  final Map<String, String?> _geocodedAddresses = {}; // Cache geocoded addresses
  
  // Filter options
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Pending', 'Approved', 'Rejected'];

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _geocodeProperty(CustomerProperty property) async {
    if (property.latitude == null || property.longitude == null) return;
    
    final cacheKey = '${property.latitude},${property.longitude}';
    if (_geocodedAddresses.containsKey(cacheKey)) return;
    
    try {
      final address = await _geocodingService.reverseGeocode(
        LatLng(property.latitude!, property.longitude!),
      );
      if (mounted) {
        setState(() {
          _geocodedAddresses[cacheKey] = address;
        });
      }
    } catch (e) {
      print('Geocoding error for property ${property.id}: $e');
    }
  }

  void _navigateToUpdateProperty(CustomerProperty property) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdatePropertyScreen(property: property),
      ),
    ).then((_) {
      // Refresh properties after update
      _loadProperties();
    });
  }

  void _navigateToPropertyDetails(CustomerProperty property) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListingDetailScreen(property: property),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(CustomerProperty property) async {
    // First confirmation dialog
    final firstConfirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            'Delete Property',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Colors.red,
            ),
          ),
          content: Text(
            'Do you want to delete this property? This action cannot be undone.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14.sp,
              color: Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'No',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Yes',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (firstConfirm == true) {
      // Second confirmation dialog (like GitHub)
      await _showGitHubStyleDeleteDialog(property);
    }
  }

  Future<void> _showGitHubStyleDeleteDialog(CustomerProperty property) async {
    final TextEditingController textController = TextEditingController();
    final String requiredText = 'delete my property';
    bool isTextMatched = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              title: Row(
                children: [
                  Icon(AppIcons.warningAmberRounded, color: Colors.red, size: 24.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Delete Property',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This action cannot be undone. This will permanently delete your property.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14.sp,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Please type "$requiredText" to confirm:',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: textController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: requiredText,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(
                          color: isTextMatched ? Colors.green : Colors.red,
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(
                          color: isTextMatched ? Colors.green : Colors.grey,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(
                          color: isTextMatched ? Colors.green : Colors.red,
                          width: 2,
                        ),
                      ),
                    ),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14.sp,
                    ),
                    onChanged: (value) {
                      setDialogState(() {
                        isTextMatched = value.trim().toLowerCase() == requiredText.toLowerCase();
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    textController.dispose();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isTextMatched
                      ? () async {
                          textController.dispose();
                          Navigator.of(context).pop();
                          await _deleteProperty(property);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    disabledForegroundColor: Colors.grey[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  ),
                  child: Text(
                    'Delete',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      textController.dispose();
    });
  }

  Future<void> _deleteProperty(CustomerProperty property) async {
    // Show loading indicator
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(
          color: const Color(0xFF20B2AA),
        ),
      ),
    );

    try {
      final result = await _service.deleteProperty(property.id.toString());
      
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      if (result['success'] == true) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Property deleted successfully',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14.sp,
              ),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        );
        
        // Refresh the properties list
        _loadProperties();
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Failed to delete property',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14.sp,
              ),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error deleting property: $e',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14.sp,
            ),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      );
    }
  }

  Future<void> _loadProperties() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // If you want to test with a provided token, you can temporarily pass it here.
      // final result = await _service.getCustomerProperties(overrideToken: 'YOUR_TEST_TOKEN');
      final result = await _service.getCustomerProperties();
      
      if (result['success'] == true) {
        final data = result['data'];
        List<CustomerProperty> properties = [];
        
        // Parse properties from API response
        if (data is Map && data['properties'] is List) {
          final propertiesList = data['properties'] as List;
          properties = propertiesList.map((json) => CustomerProperty.fromJson(json)).toList();
        } else if (data is List) {
          properties = data.map((json) => CustomerProperty.fromJson(json)).toList();
        } else if (data is Map && data['data'] is List) {
          final propertiesList = data['data'] as List;
          properties = propertiesList.map((json) => CustomerProperty.fromJson(json)).toList();
        }
        
        // Load approval status for each property and geocode addresses
        for (var property in properties) {
          _loadApprovalStatus(property);
          _geocodeProperty(property);
        }
        
        // Amenities are now included in the API response - no need for separate resolution
        print('✅ Properties loaded with amenities from API');
        
        setState(() {
          _properties = properties;
          _isLoading = false;
        });
        // Apply current filter (defaults to Pending)
        _applyFilter(_selectedFilter);
      } else {
        setState(() {
          _error = result['message'] ?? 'Failed to load properties';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading properties: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadApprovalStatus(CustomerProperty property) async {
    property.isApprovalLoading = true;
    
    try {
      final result = await _service.getPropertyApprovalStatus(property.id);
      
      if (result['success']) {
        final data = result['data'];
        final newStatus = data['status']?.toString().toLowerCase() ?? 'pending';
        property.approvalStatus = newStatus;
        property.approvalNotes = data['notes']?.toString();
      } else {
        // If status fetch fails and no status was set from API, default to pending
        if (property.approvalStatus == null) {
          property.approvalStatus = 'pending';
        }
        property.approvalNotes = 'Could not fetch status';
      }
    } catch (e) {
      // If status fetch fails and no status was set from API, default to pending
      if (property.approvalStatus == null) {
        property.approvalStatus = 'pending';
      }
      property.approvalNotes = 'Error fetching status';
    } finally {
      property.isApprovalLoading = false;
      if (mounted) {
        setState(() {
          // Re-apply filter after status is loaded to ensure correct filtering
          _applyFilter(_selectedFilter);
        });
      }
    }
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      
      if (filter == 'All') {
        _filteredProperties = List.from(_properties);
      } else {
        _filteredProperties = _properties.where((property) {
          // Ensure we check the approval status correctly
          final status = property.approvalStatus?.toLowerCase();
          
          switch (filter) {
            case 'Pending':
              // Show properties that are pending (null, 'pending', or not explicitly approved/rejected)
              return status == null || status == 'pending' || status.isEmpty;
            case 'Approved':
              // Show properties that are approved (same ones that appear in search screen)
              return status == 'approved';
            case 'Rejected':
              // Show properties that are rejected
              return status == 'rejected';
            default:
              return true;
          }
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            AppIcons.arrowBackIosNew,
            color: AppTheme.primaryBlue,
            size: 16,
          ),
          onPressed: () {
            Navigator.pop(context);
            // Ensure FAB is removed when navigating back
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                AppIcons.homeWorkRounded,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'MY LISTINGS',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryBlue,
                letterSpacing: 0.5,
              ),
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
              color: AppTheme.primaryBlue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.r),
                bottomRight: Radius.circular(20.r),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter by Status',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                SizedBox(height: 12.h),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filterOptions.map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: FilterChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (selected) => _applyFilter(filter),
                          backgroundColor: Colors.white,
                          selectedColor: AppTheme.tealAccent.withValues(alpha: 0.2),
                          labelStyle: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? AppTheme.tealAccent : AppTheme.textSecondary,
                          ),
                          side: BorderSide(
                            color: isSelected ? AppTheme.tealAccent : AppTheme.borderGrey,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const OwnershipSelectionScreen(),
            ),
          );
        },
        backgroundColor: AppTheme.primaryBlue,
        icon: Icon(AppIcons.add, color: Colors.white),
        label: Text(
          'Add Property',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryBlue,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.errorOutline,
              size: 64.sp,
              color: Colors.red,
            ),
            SizedBox(height: 16.h),
            Text(
              'Error',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: _loadProperties,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Retry',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_filteredProperties.isEmpty) {
      // Special handling for Approved filter
      if (_selectedFilter == 'Approved') {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  AppIcons.homeWorkOutlined,
                  size: 64.sp,
                  color: AppTheme.textSecondary,
                ),
                SizedBox(height: 16.h),
                Text(
                  'No Approved Properties',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Approved property posts are shown in the search screen.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
                SizedBox(height: 24.h),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainWrapper(initialTabIndex: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  ),
                  icon: Icon(AppIcons.search, color: Colors.white),
                  label: Text(
                    'Go to Search Screen',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      
      // Default empty state for other filters
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home_work_outlined,
              size: 64.sp,
              color: AppTheme.textSecondary,
            ),
            SizedBox(height: 16.h),
            Text(
              _selectedFilter == 'All' ? 'No Properties Found' : 'No $_selectedFilter Properties',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              _selectedFilter == 'All' 
                  ? 'You haven\'t posted any properties yet.'
                  : 'No properties match the selected filter.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14.sp,
                color: AppTheme.textSecondary,
              ),
            ),
            if (_selectedFilter == 'All') ...[
              SizedBox(height: 24.h),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OwnershipSelectionScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                ),
                icon: Icon(AppIcons.add, color: Colors.white),
                label: Text(
                  'Post Your First Property',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProperties,
      color: AppTheme.primaryBlue,
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: _filteredProperties.length,
        itemBuilder: (context, index) {
          return _buildPropertyCard(_filteredProperties[index]);
        },
      ),
    );
  }

  Widget _buildPropertyCard(CustomerProperty property) {
    // Debug: Check property images
    print('🎴 Building card for property ${property.id} - Images: ${property.images.length}');
    if (property.images.isNotEmpty) {
      print('   📷 First image URL: ${property.images.first.substring(0, property.images.first.length > 80 ? 80 : property.images.first.length)}...');
    }
    
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ListingDetailScreen(property: property),
        ),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Image with Status Overlay
            Stack(
              children: [
                Container(
                  height: 200.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                    ),
                    color: AppTheme.lightBlue,
                  ),
                  child: (property.images.isNotEmpty)
                      ? ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16.r),
                            topRight: Radius.circular(16.r),
                          ),
                          child: Stack(
                            children: [
                              PageView.builder(
                                itemCount: property.images.length,
                                itemBuilder: (context, idx) {
                                  final raw = property.images[idx];
                                  print('🖼️ Loading image ${idx + 1}/${property.images.length}');
                                  print('   Raw URL: ${raw.substring(0, raw.length > 80 ? 80 : raw.length)}...');
                                  
                                  // The URL from API is already a complete S3 pre-signed URL
                                  // Use it directly without modification
                                  final url = raw.trim();
                                  
                                  if (url.isEmpty) {
                                    print('   ❌ Empty URL, showing placeholder');
                                    return _buildPlaceholderImage();
                                  }
                                  
                                  print('   ✅ Using URL: ${url.substring(0, url.length > 80 ? 80 : url.length)}...');
                                  return _buildRobustImage(url, idx);
                                },
                              ),
                              // Simple dots indicator
                              if (property.images.length > 1)
                                Positioned(
                                  bottom: 8,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: List.generate(
                                        property.images.length,
                                        (index) => Container(
                                          width: 6,
                                          height: 6,
                                          margin: const EdgeInsets.symmetric(horizontal: 3),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.8),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )
                      : _buildPlaceholderImage(),
                ),
              ],
            ),
            // Property Details
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Status with Edit Button
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          property.title,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      _buildStatusChip(property),
                    ],
                  ),
                  
                  SizedBox(height: 8.h),
                  
                  // Property Size
                  if (property.area != null && property.area!.isNotEmpty)
                    Text(
                      '${property.area} ${property.areaUnit ?? ''}'.trim(),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  
                  SizedBox(height: 8.h),
                  
                  // Price
                  Text(
                    '${property.priceLabel}: PKR ${property.displayPrice}',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.tealAccent,
                    ),
                  ),
                  
                  // Amenities
                  if (property.amenitiesByCategory != null && property.amenitiesByCategory!.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    _buildAmenitiesSection(property),
                  ] else if (property.amenities.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    _buildAmenitiesSection(property),
                  ],
                  
                  SizedBox(height: 16.h),
                  
                  // Action Buttons
                  _buildActionButtons(property),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildActionButtons(CustomerProperty property) {
    return Row(
      children: [
        // View Button - Longer with teal background and white text
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: () => _navigateToPropertyDetails(property),
            icon: Icon(
              AppIcons.visibilityOutlined,
              size: 16.sp,
              color: Colors.white,
            ),
            label: Text(
              'View',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF20B2AA),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 12.h),
            ),
          ),
        ),
        
        SizedBox(width: 12.w),
        
        // Update Button - Icon only
        ElevatedButton(
          onPressed: () => _navigateToUpdateProperty(property),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF20B2AA),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            padding: EdgeInsets.all(12.w),
            minimumSize: Size(48.w, 48.h),
          ),
          child: Icon(
            AppIcons.editOutlined,
            size: 20.sp,
            color: Colors.white,
          ),
        ),
        
        SizedBox(width: 12.w),
        
        // Delete Button - Icon only
        ElevatedButton(
          onPressed: () => _showDeleteConfirmation(property),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            padding: EdgeInsets.all(12.w),
            minimumSize: Size(48.w, 48.h),
          ),
          child: Icon(
            AppIcons.deleteOutline,
            size: 20.sp,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildAmenitiesSection(CustomerProperty property) {
    print('🎯 Building amenities section for property ${property.id}');
    print('   📋 amenitiesByCategory: ${property.amenitiesByCategory}');
    print('   📋 flat amenities: ${property.amenities}');
    
    // Get all amenity names to display
    final List<String> amenityNames = [];
    
    if (property.amenitiesByCategory != null && property.amenitiesByCategory!.isNotEmpty) {
      // Extract names from amenitiesByCategory
      for (final category in property.amenitiesByCategory!.values) {
        if (category is List) {
          for (var amenity in category) {
            if (amenity is Map) {
              final name = amenity['name']?.toString();
              if (name != null && name.isNotEmpty) {
                // Skip if it's still just an ID (numeric string)
                if (!RegExp(r'^\d+$').hasMatch(name)) {
                  amenityNames.add(name);
                }
              }
            }
          }
        }
      }
    } else if (property.amenities.isNotEmpty) {
      // Use flat amenities list, but skip numeric IDs
      for (final amenity in property.amenities) {
        if (amenity.isNotEmpty && !RegExp(r'^\d+$').hasMatch(amenity)) {
          amenityNames.add(amenity);
        }
      }
    }
    
    // If no resolved names but we have amenities, show count
    if (amenityNames.isEmpty && 
        ((property.amenitiesByCategory != null && property.amenitiesByCategory!.isNotEmpty) || 
         property.amenities.isNotEmpty)) {
      final totalCount = property.amenitiesByCategory?.values
          .expand((list) => list is List ? list : [])
          .length ?? property.amenities.length;
      
      if (totalCount > 0) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppTheme.lightBlue,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            '$totalCount amenities',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryBlue,
            ),
          ),
        );
      }
    }
    
    if (amenityNames.isEmpty) return const SizedBox.shrink();
    
    // Show up to 3 amenities, with "and X more" if there are more
    final displayAmenities = amenityNames.take(3).toList();
    final remainingCount = amenityNames.length - displayAmenities.length;
    
    return Wrap(
      spacing: 6.w,
      runSpacing: 6.h,
      children: [
        ...displayAmenities.map((name) => Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppTheme.lightBlue,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            name,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryBlue,
            ),
          ),
        )),
        if (remainingCount > 0)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppTheme.lightBlue,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              '+$remainingCount more',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRobustImage(String url, int imageIndex) {
    return FutureBuilder<Widget>(
      future: _loadImageWithFallback(url, imageIndex),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 200.h,
            color: AppTheme.lightBlue,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppTheme.primaryBlue,
                    strokeWidth: 2,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Loading image...',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        if (snapshot.hasError || !snapshot.hasData) {
          print('❌ Image load failed for: ${url.substring(0, url.length > 60 ? 60 : url.length)}...');
          return _buildPlaceholderImage();
        }
        
        return snapshot.data!;
      },
    );
  }

  Future<Widget> _loadImageWithFallback(String url, int imageIndex) async {
    try {
      // Validate and potentially fix the URL
      final validatedUrl = _validateAndFixS3Url(url);
      print('🔍 Validated URL for image $imageIndex: ${validatedUrl.substring(0, validatedUrl.length > 80 ? 80 : validatedUrl.length)}...');
      
      // Use CachedNetworkImage for better CORS handling and error management
      return Container(
        width: double.infinity,
        height: 200.h,
        child: CachedNetworkImage(
          imageUrl: validatedUrl,
          width: double.infinity,
          height: 200.h,
          fit: BoxFit.cover,
          httpHeaders: {
            'Accept': 'image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
          },
          placeholder: (context, url) => Container(
            height: 200.h,
            color: AppTheme.lightBlue,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppTheme.primaryBlue,
                    strokeWidth: 2,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Loading image...',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          errorWidget: (context, url, error) {
            print('❌ Image load error for image $imageIndex: $error');
            print('❌ Failed URL: $validatedUrl');
            return _buildPlaceholderImage();
          },
          fadeInDuration: const Duration(milliseconds: 300),
          fadeOutDuration: const Duration(milliseconds: 100),
        ),
      );
    } catch (e, stackTrace) {
      print('❌ Exception loading image $imageIndex: $e');
      print('❌ Stack trace: $stackTrace');
      return _buildPlaceholderImage();
    }
  }

  String _validateAndFixS3Url(String url) {
    try {
      // If it's already a full URL, validate it
      if (url.startsWith('http')) {
        final uri = Uri.parse(url);
        
        // Check if it's an S3 URL and fix common issues
        if (uri.host.contains('s3') || uri.host.contains('amazonaws.com')) {
          // Ensure the URL is properly encoded
          final fixedUrl = url.replaceAll(' ', '%20');
          
          // For S3 signed URLs, ensure they're not expired
          if (url.contains('X-Amz-Expires')) {
            final expiresMatch = RegExp(r'X-Amz-Expires=(\d+)').firstMatch(url);
            if (expiresMatch != null) {
              final expires = int.tryParse(expiresMatch.group(1) ?? '0') ?? 0;
              print('🕐 S3 URL expires in: ${expires}s');
            }
          }
          
          return fixedUrl;
        }
        
        return url;
      }
      
      // If it's a relative path, prepend the base URL
      final baseUrl = 'https://testingbackend.dhamarketplace.com';
      final cleanPath = url.startsWith('/') ? url : '/$url';
      return '$baseUrl$cleanPath';
      
    } catch (e) {
      print('❌ Error validating URL: $e');
      return url;
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: 200.h,
      decoration: BoxDecoration(
        color: AppTheme.lightBlue,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              AppIcons.imageNotSupportedOutlined,
              size: 32.sp,
              color: AppTheme.primaryBlue,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Image Unavailable',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Unable to load property image',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.sp,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(CustomerProperty property) {
    if (property.isApprovalLoading == true) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12.sp,
              height: 12.sp,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.textSecondary),
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              'Loading...',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: property.statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: property.statusColor.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        property.statusText,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: property.statusColor,
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppTheme.lightBlue,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12.sp,
            color: AppTheme.primaryBlue,
          ),
          SizedBox(width: 4.w),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  // Top-right status pill overlay (e.g., Available/Pending/Rejected)
  Widget _buildStatusPill(CustomerProperty property) {
    final bg = property.statusColor.withValues(alpha: 0.12);
    final fg = property.statusColor;
    final text = property.isApproved ? 'Available' : property.statusText;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: fg.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            property.isApproved
                ? AppIcons.checkCircle
                : property.isRejected
                    ? AppIcons.cancel
                    : AppIcons.hourglassTop,
            size: 14.sp,
            color: fg,
          ),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
  
  // Build contact icon overlay button
  Widget _buildContactIcon({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44.w,
        height: 44.w,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: const Color(0xFF20B2AA), // Teal color
          size: 20.sp,
        ),
      ),
    );
  }
  
  // Make phone call
  Future<void> _makeCall(String phoneNumber) async {
    try {
      await CallService.launchCall(phoneNumber);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to make call: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // Send WhatsApp message
  Future<void> _sendWhatsApp(String phoneNumber, CustomerProperty property) async {
    try {
      final message = 'Hi, I am interested in your property "${property.title}"';
      await WhatsAppService.launchWhatsApp(
        phoneNumber: phoneNumber,
        message: message,
        context: context,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open WhatsApp: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}