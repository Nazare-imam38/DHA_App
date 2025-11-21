import 'package:flutter/material.dart';
import '../../my_listings_screen.dart';
import 'owner_details_step.dart';
import 'review_confirmation_step.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import '../models/property_form_data.dart';
import '../../../services/media_upload_service.dart';
import '../../../ui/widgets/app_icons.dart';
import 'review_confirmation_step.dart';
import '../../../core/theme/app_theme.dart';

class MediaUploadStep extends StatefulWidget {
  @override
  _MediaUploadStepState createState() => _MediaUploadStepState();
}

class _MediaUploadStepState extends State<MediaUploadStep> {
  List<File> _selectedImages = [];
  List<File> _selectedVideos = [];
  bool _isUploading = false;
  final int _maxImageSize = 3 * 1024 * 1024; // 3MB in bytes
  final int _maxVideoSize = 50 * 1024 * 1024; // 50MB for videos
  final MediaUploadService _mediaUploadService = MediaUploadService();
  String _uploadStatus = '';
  double _uploadProgress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            AppIcons.arrowBackIosNew,
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
                AppIcons.photoLibraryRounded,
                    color: Colors.white,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'MEDIA UPLOAD',
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
      body: Consumer<PropertyFormData>(
        builder: (context, formData, child) {
          return Column(
            children: [
              // Process Indicator
              Container(
                padding: EdgeInsets.all(16.w),
                child: Center(
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
                              '6',
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
                          'Media Upload',
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
              ),
              
              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Photos Section
                      _buildPhotosSection(),
                      
                      SizedBox(height: 24.h),
                      
                      // Videos Section
                      _buildVideosSection(),
                      
                      SizedBox(height: 24.h),
                      
                      // Upload Progress
                      if (_isUploading) _buildUploadProgress(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: AppTheme.cardWhite,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
          boxShadow: AppTheme.lightShadow,
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  side: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Back to Amenities',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _nextStep(context, context.read<PropertyFormData>()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      AppIcons.arrowForward,
                      color: AppTheme.cardWhite,
                      size: 20,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Continue',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.cardWhite,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: const Icon(
                  AppIcons.photoLibrary,
                  color: AppTheme.primaryBlue,
                  size: 24,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Step 6: Media Upload',
                      style: AppTheme.titleLarge.copyWith(
                        fontSize: 18.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Add photos and videos of your property',
                      style: AppTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppTheme.lightBlue,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(
                color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  AppIcons.infoOutline,
                  color: AppTheme.primaryBlue,
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Upload high-quality photos and videos to showcase your property effectively.',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
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
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B5993).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  AppIcons.imageRounded,
                  color: const Color(0xFF1B5993),
                  size: 24.w,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Property Photos',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1B5993),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F4FD),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '${_selectedImages.length}/20',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1B5993),
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 8.h),
          
          Text(
            'Upload up to 20 photos (max 3MB each)',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B7280),
            ),
          ),
          
          SizedBox(height: 20.h),
          
          // Photo Upload Area
          _buildPhotoUploadArea(),
          
          SizedBox(height: 20.h),
          
          // Photo Grid
          if (_selectedImages.isNotEmpty) _buildPhotoGrid(),
        ],
      ),
    );
  }

