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
    RhetoriqueApp(storageService: storageService),
  );
}

class RhetoriqueApp extends StatelessWidget {
  final StorageService? storageService;
  final DataService? dataService;

  const RhetoriqueApp({
    super.key,
    this.storageService,
    this.dataService,
  });

  @override
  Widget build(BuildContext context) {
    final storage = storageService ?? StorageService();
    final data = dataService ?? DataService();

    return MultiProvider(
      providers: [
        Provider<DataService>.value(value: data),
        ChangeNotifierProvider<StorageService>.value(value: storage),
      ],
      child: MaterialApp(
        title: 'Rhétorique — L’art de Molière',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.light, // Pas de mode sombre (thème clair classique permanent)
        home: const HomeScreen(),
      ),
    );
  }
}
