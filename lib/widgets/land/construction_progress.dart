import 'package:flutter/material.dart';
import '../../models/building_model.dart';
import '../common/progress_bar.dart';

class ConstructionProgress extends StatelessWidget {
  final Building building;
  final VoidCallback? onComplete;
  
  const ConstructionProgress({
    super.key,
    required this.building,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isComplete = building.status == BuildingStatus.complete;
    final bool isUnderConstruction = building.status == BuildingStatus.underConstruction;
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isComplete ? Colors.green[100] : Colors.amber[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isComplete ? Icons.check_circle : Icons.construction,
                    color: isComplete ? Colors.green[800] : Colors.amber[800],
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isComplete ? 'Construction Complete' : 'Construction Progress',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        building.name,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Progress bar
            if (isUnderConstruction)
              CustomProgressBar(
                current: building.completionPercentage.toDouble(),
                max: 100,
                label: 'Construction',
                showPercentage: true,
                barColor: Colors.amber,
              ),
            
            // Time remaining
            if (isUnderConstruction) ...[
              const SizedBox(height: 12),
              _buildTimeRemaining(context),
            ],
            
            // Complete button
            if (isComplete && onComplete != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Find Tenants',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildTimeRemaining(BuildContext context) {
    if (building.completionPercentage >= 100) {
      return Container(); // No time remaining
    }
    
    final percentRemaining = 100 - building.completionPercentage;
    final hoursRemaining = (percentRemaining * building.constructionDurationHours / 100).round();
    
    String timeText;
    if (hoursRemaining < 1) {
      timeText = 'Less than an hour remaining';
    } else if (hoursRemaining == 1) {
      timeText = '1 hour remaining';
    } else if (hoursRemaining < 24) {
      timeText = '$hoursRemaining hours remaining';
    } else {
      final days = (hoursRemaining / 24).floor();
      final hours = hoursRemaining % 24;
      if (hours == 0) {
        timeText = '$days days remaining';
      } else {
        timeText = '$days days, $hours hours remaining';
      }
    }
    
    return Row(
      children: [
        Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          timeText,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}