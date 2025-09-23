import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import '../lib/ui/widgets/modern_filters_panel.dart';

void main() {
  group('Filter Tests', () {
    testWidgets('Filter panel initializes with correct default values', (WidgetTester tester) async {
      // Test that the filter panel initializes without errors
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ModernFiltersPanel(
              isVisible: true,
              onClose: () {},
              onFiltersChanged: (filters) {},
              initialFilters: {},
            ),
          ),
        ),
      );

      // Verify the widget builds without errors
      expect(find.byType(ModernFiltersPanel), findsOneWidget);
    });

    testWidgets('Price range slider has valid bounds', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ModernFiltersPanel(
              isVisible: true,
              onClose: () {},
              onFiltersChanged: (filters) {},
              initialFilters: {},
            ),
          ),
        ),
      );

      // Find the RangeSlider
      final rangeSlider = find.byType(RangeSlider);
      expect(rangeSlider, findsOneWidget);

      // Verify the slider has valid properties
      final slider = tester.widget<RangeSlider>(rangeSlider);
      expect(slider.min, equals(5475000));
      expect(slider.max, equals(565000000));
      expect(slider.values.start, greaterThanOrEqualTo(5475000));
      expect(slider.values.end, lessThanOrEqualTo(565000000));
    });

    testWidgets('Filter panel can be closed', (WidgetTester tester) async {
      bool isVisible = true;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return ModernFiltersPanel(
                  isVisible: isVisible,
                  onClose: () {
                    setState(() {
                      isVisible = false;
                    });
                  },
                  onFiltersChanged: (filters) {},
                  initialFilters: {},
                );
              },
            ),
          ),
        ),
      );

      // Find and tap the close button
      final closeButton = find.byIcon(Icons.close);
      expect(closeButton, findsOneWidget);
      
      await tester.tap(closeButton);
      await tester.pump();
    });
  });
}
