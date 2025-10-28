import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/enhanced_auth_provider.dart';
import '../../../services/biometric_service.dart';
import 'biometric_login_screen.dart';
import 'enhanced_login_screen.dart';
import '../home/home_screen.dart';
import '../../../screens/main_wrapper.dart';

/// Enhanced splash screen with comprehensive biometric authentication flow
class EnhancedSplashScreen extends StatefulWidget {
  const EnhancedSplashScreen({super.key});

  @override
  State<EnhancedSplashScreen> createState() => _EnhancedSplashScreenState();
}

class _EnhancedSplashScreenState extends State<EnhancedSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeAuth();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  Future<void> _initializeAuth() async {
    try {
      // Wait for animation to complete
      await Future.delayed(const Duration(milliseconds: 1500));
      
      // Initialize authentication
      final authProvider = Provider.of<EnhancedAuthProvider>(
        context,
        listen: false,
      );
      
      await authProvider.initializeAuth();
      
      // Navigate based on authentication state
      if (mounted) {
        _navigateBasedOnAuthState(authProvider);
      }
    } catch (e) {
      if (mounted) {
        _navigateToLogin();
      }
    }
  }

  void _navigateBasedOnAuthState(EnhancedAuthProvider authProvider) {
    // Check if user is logged in
    if (authProvider.isLoggedIn) {
      // Check if biometric is available and enabled
      if (authProvider.canUseBiometric) {
        _navigateToBiometricLogin();
      } else {
        _navigateToHome();
      }
    } else {
      // Check if biometric setup is required
      if (authProvider.biometricSetupRequired) {
        _navigateToBiometricSetup();
      } else {
        _navigateToLogin();
      }
    }
  }

  void _navigateToBiometricLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const BiometricLoginScreen(),
      ),
    );
  }

  void _navigateToBiometricSetup() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const EnhancedLoginScreen(showBiometricSetup: true),
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const EnhancedLoginScreen(),
      ),
    );
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const MainWrapper(initialTabIndex: 0),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Consumer<EnhancedAuthProvider>(
        builder: (context, authProvider, child) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.security,
                            size: 60,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 40),
                
                // App Title
                AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        'DHA Marketplace',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 10),
                
                // Subtitle
                AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        'Secure Property Marketplace',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 60),
                
                // Loading Indicator
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _getLoadingMessage(authProvider),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 40),
                
                // Biometric Status (if available)
                if (authProvider.biometricStatus != null)
                  AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildBiometricStatus(authProvider.biometricStatus!),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getLoadingMessage(EnhancedAuthProvider authProvider) {
    if (authProvider.isLoading) {
      return 'Initializing secure authentication...';
    }
    
    if (authProvider.isLoggedIn) {
      if (authProvider.canUseBiometric) {
        return 'Preparing biometric authentication...';
      } else {
        return 'Loading your dashboard...';
      }
    } else {
      return 'Setting up secure environment...';
    }
  }

  Widget _buildBiometricStatus(BiometricStatus biometricStatus) {
    IconData icon;
    Color color;
    String message;

    if (biometricStatus.canUseBiometric) {
      icon = Icons.fingerprint;
      color = Colors.green;
      message = 'Biometric authentication ready';
    } else if (!biometricStatus.isAvailable) {
      icon = Icons.fingerprint;
      color = Colors.orange;
      message = 'Biometric authentication not available';
    } else if (!biometricStatus.isEnabled) {
      icon = Icons.fingerprint;
      color = Colors.orange;
      message = 'Biometric authentication available';
    } else if (biometricStatus.isLockedOut) {
      icon = Icons.lock;
      color = Colors.red;
      message = 'Biometric authentication locked';
    } else {
      icon = Icons.error;
      color = Colors.red;
      message = 'Biometric authentication error';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Text(
            message,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
