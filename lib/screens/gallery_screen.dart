import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:photo_view/photo_view.dart';
import '../ui/widgets/cached_asset_image.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final List<Map<String, dynamic>> _galleryImages = [
    {
      'image': 'assets/gallery/dha-gate-night.jpg',
      'title': 'DHA Phase 4 Entrance',
      'category': 'Infrastructure',
    },
    {
      'image': 'assets/gallery/dha-medical-center.jpg',
      'title': 'DHA Medical Center',
      'category': 'Healthcare',
    },
    {
      'image': 'assets/gallery/dha-commercial-center.jpg',
      'title': 'DHA Commercial Center',
      'category': 'Commercial',
    },
    {
      'image': 'assets/gallery/dha-sports-facility.jpg',
      'title': 'DHA Sports Complex',
      'category': 'Recreation',
    },
    {
      'image': 'assets/gallery/dha-mosque-night.jpg',
      'title': 'DHA Grand Mosque',
      'category': 'Religious',
    },
    {
      'image': 'assets/gallery/imperial-hall.jpg',
      'title': 'DHA Imperial Hall',
      'category': 'Community',
    },
    {
      'image': 'assets/gallery/dha-park-night.jpg',
      'title': 'DHA Community Park',
      'category': 'Recreation',
    },
  ];

  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Commercial',
    'Healthcare',
    'Infrastructure',
    'Recreation',
    'Religious',
    'Community',
  ];

  List<Map<String, dynamic>> get _filteredImages {
    if (_selectedCategory == 'All') {
      return _galleryImages;
    }
    return _galleryImages.where((image) => image['category'] == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F6),
      appBar: AppBar(
        title: Text(
          'Gallery',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1E3C90),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Category Filter
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((category) {
                  final isSelected = category == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: FilterChip(
                      label: Text(
                        category,
                        style: GoogleFonts.inter(
                          color: isSelected ? Colors.white : const Color(0xFF1E3C90),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      backgroundColor: Colors.white,
                      selectedColor: const Color(0xFF2ECC71),
                      checkmarkColor: Colors.white,
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF2ECC71) : Colors.grey[300]!,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          // Gallery Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: MasonryGridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                itemCount: _filteredImages.length,
                itemBuilder: (context, index) {
                  final image = _filteredImages[index];
                  return _buildGalleryItem(image, index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryItem(Map<String, dynamic> image, int index) {
    return GestureDetector(
      onTap: () => _showFullScreenImage(image, index),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Container(
                height: _getImageHeight(index),
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(image['image']),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Category Badge
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2ECC71),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            image['category'],
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      // View Icon
                      const Positioned(
                        top: 12,
                        right: 12,
                        child: Icon(
                          Icons.zoom_in,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Title
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.white,
                child: Text(
                  image['title'],
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF222222),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _getImageHeight(int index) {
    // Vary heights for masonry effect
    final heights = [200.0, 250.0, 180.0, 220.0, 190.0, 240.0, 210.0, 230.0];
    return heights[index % heights.length];
  }

  void _showFullScreenImage(Map<String, dynamic> image, int currentIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageViewer(
          images: _filteredImages,
          currentIndex: currentIndex,
        ),
      ),
    );
  }
}

class FullScreenImageViewer extends StatefulWidget {
  final List<Map<String, dynamic>> images;
  final int currentIndex;

  const FullScreenImageViewer({
    super.key,
    required this.images,
    required this.currentIndex,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
    _pageController = PageController(initialPage: widget.currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Image Viewer
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              final image = widget.images[index];
              return Center(
                child: PhotoView(
                  imageProvider: AssetImage(image['image']),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2.0,
                ),
              );
            },
          ),
          
          // Top Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.images[_currentIndex]['title'],
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Share functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Share functionality coming soon')),
                      );
                    },
                    icon: const Icon(
                      Icons.share,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: widget.images.asMap().entries.map((entry) {
                      return Container(
                        width: 8.0,
                        height: 8.0,
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentIndex == entry.key
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  
                  // Image Info
                  Text(
                    '${_currentIndex + 1} of ${widget.images.length}',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
