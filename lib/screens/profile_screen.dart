// screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/common/progress_bar.dart';
import '../widgets/common/currency_display.dart';
import '../models/game_constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          final stats = gameProvider.getPlayerStats();
          final unlockedFeatures = gameProvider.unlockedFeatures;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(stats),
                const SizedBox(height: 24),
                _buildPlayerStats(stats),
                const SizedBox(height: 24),
                _buildPortfolioSummary(stats),
                const SizedBox(height: 24),
                _buildFeatureUnlocks(unlockedFeatures),
                const SizedBox(height: 24),
                _buildAchievements(gameProvider),
                const SizedBox(height: 24),
                _buildSettings(context),
                const SizedBox(height: 80), // Bottom spacing
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildProfileHeader(Map<String, dynamic> stats) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  'RM',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Real Estate Mogul',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Level ${stats['level']}',
                          style: TextStyle(
                            color: Colors.amber[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Net Worth: ',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      CurrencyDisplay(
                        amount: stats['netWorth'],
                        compact: true,
                        fontSize: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CustomProgressBar(
                    current: stats['experience'].toDouble(),
                    max: stats['nextLevelExp'].toDouble(),
                    label: 'Experience',
                    showPercentage: true,
                    barColor: Colors.amber,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPlayerStats(Map<String, dynamic> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Player Stats'),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildStatRow(
                  'Cash',
                  CurrencyDisplay(
                    amount: stats['cash'],
                    fontSize: 16,
                  ),
                  'Daily Income',
                  CurrencyDisplay(
                    amount: stats['dailyIncome'],
                    fontSize: 16,
                    color: Colors.green[700],
                  ),
                ),
                const Divider(height: 24),
                _buildStatRow(
                  'Properties',
                  Text(
                    '${stats['properties']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  'Buildings',
                  Text(
                    '${stats['buildings']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildPortfolioSummary(Map<String, dynamic> stats) {
    // Calculate some financial stats
    final totalAssets = stats['netWorth'] - stats['cash'];
    final dailyROI = stats['dailyIncome'] / totalAssets * 100;
    final annualROI = dailyROI * 365;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Portfolio Summary'),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Annual ROI',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            totalAssets > 0 ? '${annualROI.toStringAsFixed(1)}%' : 'N/A',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Monthly Income',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          CurrencyDisplay(
                            amount: stats['dailyIncome'] * 30,
                            fontSize: 18,
                            color: Colors.green[700],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cash on Hand',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          CurrencyDisplay(
                            amount: stats['cash'],
                            fontSize: 18,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Asset Value',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          CurrencyDisplay(
                            amount: totalAssets,
                            fontSize: 18,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildFeatureUnlocks(Map<String, bool> unlockedFeatures) {
    final levelUnlocks = GameConstants.featureUnlockLevels;
    
    // Prepare sorted feature list
    final List<Map<String, dynamic>> featureList = [];
    for (final entry in levelUnlocks.entries) {
      final feature = entry.key;
      final level = entry.value;
      
      featureList.add({
        'feature': feature,
        'level': level,
        'unlocked': unlockedFeatures.containsKey(feature),
      });
    }
    
    // Sort by unlock level
    featureList.sort((a, b) => a['level'].compareTo(b['level']));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Feature Unlocks'),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: featureList.map((feature) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: feature['unlocked']
                              ? Colors.green[100]
                              : Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            feature['unlocked']
                                ? Icons.check
                                : Icons.lock,
                            size: 16,
                            color: feature['unlocked']
                                ? Colors.green[700]
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getFeatureName(feature['feature']),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: feature['unlocked']
                                    ? Colors.black
                                    : Colors.grey[600],
                              ),
                            ),
                            Text(
                              feature['unlocked']
                                  ? 'Unlocked'
                                  : 'Unlocks at Level ${feature['level']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: feature['unlocked']
                                    ? Colors.green[700]
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildAchievements(GameProvider gameProvider) {
    // For MVP, we'll just show placeholder achievements
    final List<Map<String, dynamic>> achievements = [
      {
        'name': 'First Property',
        'description': 'Purchase your first property',
        'completed': gameProvider.getPlayerStats()['properties'] > 0,
        'icon': Icons.home,
      },
      {
        'name': 'Developer',
        'description': 'Construct your first building',
        'completed': gameProvider.getPlayerStats()['buildings'] > 0,
        'icon': Icons.construction,
      },
      {
        'name': 'Investor',
        'description': 'Reach \$100k in net worth',
        'completed': gameProvider.getPlayerStats()['netWorth'] >= 100000,
        'icon': Icons.attach_money,
      },
      {
        'name': 'Passive Income',
        'description': 'Earn \$500 daily in rent',
        'completed': gameProvider.getPlayerStats()['dailyIncome'] >= 500,
        'icon': Icons.trending_up,
      },
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Achievements'),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: achievements.map((achievement) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: achievement['completed']
                              ? Colors.amber[100]
                              : Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          achievement['icon'],
                          color: achievement['completed']
                              ? Colors.amber[800]
                              : Colors.grey[500],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              achievement['name'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: achievement['completed']
                                    ? Colors.black
                                    : Colors.grey[600],
                              ),
                            ),
                            Text(
                              achievement['description'],
                              style: TextStyle(
                                fontSize: 14,
                                color: achievement['completed']
                                    ? Colors.black
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (achievement['completed'])
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Completed',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildSettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Settings'),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notifications'),
                trailing: Switch(
                  value: true, // Placeholder value
                  onChanged: (value) {
                    // Handle notification setting change
                  },
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.music_note),
                title: const Text('Sound Effects'),
                trailing: Switch(
                  value: true, // Placeholder value
                  onChanged: (value) {
                    // Handle sound setting change
                  },
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showAboutDialog(context);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.restore),
                title: const Text('Reset Game'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showResetConfirmation(context);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
  
  Widget _buildStatRow(
    String label1,
    Widget value1,
    String label2,
    Widget value2,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label1,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              value1,
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label2,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              value2,
            ],
          ),
        ),
      ],
    );
  }
  
  String _getFeatureName(String featureKey) {
    switch (featureKey) {
      case 'smallHouse':
        return 'Small Houses';
      case 'duplex':
        return 'Duplexes';
      case 'retailStore':
        return 'Retail Stores';
      case 'apartment':
        return 'Apartments';
      case 'officeBuilding':
        return 'Office Buildings';
      case 'landDevelopment':
        return 'Land Development';
      case 'customDesigns':
        return 'Custom Designs';
      case 'secondNeighborhood':
        return 'Second Neighborhood';
      default:
        return featureKey;
    }
  }
  
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Real Estate Empire'),
       // Continuing screens/profile_screen.dart
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Real Estate Empire v1.0.0'),
            const SizedBox(height: 16),
            const Text(
              'A real estate tycoon simulator where you can build your property empire from the ground up!',
              style: TextStyle(height: 1.5),
            ),
            const SizedBox(height: 16),
            const Text(
              '© 2025 Real Estate Empire',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Game'),
        content: const Text(
          'Are you sure you want to reset the game? This will delete all your progress and cannot be undone.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Implement game reset
              Navigator.of(context).pop();
              
              // Show confirmation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Game has been reset.'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}