import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'services/database_service.dart';
import 'services/locale_service.dart';
import 'services/theme_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbService = DatabaseService();
  await dbService.init();

  final themeService = ThemeService();
  await themeService.init();

  final localeService = LocaleService();
  await localeService.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<DatabaseService>.value(value: dbService),
        ChangeNotifierProvider<ThemeService>.value(value: themeService),
        ChangeNotifierProvider<LocaleService>.value(value: localeService),
      ],
      child: const RyboApp(),
    ),
  );
}

class RyboApp extends StatelessWidget {
  const RyboApp({super.key});

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      brightness: brightness,
      primarySwatch: Colors.blue,
      useMaterial3: true,
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: 16.0),
      ),
      appBarTheme: const AppBarTheme(
        toolbarHeight: 44,
        centerTitle: true,
        scrolledUnderElevation: 4,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 8,
        backgroundColor: isDark ? Colors.grey[900] : Colors.grey[200],
        selectedItemColor: isDark ? Colors.blue[300] : Colors.blue[700],
        unselectedItemColor: isDark ? Colors.grey[500] : Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        unselectedIconTheme: const IconThemeData(size: 24),
        selectedIconTheme: const IconThemeData(size: 26),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();
    final localeService = context.watch<LocaleService>();
    return MaterialApp(
      title: 'RyboKalkulator',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: themeService.themeMode,
      locale: localeService.locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pl'),
        Locale('en'),
        Locale('de'),
      ],
      home: const HomeScreen(),
    );
  }
}