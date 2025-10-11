import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'projects_screen_instant.dart';
import 'projects_screen_pure_tileserver.dart';

/// Test screen that allows switching between GeoJSON and Tileserver implementations
class ProjectsScreenTest extends StatefulWidget {
  const ProjectsScreenTest({super.key});

  @override
  State<ProjectsScreenTest> createState() => _ProjectsScreenTestState();
}

class _ProjectsScreenTestState extends State<ProjectsScreenTest> {
  bool _useTileserver = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: Stack(
        children: [
          // Show the appropriate implementation
          if (_useTileserver)
            const ProjectsScreenPureTileserver()
          else
            const ProjectsScreenInstant(),
          
          // Toggle button
          Positioned(
            top: 50,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _useTileserver = !_useTileserver;
                });
              },
              backgroundColor: _useTileserver ? Colors.blue : Colors.green,
              child: Icon(
                _useTileserver ? Icons.cloud : Icons.storage,
                color: Colors.white,
              ),
              tooltip: _useTileserver ? 'Switch to GeoJSON' : 'Switch to Tileserver',
            ),
          ),
          
          // Info banner
          Positioned(
            top: 16,
            left: 16,
            right: 80,
            child: Card(
              color: _useTileserver ? Colors.blue.withOpacity(0.9) : Colors.green.withOpacity(0.9),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      _useTileserver ? Icons.cloud : Icons.storage,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _useTileserver 
                              ? 'Using Tileserver (MBTiles)' 
                              : 'Using GeoJSON (Local Assets)',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _useTileserver 
                              ? 'localhost:8090 - Real-time boundaries' 
                              : 'assets/ - Static GeoJSON files',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
