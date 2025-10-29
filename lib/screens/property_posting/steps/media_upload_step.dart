import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import '../models/property_form_data.dart';
import '../../../services/media_upload_service.dart';
import 'owner_details_step.dart';
import 'review_confirmation_step.dart';

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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1B5993)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Media Upload',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1B5993),
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<PropertyFormData>(
        builder: (context, formData, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                // Header Section
                _buildHeaderSection(),
                
                SizedBox(height: 32.h),
                
                // Photos Section
                _buildPhotosSection(),
                
                SizedBox(height: 32.h),
                
                // Videos Section
                _buildVideosSection(),
                
                SizedBox(height: 32.h),
                
                // Upload Progress
                if (_isUploading) _buildUploadProgress(),
                
                SizedBox(height: 32.h),
                
                // Action Buttons
                _buildActionButtons(context, formData),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: EdgeInsets.all(24.w),
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
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B5993).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF1B5993),
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
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1B5993),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Add photos and videos of your property',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF616161),
              ),
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
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                color: const Color(0xFF1B5993).withValues(alpha: 0.2),
                width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                Icon(
                  Icons.info_outline,
                  color: const Color(0xFF1B5993),
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                            child: Text(
                    'Upload high-quality photos and videos to showcase your property effectively.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1B5993),
                    ),
                          ),
                        ),
                      ],
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // Test API Connection Button
          OutlinedButton.icon(
            onPressed: _testApiConnection,
            icon: Icon(
              Icons.api,
              color: const Color(0xFF1B5993),
              size: 18.sp,
            ),
            label: Text(
              'Test API Connection',
                  style: TextStyle(
                    fontFamily: 'Inter',
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1B5993),
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF1B5993), width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            ),
                      ),
                    ],
                  ),
    );
  }

  Widget _buildPhotosSection() {
    return Container(
      padding: EdgeInsets.all(24.w),
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
              Icon(
                Icons.photo,
                color: const Color(0xFF1B5993),
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                'Property Photos',
                        style: TextStyle(
                          fontFamily: 'Inter',
                  fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                  color: const Color(0xFF1B5993),
                ),
              ),
              const Spacer(),
              Text(
                '${_selectedImages.length}/20',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF616161),
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
              fontWeight: FontWeight.w500,
              color: const Color(0xFF616161),
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
        height: 120.h,
                  decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: const Color(0xFF1B5993).withValues(alpha: 0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
                  ),
                  child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
                    children: [
            Icon(
              Icons.cloud_upload_outlined,
              color: const Color(0xFF1B5993),
              size: 32.sp,
            ),
            SizedBox(height: 8.h),
            Text(
              'Tap to select photos',
                        style: TextStyle(
                          fontFamily: 'Inter',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1B5993),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'or drag and drop files here',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF616161),
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
                  color: Colors.grey.withValues(alpha: 0.2),
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
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
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
      padding: EdgeInsets.all(24.w),
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
              Icon(
                Icons.videocam,
                    color: const Color(0xFF1B5993),
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                        'Property Videos',
                        style: TextStyle(
                          fontFamily: 'Inter',
                  fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                  color: const Color(0xFF1B5993),
                ),
              ),
              const Spacer(),
              Text(
                '${_selectedVideos.length}/5',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF616161),
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
              fontWeight: FontWeight.w500,
              color: const Color(0xFF616161),
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
        height: 100.h,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: const Color(0xFF1B5993).withValues(alpha: 0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              color: const Color(0xFF1B5993),
              size: 28.sp,
            ),
            SizedBox(height: 8.h),
            Text(
              'Tap to select videos',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1B5993),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'MP4, MOV, AVI formats supported',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF616161),
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
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.2),
              width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
                padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                      color: const Color(0xFF1B5993).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                  Icons.play_circle_outline,
                  color: const Color(0xFF1B5993),
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
                          color: const Color(0xFF1B5993),
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
                        color: const Color(0xFF616161),
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
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.red,
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
          color: const Color(0xFF1B5993).withValues(alpha: 0.3),
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
                  valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF1B5993)),
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
                    color: const Color(0xFF1B5993),
                  ),
                ),
              ),
            ],
          ),
          if (_uploadProgress > 0) ...[
            SizedBox(height: 12.h),
            LinearProgressIndicator(
              value: _uploadProgress,
              backgroundColor: Colors.grey.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF1B5993)),
            ),
            SizedBox(height: 8.h),
          Text(
              '${(_uploadProgress * 100).toInt()}% complete',
              style: TextStyle(
              fontFamily: 'Inter',
                fontSize: 12.sp,
              fontWeight: FontWeight.w500,
                color: const Color(0xFF616161),
            ),
          ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildActionButtons(BuildContext context, PropertyFormData formData) {
    return Row(
          children: [
        Expanded(
          child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              side: const BorderSide(color: Color(0xFF1B5993), width: 2),
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
                    color: const Color(0xFF1B5993),
              ),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _nextStep(context, formData),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B5993),
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
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Continue',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
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
                result['success'] == true ? Icons.check_circle : Icons.error,
                color: result['success'] == true ? Colors.green : Colors.red,
                size: 28.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                result['success'] == true ? 'API Connected!' : 'API Error',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                    color: Color(0xFF1B5993),
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
                color: const Color(0xFF616161),
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
                    color: const Color(0xFF616161),
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
                  color: Color(0xFF1B5993),
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
              color: Color(0xFF1B5993),
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
                color: Color(0xFF1B5993),
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

    // Branching: if user is posting on behalf and owner details missing -> ask now; else show review
    final isOnBehalf = formData.onBehalf == 1;
    final ownerDetailsMissing = formData.onBehalf == 1 && (formData.name == null || formData.phone == null || formData.cnic == null || formData.address == null);

    if (isOnBehalf && ownerDetailsMissing) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider.value(
            value: formData,
            child: OwnerDetailsStep(),
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: formData,
          child: ReviewConfirmationStep(),
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
              Icons.check_circle,
              color: Colors.green,
              size: 28.sp,
            ),
            SizedBox(width: 12.w),
            const Text(
              'Upload Successful!',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                color: Color(0xFF1B5993),
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
                  color: const Color(0xFF616161),
                ),
              ),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.popUntil(context, (route) => route.isFirst); // Go to home
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B5993),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: const Text(
              'Back to Home',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}