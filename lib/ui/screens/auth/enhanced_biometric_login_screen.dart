import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/enhanced_biometric_auth_provider.dart';
import '../../models/biometric_auth_state.dart';
import 'enhanced_login_screen.dart';
import '../home/home_screen.dart';
import '../../screens/main_wrapper.dart';

/// Enhanced biometric login screen with comprehensive error handling and fallback options
class EnhancedBiometricLoginScreen extends StatefulWidget {
  const EnhancedBiometricLoginScreen({super.key});

  @override
  State<EnhancedBiometricLoginScreen> createState() => _EnhancedBiometricLoginScreenState();
}

class _EnhancedBiometricLoginScreenState extends State<EnhancedBiometricLoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  bool _isAuthenticating = false;
  String? _errorMessage;
  int _retryCount = 0;
  static const int maxRetries = 3;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startBiometricAuthentication();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  Future<void> _startBiometricAuthentication() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      await _authenticateWithBiometric();
    }
  }

  Future<void> _authenticateWithBiometric() async {
    if (_isAuthenticating) return;
    
    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<EnhancedBiometricAuthProvider>(
        context,
        listen: false,
      );

      final result = await authProvider.loginWithBiometric();

      if (result.success) {
        _navigateToHome();
      } else {
        setState(() {
          _errorMessage = result.error;
          _retryCount++;
        });

        if (result.requiresPassword) {
          _navigateToPasswordLogin();
        } else if (_retryCount < maxRetries) {
          // Show retry option
          _showRetryDialog();
        } else {
          _navigateToPasswordLogin();
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Biometric authentication failed: $e';
        _retryCount++;
      });

      if (_retryCount < maxRetries) {
        _showRetryDialog();
      } else {
        _navigateToPasswordLogin();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const MainWrapper(initialTabIndex: 0),
      ),
    );
  }

  void _navigateToPasswordLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const EnhancedLoginScreen(),
      ),
    );
  }

  void _showRetryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Authentication Failed'),
        content: Text(_errorMessage ?? 'Biometric authentication failed. Would you like to try again?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToPasswordLogin();
            },
            child: const Text('Use Password'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _authenticateWithBiometric();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: Consumer<EnhancedBiometricAuthProvider>(
          builder: (context, authProvider, child) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  
                  // Header
                  _buildHeader(),
                  
                  const Spacer(),
                  
                  // Biometric Authentication UI
                  _buildBiometricAuthUI(authProvider),
                  
                  const Spacer(),
                  
                  // Fallback Options
                  _buildFallbackOptions(),
                  
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              Text(
                'Welcome Back',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Use your biometric to continue',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBiometricAuthUI(EnhancedBiometricAuthProvider authProvider) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              children: [
                // Biometric Icon
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _isAuthenticating ? _pulseAnimation.value : 1.0,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(60),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          _getBiometricIcon(authProvider.biometricState),
                          size: 60,
                          color: _getBiometricColor(authProvider.biometricState),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 30),
                
                // Status Message
                Text(
                  _getStatusMessage(authProvider.biometricState),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 20),
                
                // Loading Indicator
                if (_isAuthenticating) ...[
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Authenticating...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
                
                // Error Message
                if (_errorMessage != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFallbackOptions() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Use Password Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _navigateToPasswordLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Use Password Instead',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Help Button
              TextButton(
                onPressed: _showHelpDialog,
                child: Text(
                  'Need Help?',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getBiometricIcon(BiometricAuthStateModel biometricState) {
    switch (biometricState.state) {
      case BiometricAuthState.available:
        return Icons.fingerprint;
      case BiometricAuthState.disabled:
        return Icons.fingerprint;
      case BiometricAuthState.locked:
        return Icons.lock;
      case BiometricAuthState.error:
        return Icons.error;
      default:
        return Icons.security;
    }
  }

  Color _getBiometricColor(BiometricAuthStateModel biometricState) {
    switch (biometricState.state) {
      case BiometricAuthState.available:
        return Colors.green;
      case BiometricAuthState.disabled:
        return Colors.orange;
      case BiometricAuthState.locked:
        return Colors.red;
      case BiometricAuthState.error:
        return Colors.red;
      default:
        return Colors.white;
    }
  }

  String _getStatusMessage(BiometricAuthStateModel biometricState) {
    if (_isAuthenticating) {
      return 'Authenticating with ${biometricState.biometricTypeDisplayName}...';
    }
    
    return biometricState.detailedStatusMessage;
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Biometric Authentication Help'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('If you\'re having trouble with biometric authentication:'),
            SizedBox(height: 16),
            Text('• Make sure your fingerprint/face is clean and dry'),
            Text('• Try positioning your finger/face correctly'),
            Text('• Use the password option if biometrics aren\'t working'),
            Text('• Check that biometric authentication is enabled in device settings'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
