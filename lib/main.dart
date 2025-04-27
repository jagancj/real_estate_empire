import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/game_provider.dart';
import 'providers/player_provider.dart';
import 'providers/property_provider.dart';
import 'providers/loan_provider.dart'; // Add import for new provider
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Force portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize services
  final databaseService = DatabaseService();
  await databaseService.initialize();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlayerProvider(databaseService)),
        ChangeNotifierProvider(create: (_) => PropertyProvider(databaseService)),
        ChangeNotifierProvider(create: (_) => LoanProvider(databaseService)), // Add LoanProvider
        ChangeNotifierProxyProvider3<PlayerProvider, PropertyProvider, LoanProvider, GameProvider>(
          create: (context) => GameProvider(
            playerProvider: Provider.of<PlayerProvider>(context, listen: false),
            propertyProvider: Provider.of<PropertyProvider>(context, listen: false),
            loanProvider: Provider.of<LoanProvider>(context, listen: false), // Pass LoanProvider
            databaseService: databaseService,
          ),
          update: (context, playerProvider, propertyProvider, loanProvider, previous) =>
            previous!..update(playerProvider, propertyProvider, loanProvider),
        ),
      ],
      child: const RealEstateEmpireApp(),
    ),
  );
}