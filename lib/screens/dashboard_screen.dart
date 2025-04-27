import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';
import '../providers/game_provider.dart';
import '../app.dart';
import '../models/property_model.dart';
import '../widgets/common/currency_display.dart';
import '../widgets/common/progress_bar.dart';
import '../widgets/property/income_collector.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  Timer? _gameLoopTimer;
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    // Set up game loop timer (update every second)
    _gameLoopTimer = Timer.periodic(const Duration(seconds: 1), _gameLoop);
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _gameLoopTimer?.cancel();
    _tabController.dispose();
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Portfolio'),
            Tab(text: 'Finance'),
          ],
        ),
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          final stats = gameProvider.getPlayerStats();
          
          return TabBarView(
            controller: _tabController,
            children: [
              // Overview Tab
              _buildOverviewTab(context, gameProvider, stats),
              
              // Portfolio Tab
              _buildPortfolioTab(context, gameProvider, stats),
              
              // Finance Tab
              _buildFinanceTab(context, gameProvider, stats),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildOverviewTab(BuildContext context, GameProvider gameProvider, Map<String, dynamic> stats) {
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh game state
        await gameProvider.gameLoop();
      },
      child: ListView(  // Changed from SingleChildScrollView to ListView
        padding: const EdgeInsets.all(16),
        children: [
          _buildCreditCardWidget(stats),
          const SizedBox(height: 16),
          _buildIncomeCollector(context, gameProvider, stats),
          const SizedBox(height: 16),
          _buildPlayerStatsSection(stats),
          const SizedBox(height: 16),
          _buildQuickActions(context),
          // Add some bottom padding for scrolling
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCreditCardWidget(Map<String, dynamic> stats) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade800,
            Colors.blue.shade500,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // World map pattern (you can replace with an actual asset or omit)
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Container(
                color: Colors.white.withOpacity(0.1),
                // If you have a world map asset, use this instead:
                // child: Image.asset(
                //   'assets/images/world_map_dots.png',
                //   fit: BoxFit.cover,
                // ),
              ),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row with bank icon and level
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.account_balance,
                          color: Colors.white,
                          size: 28,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'CENTRAL BANK',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Level ${stats['level']}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Cash balance
                const Text(
                  'Available Balance',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                CurrencyDisplay(
                  amount: stats['cash'],
                  fontSize: 36,
                  color: Colors.white,
                ),
                
                const Spacer(),
                
                // Net worth
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Net Worth',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        CurrencyDisplay(
                          amount: stats['netWorth'],
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Daily Income',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        CurrencyDisplay(
                          amount: stats['dailyIncome'],
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Collected \$${income.toStringAsFixed(2)} in rent!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      },
    );
  }
  
  Widget _buildPlayerStatsSection(Map<String, dynamic> stats) {
    final totalAssets = stats['netWorth'] - stats['cash'];
    final dailyROI = totalAssets > 0 ? stats['dailyIncome'] / totalAssets * 100 : 0;
    
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Portfolio Stats',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Level and experience
            const Text(
              'Experience Progress',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            CustomProgressBar(
              current: stats['experience'].toDouble(),
              max: stats['nextLevelExp'].toDouble(),
              label: 'Level ${stats["level"]} Progress',
              showPercentage: true,
              barColor: Colors.amber,
            ),
            const SizedBox(height: 16),
            
            // Portfolio status
            SizedBox(  // Wrap in SizedBox to control height
              height: 60,  // Set a fixed height
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Properties',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '${stats['properties']}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Buildings',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '${stats['buildings']}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ROI',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '${dailyROI.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickActions(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Use a SizedBox with a fixed height to prevent overflow
            SizedBox(
              height: 170,  // Adjust based on your needs
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),  // Disable scrolling
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.5,
                children: [
                  _buildActionButton(
                    context: context,
                    icon: Icons.store,
                    label: 'Buy Property',
                    color: Colors.blue,
                    onTap: () {
                      navigationKey.currentState?.setCurrentIndex(2); // Market tab index
                    },
                  ),
                  _buildActionButton(
                    context: context,
                    icon: Icons.home_work,
                    label: 'My Properties',
                    color: Colors.green,
                    onTap: () {
                      navigationKey.currentState?.setCurrentIndex(1); // Properties tab index
                    },
                  ),
                  _buildActionButton(
                    context: context,
                    icon: Icons.construction,
                    label: 'Develop Land',
                    color: Colors.orange,
                    onTap: () {
                      navigationKey.currentState?.setCurrentIndex(3); // Develop tab index
                    },
                  ),
                  _buildActionButton(
                    context: context,
                    icon: Icons.account_balance,
                    label: 'Get Loan',
                    color: Colors.purple,
                    onTap: () {
                      _tabController.animateTo(2); // Switch to Finance tab
                    },
                  ),
                ],
              ),
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
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: color.withOpacity(0.8),
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

  // Portfolio Tab
  Widget _buildPortfolioTab(BuildContext context, GameProvider gameProvider, Map<String, dynamic> stats) {
    return ListView(  // Changed from SingleChildScrollView to ListView
      padding: const EdgeInsets.all(16),
      children: [
        _buildPortfolioSummary(stats),
        const SizedBox(height: 16),
        _buildAssetBreakdown(gameProvider),
        const SizedBox(height: 16),
        _buildTopPerformers(gameProvider),
        // Add some bottom padding for scrolling
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildPortfolioSummary(Map<String, dynamic> stats) {
    final totalAssets = stats['netWorth'] - stats['cash'];
    final cashPercentage = stats['netWorth'] > 0 ? (stats['cash'] / stats['netWorth'] * 100) : 0;
    final assetsPercentage = stats['netWorth'] > 0 ? (totalAssets / stats['netWorth'] * 100) : 0;
    
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Portfolio Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: cashPercentage.round(),
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.horizontal(
                        left: const Radius.circular(15),
                        right: Radius.circular(cashPercentage > 95 ? 15 : 0),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      cashPercentage > 15 ? 'Cash' : '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: assetsPercentage.round(),
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(cashPercentage < 5 ? 15 : 0),
                        right: const Radius.circular(15),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      assetsPercentage > 15 ? 'Assets' : '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Cash',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      CurrencyDisplay(
                        amount: stats['cash'],
                        fontSize: 16,
                      ),
                      Text(
                        '${cashPercentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Assets',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      CurrencyDisplay(
                        amount: totalAssets,
                        fontSize: 16,
                      ),
                      Text(
                        '${assetsPercentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetBreakdown(GameProvider gameProvider) {
    final properties = gameProvider.propertyProvider.ownedProperties;
    final buildings = gameProvider.propertyProvider.buildings;
    final land = gameProvider.propertyProvider.ownedLand;
    
    // Calculate total value of each category
    double propertyValue = 0;
    for (var property in properties) {
      propertyValue += property.currentValue;
    }
    
    double buildingValue = 0;
    for (var building in buildings) {
      buildingValue += building.currentValue;
    }
    
    double landValue = 0;
    for (var parcel in land) {
      landValue += parcel.currentValue;
    }
    
    final totalAssetValue = propertyValue + buildingValue + landValue;
    
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Asset Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildAssetTypeRow(
              label: 'Properties',
              icon: Icons.home,
              color: Colors.blue,
              count: properties.length,
              value: propertyValue,
              percentage: totalAssetValue > 0 ? (propertyValue / totalAssetValue * 100) : 0,
            ),
            const SizedBox(height: 12),
            _buildAssetTypeRow(
              label: 'Buildings',
              icon: Icons.business,
              color: Colors.purple,
              count: buildings.length,
              value: buildingValue,
              percentage: totalAssetValue > 0 ? (buildingValue / totalAssetValue * 100) : 0,
            ),
            const SizedBox(height: 12),
            _buildAssetTypeRow(
              label: 'Land',
              icon: Icons.landscape,
              color: Colors.green,
              count: land.length,
              value: landValue,
              percentage: totalAssetValue > 0 ? (landValue / totalAssetValue * 100) : 0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetTypeRow({
    required String label,
    required IconData icon,
    required Color color,
    required int count,
    required double value,
    required double percentage,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'x$count',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CurrencyDisplay(
                    amount: value,
                    fontSize: 14,
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopPerformers(GameProvider gameProvider) {
    final properties = gameProvider.propertyProvider.ownedProperties
        .where((p) => p.status == PropertyStatus.occupied)
        .toList();
    
    // Sort by ROI (daily rent / current value)
    properties.sort((a, b) {
      final roiA = a.currentRent / a.currentValue;
      final roiB = b.currentRent / b.currentValue;
      return roiB.compareTo(roiA); // Descending order
    });
    
    // Take top 3 or less
    final topProperties = properties.take(3).toList();
    
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Performers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (topProperties.isEmpty) ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: 40,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No occupied properties yet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Purchase properties and find tenants to see your top performers.',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              ...topProperties.map((property) {
                final roi = (property.currentRent * 365 / property.currentValue) * 100;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[200],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            property.imageAsset,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              property.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              _getPropertyTypeString(property.type),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          CurrencyDisplay(
                            amount: property.currentRent,
                            fontSize: 16,
                            color: Colors.green[700],
                          ),
                          Text(
                            'ROI: ${roi.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  // Finance Tab
  Widget _buildFinanceTab(BuildContext context, GameProvider gameProvider, Map<String, dynamic> stats) {
    // This is a mock implementation that would need to be connected to actual loan data
    // Assume we have a list of banks with loan offers and active loans
    final List<Map<String, dynamic>> bankOffers = [
      {
        'name': 'First National Bank',
        'logo': Icons.account_balance, // Using icon instead of asset for simplicity
        'maxAmount': 100000.0,
        'interestRate': 5.0,
        'term': 12, // months
        'color': Colors.blue,
      },
      {
        'name': 'Central Investment',
        'logo': Icons.business, // Using icon instead of asset for simplicity
        'maxAmount': 250000.0,
        'interestRate': 7.5,
        'term': 24, // months
        'color': Colors.purple,
      },
      {
        'name': 'Fortune Finance',
        'logo': Icons.attach_money, // Using icon instead of asset for simplicity
        'maxAmount': 500000.0,
        'interestRate': 10.0,
        'term': 36, // months
        'color': Colors.green,
      },
    ];
    
    // Mock active loans
    final List<Map<String, dynamic>> activeLoans = [];
    
    return ListView(  // Changed from SingleChildScrollView to ListView
      padding: const EdgeInsets.all(16),
      children: [
        _buildLoanSummary(activeLoans),
        const SizedBox(height: 16),
        _buildLoanOffers(context, bankOffers, stats['netWorth']),
        if (activeLoans.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildActiveLoans(context, activeLoans),
        ],
        // Add some bottom padding for scrolling
        const SizedBox(height: 40),
      ],
    );
  }
  
  Widget _buildLoanSummary(List<Map<String, dynamic>> activeLoans) {
    // Calculate total debt
    double totalDebt = 0;
    double monthlyPayment = 0;
    
    for (var loan in activeLoans) {
      totalDebt += loan['remainingAmount'] as double;
      monthlyPayment += loan['monthlyPayment'] as double;
    }
    
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Finance Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (activeLoans.isEmpty) ...[
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.account_balance,
                      size: 48,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Active Loans',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Apply for a loan to grow your real estate empire faster.',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Debt',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        CurrencyDisplay(
                          amount: totalDebt,
                          fontSize: 24,
                          color: Colors.red[700],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Monthly Payment',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        CurrencyDisplay(
                          amount: monthlyPayment,
                          fontSize: 24,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: 0.3, // This would be calculated based on income vs debt ratio
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
              const SizedBox(height: 8),
              Text(
                'Debt-to-Income Ratio: 30%',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildLoanOffers(BuildContext context, List<Map<String, dynamic>> bankOffers, double netWorth) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available Loans',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Apply for a loan to expand your real estate portfolio',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ...bankOffers.map((offer) => _buildBankOfferCard(context, offer, netWorth)).toList(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBankOfferCard(
    BuildContext context, 
    Map<String, dynamic> offer,
    double netWorth,
  ) {
    // Calculate max loan amount for this player - lower of bank max or player qualification
    final double playerQualifiedAmount = netWorth * 0.7; // 70% of net worth
    final double maxLoanAmount = playerQualifiedAmount < offer['maxAmount'] 
      ? playerQualifiedAmount 
      : offer['maxAmount'];
    
    final Color bankColor = offer['color'] as Color;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: bankColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: bankColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    offer['logo'] as IconData,
                    color: bankColor,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  offer['name'] as String,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildOfferDetailItem(
                    'Max Loan',
                    CurrencyDisplay(
                      amount: maxLoanAmount,
                      fontSize: 16,
                    ),
                  ),
                ),
                Expanded(
                  child: _buildOfferDetailItem(
                    'Interest Rate',
                    Text(
                      '${offer['interestRate']}% APR',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _buildOfferDetailItem(
                    'Term',
                    Text(
                      '${offer['term']} months',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showLoanApplicationDialog(context, offer, maxLoanAmount);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: bankColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Apply for Loan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOfferDetailItem(String label, Widget value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        value,
      ],
    );
  }
  
  void _showLoanApplicationDialog(
    BuildContext context, 
    Map<String, dynamic> offer,
    double maxAmount,
  ) {
    double selectedAmount = maxAmount / 2; // Start with half the max
    
    // Calculate monthly payment
    double calculateMonthlyPayment(double principal, double annualRate, int months) {
      final monthlyRate = annualRate / 100 / 12;
      return principal * monthlyRate * (pow(1 + monthlyRate, months) / (pow(1 + monthlyRate, months) - 1));
    }
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final monthlyPayment = calculateMonthlyPayment(
              selectedAmount, 
              offer['interestRate'] as double, 
              offer['term'] as int,
            );
            
            final totalCost = monthlyPayment * (offer['term'] as int);
            final totalInterest = totalCost - selectedAmount;
            
            return AlertDialog(
              title: Text('Apply for Loan - ${offer['name']}'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Loan Amount',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: selectedAmount,
                      min: 1000,
                      max: maxAmount,
                      divisions: 20,
                      label: '\$${selectedAmount.round()}',
                      onChanged: (value) {
                        setState(() {
                          selectedAmount = value;
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Min'),
                        CurrencyDisplay(
                          amount: selectedAmount,
                          fontSize: 18,
                        ),
                        const Text('Max'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Loan terms
                    Text(
                      'Term: ${offer['term']} months',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Rate: ${offer['interestRate']}% APR',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    
                    // Payment info
                    const Text(
                      'Payment Summary',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Monthly Payment:'),
                        CurrencyDisplay(
                          amount: monthlyPayment,
                          fontSize: 16,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Cost:'),
                        CurrencyDisplay(
                          amount: totalCost,
                          fontSize: 16,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Interest:'),
                        CurrencyDisplay(
                          amount: totalInterest,
                          fontSize: 16,
                          color: Colors.red[700],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement loan acceptance logic with GameProvider
                    Navigator.of(context).pop();
                    // Show confirmation
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Loan approved for \$${selectedAmount.toStringAsFixed(2)}!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (offer['color'] as Color),
                  ),
                  child: const Text('Accept Loan'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  Widget _buildActiveLoans(BuildContext context, List<Map<String, dynamic>> activeLoans) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Active Loans',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...activeLoans.map((loan) => _buildActiveLoanCard(context, loan)).toList(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActiveLoanCard(BuildContext context, Map<String, dynamic> loan) {
    final remainingAmount = loan['remainingAmount'] as double;
    final originalAmount = loan['originalAmount'] as double;
    final progressPercentage = 1 - (remainingAmount / originalAmount);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loan['bankName'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[700],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Original Amount',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    CurrencyDisplay(
                      amount: originalAmount,
                      fontSize: 14,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Remaining Balance',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    CurrencyDisplay(
                      amount: remainingAmount,
                      fontSize: 14,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progressPercentage,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green[700]!),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(progressPercentage * 100).toStringAsFixed(1)}% Paid',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '${loan['remainingPayments']} payments left',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Payment',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    CurrencyDisplay(
                      amount: loan['monthlyPayment'] as double,
                      fontSize: 14,
                    ),
                  ],
                ),
                OutlinedButton(
                  onPressed: () {
                    // Show early payment dialog
                    _showEarlyPaymentDialog(context, loan);
                  },
                  child: const Text('Make Early Payment'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _showEarlyPaymentDialog(BuildContext context, Map<String, dynamic> loan) {
    final remainingAmount = loan['remainingAmount'] as double;
    double paymentAmount = remainingAmount * 0.1; // Default 10% of remaining
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Make Early Payment'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Remaining balance: ${CurrencyDisplay(amount: remainingAmount, fontSize: 16).toString()}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Payment Amount',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: paymentAmount,
                    min: remainingAmount * 0.05, // Min 5% payment
                    max: remainingAmount, // Max full payment
                    divisions: 20,
                    label: '\$${paymentAmount.round()}',
                    onChanged: (value) {
                      setState(() {
                        paymentAmount = value;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Min'),
                      CurrencyDisplay(
                        amount: paymentAmount,
                        fontSize: 18,
                      ),
                      const Text('Max'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    paymentAmount >= remainingAmount
                        ? 'This will pay off your loan completely!'
                        : 'This will reduce your remaining balance to ${CurrencyDisplay(amount: remainingAmount - paymentAmount, fontSize: 14).toString()}',
                    style: TextStyle(
                      color: paymentAmount >= remainingAmount ? Colors.green : Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement early payment logic
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Payment of \$${paymentAmount.toStringAsFixed(2)} applied!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Make Payment'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  String _getPropertyTypeString(PropertyType type) {
    switch (type) {
      case PropertyType.studioApartment:
        return 'Studio Apartment';
      case PropertyType.smallHouse:
        return 'Small House';
      case PropertyType.duplex:
        return 'Duplex';
      case PropertyType.smallOffice:
        return 'Office Space';
      case PropertyType.retailStore:
        return 'Retail Store';
    }
  }
}