  Widget _buildPhotoUploadArea() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        height: 200.h,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Stack(
          children: [
            // Dashed border effect using custom painter
            CustomPaint(
              size: Size(double.infinity, 200.h),
              painter: _DashedBorderPainter(),
            ),
            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    AppIcons.arrowUpwardRounded,
                    color: const Color(0xFF4B5563),
                    size: 56.w,
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Click to upload photos',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    '${_selectedImages.length}/20 photos uploaded',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
      ),
      itemCount: _selectedImages.length,
      itemBuilder: (context, index) {
        return Stack(
          children: [
                Container(
                  decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                  color: AppTheme.textLight.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.file(
                  _selectedImages[index],
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppTheme.error,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    AppIcons.close,
                    color: AppTheme.cardWhite,
                    size: 16.sp,
                  ),
                ),
                  ),
                ),
              ],
            );
          },
    );
  }

  Widget _buildVideosSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
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
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B5993).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  AppIcons.videocamRounded,
                  color: const Color(0xFF1B5993),
                  size: 24.w,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Property Videos',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1B5993),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F4FD),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '${_selectedVideos.length}/5',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1B5993),
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 8.h),
          
          Text(
            'Upload up to 5 videos (max 50MB each)',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B7280),
            ),
          ),
          
          SizedBox(height: 20.h),
          
          // Video Upload Area
          _buildVideoUploadArea(),
          
          SizedBox(height: 20.h),
          
          // Video List
          if (_selectedVideos.isNotEmpty) _buildVideoList(),
        ],
      ),
    );
  }
  
  Widget _buildVideoUploadArea() {
    return GestureDetector(
      onTap: _pickVideos,
      child: Container(
        height: 200.h,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Stack(
          children: [
            // Dashed border effect using custom painter
            CustomPaint(
              size: Size(double.infinity, 200.h),
              painter: _DashedBorderPainter(),
            ),
            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    AppIcons.movieFilterRounded,
                    color: const Color(0xFF4B5563),
                    size: 56.w,
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Click to upload videos',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    '${_selectedVideos.length} video(s) uploaded',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoList() {
    return Column(
      children: _selectedVideos.asMap().entries.map((entry) {
        int index = entry.key;
        File video = entry.value;
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppTheme.backgroundGrey,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppTheme.textLight.withValues(alpha: 0.2),
              width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
                padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                  AppIcons.playCircleOutline,
                  color: AppTheme.primaryBlue,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Expanded(
                      child: Text(
                        video.path.split('/').last,
                        style: TextStyle(
                      fontFamily: 'Inter',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBlue,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    SizedBox(height: 4.h),
                  Text(
                      '${(video.lengthSync() / (1024 * 1024)).toStringAsFixed(1)} MB',
                        style: TextStyle(
                      fontFamily: 'Inter',
                        fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
              GestureDetector(
                onTap: () => _removeVideo(index),
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    AppIcons.deleteOutline,
                    color: AppTheme.error,
                    size: 20.sp,
                  ),
                  ),
                ),
              ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUploadProgress() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 20.w,
                height: 20.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: _uploadProgress > 0 ? _uploadProgress : null,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  _uploadStatus.isNotEmpty ? _uploadStatus : 'Uploading media files...',
                  style: TextStyle(
              fontFamily: 'Inter',
                    fontSize: 14.sp,
              fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          if (_uploadProgress > 0) ...[
            SizedBox(height: 12.h),
            LinearProgressIndicator(
              value: _uploadProgress,
              backgroundColor: AppTheme.textLight.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
            ),
            SizedBox(height: 8.h),
          Text(
              '${(_uploadProgress * 100).toInt()}% complete',
              style: TextStyle(
              fontFamily: 'Inter',
                fontSize: 12.sp,
              fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
            ),
          ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildActionButtons(BuildContext context, PropertyFormData formData) {
    final hasMedia = _selectedImages.isNotEmpty || _selectedVideos.isNotEmpty;
    
    return Column(
      children: [
        // Optional Message
        if (!hasMedia)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            margin: EdgeInsets.only(bottom: 16.h),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  AppIcons.infoRounded,
                  color: AppTheme.primaryBlue,
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'You can skip media upload for now and add photos/videos later. However, properties with media get more attention from buyers.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        // Action Buttons Row
        Row(
          children: [
        Expanded(
          child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              side: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              'Back to Amenities',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBlue,
              ),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _nextStep(context, formData), // Always enabled
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue, // Always blue
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.arrow_forward,
                  color: AppTheme.cardWhite,
                  size: 20,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Continue',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.cardWhite,
                  ),
                ),
              ],
            ),
          ),
        ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        allowCompression: true,
      );

      if (result != null) {
        List<File> newImages = [];
        
        for (var file in result.files) {
          // Check file size
          if (file.size <= _maxImageSize) {
            try {
              File tempFile;
              
              if (file.bytes != null) {
                // For web and mobile, create a temporary file from bytes
                final tempDir = await getTemporaryDirectory();
                tempFile = File('${tempDir.path}/temp_image_${DateTime.now().millisecondsSinceEpoch}.${file.extension}');
                await tempFile.writeAsBytes(file.bytes!);
              } else if (file.path != null) {
                // For mobile platforms, use the path directly
                tempFile = File(file.path!);
              } else {
                print('No file data available for ${file.name}');
                continue;
              }
              
              newImages.add(tempFile);
            } catch (e) {
              print('Error processing image ${file.name}: $e');
              continue;
            }
          } else {
            print('Image ${file.name} is too large (${(file.size / (1024 * 1024)).toStringAsFixed(1)}MB). Skipping...');
          }
        }

        if (result.files.length != newImages.length) {
          _showErrorDialog('Some images were too large and were not added. Maximum size is 3MB per image.');
        }

        if (_selectedImages.length + newImages.length > 20) {
          _showErrorDialog('Maximum 20 photos allowed. Please remove some existing photos first.');
          return;
        }

        setState(() {
          _selectedImages.addAll(newImages);
        });
      }
    } catch (e) {
      _showErrorDialog('Error selecting images: $e');
    }
  }

  Future<void> _pickVideos() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: true,
        allowCompression: true,
      );

      if (result != null) {
        List<File> newVideos = [];
        
        for (var file in result.files) {
          // Check file size
          if (file.size <= _maxVideoSize) {
            try {
              File tempFile;
              
              if (file.bytes != null) {
                // For web and mobile, create a temporary file from bytes
                final tempDir = await getTemporaryDirectory();
                tempFile = File('${tempDir.path}/temp_video_${DateTime.now().millisecondsSinceEpoch}.${file.extension}');
                await tempFile.writeAsBytes(file.bytes!);
              } else if (file.path != null) {
                // For mobile platforms, use the path directly
                tempFile = File(file.path!);
              } else {
                print('No file data available for ${file.name}');
                continue;
              }
              
              newVideos.add(tempFile);
            } catch (e) {
              print('Error processing video ${file.name}: $e');
              continue;
            }
          } else {
            print('Video ${file.name} is too large (${(file.size / (1024 * 1024)).toStringAsFixed(1)}MB). Skipping...');
          }
        }

        if (result.files.length != newVideos.length) {
          _showErrorDialog('Some videos were too large and were not added. Maximum size is 50MB per video.');
        }

        if (_selectedVideos.length + newVideos.length > 5) {
          _showErrorDialog('Maximum 5 videos allowed. Please remove some existing videos first.');
          return;
        }

        setState(() {
          _selectedVideos.addAll(newVideos);
        });
      }
    } catch (e) {
      _showErrorDialog('Error selecting videos: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _removeVideo(int index) {
    setState(() {
      _selectedVideos.removeAt(index);
    });
  }

  void _testApiConnection() async {
    setState(() {
      _isUploading = true;
      _uploadStatus = 'Testing API connection...';
      _uploadProgress = 0.0;
    });

    try {
      final result = await _mediaUploadService.testApiConnection();
      
      setState(() {
        _isUploading = false;
        _uploadStatus = '';
        _uploadProgress = 0.0;
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(
                result['success'] == true ? AppIcons.checkCircle : AppIcons.error,
                color: result['success'] == true ? AppTheme.success : AppTheme.error,
                size: 28.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                result['success'] == true ? 'API Connected!' : 'API Error',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                    color: AppTheme.primaryBlue,
                  ),
                ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result['success'] == true 
                    ? 'Successfully connected to the property creation API.'
                    : 'Failed to connect to the API.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (result['statusCode'] != null) ...[
                SizedBox(height: 12.h),
                Text(
                  'Status Code: ${result['statusCode']}',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
                  ),
                ),
              ],
              if (result['body'] != null) ...[
                SizedBox(height: 8.h),
                Text(
                  'Response: ${result['body'].toString().substring(0, 100)}...',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'OK',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryBlue,
                ),
              ),
              ),
            ],
          ),
        );
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadStatus = '';
        _uploadProgress = 0.0;
      });
      _showErrorDialog('Test failed: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Error',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
              color: AppTheme.primaryBlue,
          ),
        ),
        content: Text(
          message,
              style: const TextStyle(
                fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _nextStep(BuildContext context, PropertyFormData formData) async {
    // If user picked media, attempt upload; otherwise skip upload and continue
    if (_selectedImages.isNotEmpty || _selectedVideos.isNotEmpty) {
      setState(() {
        _isUploading = true;
        _uploadStatus = 'Preparing files for upload...';
        _uploadProgress = 0.0;
      });

      try {
        final propertyData = _preparePropertyData(formData);
        setState(() {
          _uploadStatus = 'Uploading to Amazon S3...';
          _uploadProgress = 0.2;
        });

        final uploadResult = await _mediaUploadService.uploadPropertyMedia(
          images: _selectedImages,
          videos: _selectedVideos,
          propertyData: propertyData,
        );

        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
          _uploadStatus = '';
        });

        if (uploadResult['success'] != true) {
          _showErrorDialog('Upload failed: ${uploadResult['message'] ?? 'Unknown error'}');
        }

        // Persist selected media regardless of success so user can retry later
        formData.updateMedia(images: _selectedImages, videos: _selectedVideos);
      } catch (e) {
        setState(() {
          _isUploading = false;
          _uploadStatus = '';
          _uploadProgress = 0.0;
        });
        _showErrorDialog('Upload failed: $e');
        formData.updateMedia(images: _selectedImages, videos: _selectedVideos);
      }
    }

    // Always go to Owner Details Step (Step 7)
    // - If own property: form will be pre-filled from user API
    // - If on behalf: form will be empty for manual input
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: formData,
          child: const OwnerDetailsStep(),
        ),
      ),
    );
  }

  Map<String, dynamic> _preparePropertyData(PropertyFormData formData) {
    return {
      // Basic property info
      'category': formData.category,
      'property_type_id': formData.propertyTypeId,
      'property_type_name': formData.propertyTypeName,
      'property_subtype_id': formData.propertySubtypeId,
      'property_subtype_name': formData.propertySubtypeName,
      'title': formData.title,
      'description': formData.description,
      'listing_duration': formData.listingDuration,
      'purpose': formData.purpose,
      
      // Pricing
      'price': formData.price,
      'rent_price': formData.rentPrice,
      'property_duration': formData.propertyDuration,
      
      // Property details
      'building_name': formData.buildingName,
      'floor_number': formData.floorNumber,
      'apartment_number': formData.apartmentNumber,
      'area': formData.area,
      'area_unit': formData.areaUnit,
      'street_number': formData.streetNumber,
      
      // Location details
      'location': formData.location,
      'sector': formData.sector,
      'phase': formData.phase,
      'latitude': formData.latitude,
      'longitude': formData.longitude,
      'block': formData.block,
      'street_no': formData.streetNo,
      'floor': formData.floor,
      'building': formData.building,
      
      // Unit details
      'unit_no': formData.unitNo,
      
      // Payment method
      'payment_method': formData.paymentMethod,
      
      // Amenities
      'amenities': formData.amenities.join(','),
      
      // Owner details (if applicable)
      'on_behalf': formData.onBehalf,
      'cnic': formData.cnic,
      'name': formData.name,
      'phone': formData.phone,
      'address': formData.address,
      'email': formData.email,
    };
  }

  void _showSuccessDialog(BuildContext context, Map<String, dynamic> uploadResult) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              AppIcons.checkCircle,
              color: AppTheme.success,
              size: 28.sp,
            ),
            SizedBox(width: 12.w),
            const Text(
              'Upload Successful!',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryBlue,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your property has been successfully uploaded to Amazon S3 and submitted for review.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 16.h),
            if (uploadResult['data'] != null) ...[
              Text(
                'Property ID: ${uploadResult['data']['id'] ?? 'N/A'}',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              // Navigate to My Listings so user can see the newly posted item under Pending
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MyListingsScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: const Text(
              'Back to Home',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                color: AppTheme.cardWhite,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Dashed Border with rounded corners
class _DashedBorderPainter extends CustomPainter {
  final double radius = 12.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    const dashWidth = 8.0;
    const dashSpace = 4.0;

    // Draw dashed lines for each side (accounting for rounded corners)
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
        Radius.circular(radius),
      ));

    // Draw dashed path manually
    final metrics = path.computeMetrics();
    for (var metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final pathSegment = Path();
        final start = metric.getTangentForOffset(distance);
        final end = metric.getTangentForOffset(
          (distance + dashWidth).clamp(0.0, metric.length),
        );
        if (start != null && end != null) {
          pathSegment.moveTo(start.position.dx, start.position.dy);
          pathSegment.lineTo(end.position.dx, end.position.dy);
          canvas.drawPath(pathSegment, paint);
        }
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}