import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/database_service.dart';
import 'screens/home_screen.dart';

void main() async {
  // 1. Czekamy na silnik Fluttera
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Tworzymy i odpalamy bazę
  final dbService = DatabaseService();
  await dbService.init();

  // 3. Uruchamiamy aplikację OPAKOWANĄ w Providera
  runApp(
    MultiProvider(
      providers: [
        // Tutaj "wstrzykujemy" serwis do całej aplikacji
        Provider<DatabaseService>.value(value: dbService),
      ],
      child: const RyboApp(),
    ),
  );
}

class RyboApp extends StatelessWidget {
  const RyboApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RyboKalkulator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16.0),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}