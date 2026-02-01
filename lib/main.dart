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

    // Kolor akcentu - zielona obramówka z ikony
    const tealAccent = Color(0xFF52B69A);

    return ThemeData(
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: tealAccent,
        brightness: brightness,
        primary: tealAccent,
        secondary: tealAccent,
      ),
      useMaterial3: true,
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: 16.0),
      ),
      appBarTheme: AppBarTheme(
        toolbarHeight: 44,
        centerTitle: true,
        scrolledUnderElevation: 4,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 8,
        backgroundColor:
            isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
        selectedItemColor: tealAccent,
        unselectedItemColor: isDark ? Colors.grey[600] : Colors.grey[500],
        type: BottomNavigationBarType.fixed,
        unselectedIconTheme: const IconThemeData(size: 24),
        selectedIconTheme: const IconThemeData(size: 26),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: tealAccent,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
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
