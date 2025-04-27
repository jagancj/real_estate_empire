import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/game_provider.dart';
import 'providers/player_provider.dart';
import 'providers/property_provider.dart';
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
        ChangeNotifierProxyProvider2<PlayerProvider, PropertyProvider, GameProvider>(
          create: (context) => GameProvider(
            playerProvider: Provider.of<PlayerProvider>(context, listen: false),
            propertyProvider: Provider.of<PropertyProvider>(context, listen: false),
            databaseService: databaseService,
          ),
          update: (context, playerProvider, propertyProvider, previous) =>
            previous!..update(playerProvider, propertyProvider),
        ),
      ],
      child: const RealEstateEmpireApp(),
    ),
  );
}