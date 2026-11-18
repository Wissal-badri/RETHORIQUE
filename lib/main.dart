import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/data_service.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  await storageService.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<DataService>(create: (_) => DataService()),
        ChangeNotifierProvider<StorageService>.value(value: storageService),
      ],
      child: const RhetoriqueApp(),
    ),
  );
}

class RhetoriqueApp extends StatelessWidget {
  const RhetoriqueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rhétorique — L’art de Molière',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light, // Pas de mode sombre (thème clair classique permanent)
      home: const HomeScreen(),
    );
  }
}
