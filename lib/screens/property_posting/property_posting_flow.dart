import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/property_form_data.dart';
import 'steps/owner_details_step.dart';
import 'steps/purpose_selection_step.dart';
import 'steps/type_pricing_step.dart';
import 'steps/property_details_step.dart';
import 'steps/location_details_step.dart';
import 'steps/unit_details_step.dart';
import 'steps/payment_method_step.dart';
import 'steps/media_upload_step.dart';
import 'steps/amenities_selection_step.dart';
import '../../services/property_service.dart';
import '../../widgets/step_progress_indicator.dart';
import '../ownership_selection_screen.dart';

class PropertyPostingFlow extends StatefulWidget {
  @override
  _PropertyPostingFlowState createState() => _PropertyPostingFlowState();
}

class _PropertyPostingFlowState extends State<PropertyPostingFlow> {
  int currentStep = 1;
  final PageController pageController = PageController();
  
  // UPDATED STEP ORDER - Owner Details moved to Step 2
  final List<Widget> steps = [
    OwnerDetailsStep(), // MOVED TO STEP 2
    PurposeSelectionStep(),
    TypePricingStep(),
    PropertyDetailsStep(),
    LocationDetailsStep(),
    UnitDetailsStep(),
    PaymentMethodStep(),
    MediaUploadStep(),
    AmenitiesSelectionStep(),
  ];
  
  final List<String> stepNames = [
    'Owner Details', // MOVED TO STEP 2
    'Purpose',
    'Type & Pricing',
    'Details',
    'Location',
    'Unit',
    'Payment',
    'Media',
    'Amenities',
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Post Your Property'),
          leading: currentStep > 1 
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => _previousStep(),
              )
            : null,
        ),
        body: Column(
          children: [
            
            // Step Content
            Expanded(
              child: PageView.builder(
                controller: pageController,
                physics: NeverScrollableScrollPhysics(),
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  return steps[index];
                },
              ),
            ),
            
            // Navigation Buttons
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (currentStep > 1)
                    ElevatedButton(
                      onPressed: _previousStep,
                      child: Text('Back'),
                    ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: _canProceed() ? _nextStep : null,
                    child: Text(currentStep == steps.length ? 'Submit' : 'Continue'),
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }
  
  bool _canProceed() {
    final formData = context.read<PropertyFormData>();
    return formData.isStepValid(currentStep);
  }
  
  void _nextStep() {
    if (currentStep < steps.length) {
      setState(() {
        currentStep++;
      });
      pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitProperty();
    }
  }
  
  void _previousStep() {
    if (currentStep > 1) {
      setState(() {
        currentStep--;
      });
      pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  void _submitProperty() async {
    try {
      final formData = context.read<PropertyFormData>();
      final propertyService = PropertyService();
      final result = await propertyService.createProperty(formData);
      
      if (result['success']) {
        _showSuccessDialog(result);
      } else {
        _showErrorDialog(result['message']);
      }
    } catch (e) {
      _showErrorDialog('Failed to create property: $e');
    }
  }
  
  void _showSuccessDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Property Created Successfully'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Property ID: ${result['data']['id']}'),
            Text('PSID: ${result['data']['psid']}'),
            Text('Property Fee: ${result['data']['property_fee']}'),
            Text('Challan Due Date: ${result['data']['challan_due_date']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
  
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
