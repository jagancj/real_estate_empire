import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_estate_empire/app.dart';
import 'dart:async';
import '../providers/game_provider.dart';
import '../widgets/common/currency_display.dart';
import '../widgets/common/progress_bar.dart';
import '../widgets/property/income_collector.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Timer? _gameLoopTimer;
  
  @override
  void initState() {
    super.initState();
    // Set up game loop timer (update every second)
    _gameLoopTimer = Timer.periodic(const Duration(seconds: 1), _gameLoop);
  }
  
  @override
  void dispose() {
    _gameLoopTimer?.cancel();
    super.dispose();
  }
  
  void _gameLoop(Timer timer) {
    // Update game state
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    gameProvider.gameLoop();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real Estate Empire'),
        elevation: 0,
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          final stats = gameProvider.getPlayerStats();
          
          return RefreshIndicator(
            onRefresh: () async {
              // Refresh game state
              await gameProvider.gameLoop();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPlayerInfoCard(stats),
                  const SizedBox(height: 16),
                  _buildIncomeCollector(context, gameProvider, stats),
                  const SizedBox(height: 16),
                  _buildPortfolioSummary(stats),
                  const SizedBox(height: 16),
                  _buildQuickActions(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildPlayerInfoCard(Map<String, dynamic> stats) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  radius: 24,
                  child: const Text(
                    'RE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Real Estate Mogul',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        'Level ${stats['level']}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                CurrencyDisplay(
                  amount: stats['cash'],
                  fontSize: 18,
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomProgressBar(
              current: stats['experience'].toDouble(),
              max: stats['nextLevelExp'].toDouble(),
              label: 'Experience',
              showPercentage: true,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildIncomeCollector(
    BuildContext context, 
    GameProvider gameProvider,
    Map<String, dynamic> stats,
  ) {
    return IncomeCollector(
      pendingIncome: stats['pendingIncome'],
      onCollect: () async {
        final income = await gameProvider.collectAllIncome();
        if (income > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Collected \$${income.toStringAsFixed(2)} in rent!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
    );
  }
  
  Widget _buildPortfolioSummary(Map<String, dynamic> stats) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Portfolio Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildStatsRow(
              'Net Worth',
              '\$${stats['netWorth'].toStringAsFixed(0)}',
              'Daily Income',
              '\$${stats['dailyIncome'].toStringAsFixed(2)}',
            ),
            const Divider(height: 24),
            _buildStatsRow(
              'Properties',
              '${stats['properties']}',
              'Buildings',
              '${stats['buildings']}',
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatsRow(
    String label1, 
    String value1, 
    String label2, 
    String value2,
  ) {
    return Row(
      children: [
       Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label2,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value2,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // Update the _buildQuickActions method in dashboard_screen.dart:

Widget _buildQuickActions(BuildContext context) {
  return Card(
    elevation: 3,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.5,
            children: [
              _buildActionButton(
                context: context,
                icon: Icons.store,
                label: 'Buy Property',
                onTap: () {
                  // Use a different approach to navigate
                  final navState = context.findAncestorStateOfType<MainNavigationScreenState>();
                  if (navState != null) {
                    navState.setCurrentIndex(2); // Market tab index
                  }
                },
              ),
              _buildActionButton(
                context: context,
                icon: Icons.home_work,
                label: 'My Properties',
                onTap: () {
                  final navState = context.findAncestorStateOfType<MainNavigationScreenState>();
                  if (navState != null) {
                    navState.setCurrentIndex(1); // Properties tab index
                  }
                },
              ),
              _buildActionButton(
                context: context,
                icon: Icons.construction,
                label: 'Develop Land',
                onTap: () {
                  final navState = context.findAncestorStateOfType<MainNavigationScreenState>();
                  if (navState != null) {
                    navState.setCurrentIndex(3); // Develop tab index
                  }
                },
              ),
              _buildActionButton(
                context: context,
                icon: Icons.bar_chart,
                label: 'Statistics',
                onTap: () {
                  final navState = context.findAncestorStateOfType<MainNavigationScreenState>();
                  if (navState != null) {
                    navState.setCurrentIndex(4); // Profile tab index
                  }
                },
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
  
  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}