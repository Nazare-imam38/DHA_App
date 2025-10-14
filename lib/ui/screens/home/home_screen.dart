import 'package:flutter/material.dart';
import 'responsive_home_screen.dart';

/// HomeScreen that now uses responsive design
class HomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToProjects;
  
  const HomeScreen({super.key, this.onNavigateToProjects});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// Responsive HomeScreen wrapper that uses the responsive implementation
class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveHomeScreen(
      onNavigateToProjects: widget.onNavigateToProjects,
    );
  }
}