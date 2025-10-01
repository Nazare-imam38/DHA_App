import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/plots_provider.dart';
import 'main_wrapper.dart';
import '../ui/screens/auth/login_screen.dart';

class EnhancedSplashScreen extends StatefulWidget {
  const EnhancedSplashScreen({super.key});

  @override
  State<EnhancedSplashScreen> createState() => _EnhancedSplashScreenState();
}

class _EnhancedSplashScreenState extends State<EnhancedSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  late AnimationController _pulseController;
  
  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _textFade;
  late Animation<double> _progressFade;
  late Animation<double> _backgroundOpacity;
  late Animation<double> _pulseAnimation;
  
  double _currentProgress = 0.0;
  String _currentMessage = 'Initializing...';
  bool _isLoading = true;
  Map<String, dynamic> _loadingStages = {};
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startLoadingSequence();
  }
  
  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    
    _logoRotation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );
    
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );
    
    _progressFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeIn),
    );
    
    _backgroundOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }
  
  void _startLoadingSequence() async {
    // Start animations
    await _logoController.forward();
    await _textController.forward();
    await _progressController.forward();
    _pulseController.repeat(reverse: true);
    
    // Initialize app
    await _initializeApp();
  }
  
  Future<void> _initializeApp() async {
    try {
      // Stage 1: App Initialization (0-20%)
      _updateProgress(0.1, 'Initializing app...');
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Stage 2: Basic Setup (20-40%)
      _updateProgress(0.2, 'Setting up services...');
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Stage 3: Authentication Check (40-60%)
      _updateProgress(0.4, 'Checking authentication...');
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Stage 4: Final Setup (60-100%)
      _updateProgress(0.6, 'Preparing app...');
      await Future.delayed(const Duration(milliseconds: 500));
      
      _updateProgress(0.8, 'Almost ready...');
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Stage 5: Complete (100%)
      _updateProgress(1.0, 'Ready to launch!');
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Navigate to main app
      if (mounted) {
        await _navigateToMainApp();
      }
      
    } catch (e) {
      await _handleLoadingError(e);
    }
  }
  
  Future<void> _validateCache() async {
    try {
      // Cache metrics removed - using simple SharedPreferences caching
      _loadingStages['cache_validation'] = {
        'status': 'success',
        'metrics': {'cache_type': 'SharedPreferences'},
        'timestamp': DateTime.now(),
      };
    } catch (e) {
      _loadingStages['cache_validation'] = {
        'status': 'error',
        'error': e.toString(),
        'timestamp': DateTime.now(),
      };
    }
  }
  
  Future<void> _preloadData() async {
    try {
      // Preload common viewports
      // Preloading removed - using simple caching
      
      _loadingStages['data_preload'] = {
        'status': 'success',
        'timestamp': DateTime.now(),
      };
    } catch (e) {
      _loadingStages['data_preload'] = {
        'status': 'error',
        'error': e.toString(),
        'timestamp': DateTime.now(),
      };
    }
  }
  
  Future<void> _optimizePerformance() async {
    try {
      // Track memory usage
      // Performance tracking removed - using simple state management
      
      // Clear old performance data
      // Performance data clearing removed
      
      _loadingStages['performance_optimization'] = {
        'status': 'success',
        'timestamp': DateTime.now(),
      };
    } catch (e) {
      _loadingStages['performance_optimization'] = {
        'status': 'error',
        'error': e.toString(),
        'timestamp': DateTime.now(),
      };
    }
  }
  
  Future<void> _navigateToMainApp() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Initialize authentication state
      await authProvider.initializeAuth();
      
      // Navigate based on authentication status
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => 
              authProvider.isLoggedIn ? const MainWrapper() : const LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    } catch (e) {
      print('Navigation error: $e');
      // Fallback navigation to login screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      }
    }
  }
  
  Future<void> _handleLoadingError(dynamic error) async {
    print('Loading error: $error');
    
    setState(() {
      _currentMessage = 'Loading failed. Retrying...';
    });
    
    // Retry after delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Navigate to login screen even if there's an error
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    }
  }
  
  void _updateProgress(double progress, String message) {
    if (mounted) {
      setState(() {
        _currentProgress = progress;
        _currentMessage = message;
      });
    }
  }
  
  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              const Color(0xFFF8F9FA),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with enhanced animations
              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoScale.value,
                    child: Transform.rotate(
                      angle: _logoRotation.value * 0.1, // Subtle rotation
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF20B2AA).withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/images/dhalogo.png',
                                width: 160,
                                height: 160,
                                fit: BoxFit.contain,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 20),
              
              // App Name with fade animation
              AnimatedBuilder(
                animation: _textFade,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _textFade,
                    child: Column(
                      children: [
                        Text(
                          'DHA Marketplace',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E3C90),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Premium Property Solutions',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 60),
              
              // Enhanced loading indicator
              AnimatedBuilder(
                animation: _progressFade,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _progressFade,
                    child: Column(
                      children: [
                        // Progress bar
                        Container(
                          width: 280,
                          height: 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: Colors.grey[200],
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 280 * _currentProgress,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1E3C90), Color(0xFF20B2AA)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Loading message
                        Text(
                          _currentMessage,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Progress percentage
                        Text(
                          '${(_currentProgress * 100).toInt()}%',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: const Color(0xFF20B2AA),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Loading spinner
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF20B2AA)),
                            strokeWidth: 2.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 40),
              
              // Loading stages indicator
              if (_loadingStages.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Loading Progress',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._loadingStages.entries.map((entry) => 
                        _buildStageIndicator(entry.key, entry.value)
                      ).toList(),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStageIndicator(String stage, Map<String, dynamic> data) {
    final isSuccess = data['status'] == 'success';
    final isError = data['status'] == 'error';
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : 
            isError ? Icons.error : Icons.hourglass_empty,
            size: 14,
            color: isSuccess ? Colors.green : 
                   isError ? Colors.red : Colors.orange,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getStageDisplayName(stage),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: isSuccess ? Colors.green[700] : 
                       isError ? Colors.red[700] : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _getStageDisplayName(String stage) {
    switch (stage) {
      case 'cache_validation': return 'Cache validation';
      case 'data_preload': return 'Data preloading';
      case 'performance_optimization': return 'Performance optimization';
      default: return stage;
    }
  }
}
