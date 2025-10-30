import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/customer_property.dart';
import '../core/theme/app_theme.dart';

class ListingDetailScreen extends StatefulWidget {
  final CustomerProperty property;
  const ListingDetailScreen({super.key, required this.property});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final p = widget.property;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundGrey,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryBlue, size: 16),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Property Details',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryBlue,
            ),
          ),
          bottom: const TabBar(
            labelColor: AppTheme.primaryBlue,
            unselectedLabelColor: AppTheme.textSecondary,
            tabs: [
              Tab(icon: Icon(Icons.star_border), text: 'Features'),
              Tab(icon: Icon(Icons.place_outlined), text: 'Location'),
              Tab(icon: Icon(Icons.receipt_long), text: 'Payment'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Header image with overlay price/title
            _buildHeader(p),
            Expanded(
              child: TabBarView(
                children: [
                  _buildFeatures(p),
                  _buildLocation(p),
                  _buildPayment(p),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(CustomerProperty p) {
    return Stack(
      children: [
        Container(
          height: 180.h,
          width: double.infinity,
          color: AppTheme.lightBlue,
          child: p.images.isNotEmpty
              ? Image.network(
                  p.images.first,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(color: AppTheme.lightBlue),
                )
              : Container(color: AppTheme.lightBlue),
        ),
        Container(
          height: 180.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.0), Colors.black.withOpacity(0.6)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Positioned(
          top: 12,
          left: 12,
          child: _buildStatusPill(p),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PKR ${p.displayPrice}',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontSize: 18.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                p.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white70, size: 14),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      p.fullLocation,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white70,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildStatusPill(CustomerProperty p) {
    final bg = p.statusColor.withOpacity(0.12);
    final fg = p.statusColor;
    final text = p.isApproved ? 'Available' : p.statusText;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            p.isApproved
                ? Icons.check_circle
                : p.isRejected
                    ? Icons.cancel
                    : Icons.hourglass_top,
            size: 14,
            color: fg,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures(CustomerProperty p) {
    final amenities = p.amenities;
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plot Features',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryBlue,
            ),
          ),
          SizedBox(height: 12.h),
          if (amenities.isEmpty)
            const Text('No features provided')
          else
            ...amenities.map((name) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(fontFamily: 'Inter'),
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildLocation(CustomerProperty p) {
    final lat = p.latitude;
    final lng = p.longitude;
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Location',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryBlue,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            height: 220.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            clipBehavior: Clip.antiAlias,
            child: (lat != null && lng != null)
                ? FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(lat, lng),
                      initialZoom: 14,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.dhamarketplace.app',
                      ),
                      MarkerLayer(markers: [
                        Marker(
                          point: LatLng(lat, lng),
                          width: 36,
                          height: 36,
                          alignment: Alignment.topCenter,
                          child: const Icon(Icons.location_on, color: Color(0xFFE53935), size: 32),
                        )
                      ])
                    ],
                  )
                : const Center(child: Text('No location available')),
          ),
        ],
      ),
    );
  }

  Widget _buildPayment(CustomerProperty p) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryBlue,
            ),
          ),
          SizedBox(height: 12.h),
          _buildPaymentRow('Price', 'PKR ${p.displayPrice}'),
          if (p.paymentMethod != null && p.paymentMethod!.isNotEmpty)
            _buildPaymentRow('Payment Method', p.paymentMethod!),
          if (p.category.isNotEmpty)
            _buildPaymentRow('Category', p.category),
          if (p.purpose.isNotEmpty)
            _buildPaymentRow('Purpose', p.purpose),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderGrey),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
