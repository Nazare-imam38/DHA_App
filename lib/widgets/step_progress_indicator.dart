import 'package:flutter/material.dart';

class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepNames;
  
  const StepProgressIndicator({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepNames,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Progress Bar
          Row(
            children: List.generate(totalSteps, (index) {
              final stepNumber = index + 1;
              final isCompleted = stepNumber < currentStep;
              final isCurrent = stepNumber == currentStep;
              
              return Expanded(
                child: Row(
                  children: [
                    // Step Circle
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isCompleted || isCurrent 
                          ? Colors.blue[600] 
                          : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted
                          ? Icon(Icons.check, color: Colors.white, size: 16)
                          : Text(
                              stepNumber.toString(),
                              style: TextStyle(
                                color: isCurrent ? Colors.white : Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      ),
                    ),
                    
                    // Connector Line
                    if (stepNumber < totalSteps)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isCompleted ? Colors.blue[600] : Colors.grey[300],
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          
          SizedBox(height: 16),
          
          // Current Step Name
          Text(
            stepNames[currentStep - 1],
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
        ],
      ),
    );
  }
}
