
import 'package:flutter/material.dart';
import 'services/auth_storage.dart';
import 'services/api_service.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/home/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool loggedIn = false;

  try {
    final token = await AuthStorage.getToken();

    if (token != null && token.isNotEmpty) {
      final response = await ApiService.profile();
      loggedIn = response['success'] == true;
    }
  } catch (_) {
    // If the server is unavailable, show login.
    loggedIn = false;
  }

  runApp(TrimPlateApp(loggedIn: loggedIn));
}

class TrimPlateApp extends StatelessWidget {
  final bool loggedIn;

  const TrimPlateApp({super.key, required this.loggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrimPlate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF008747),
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF008747),
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: loggedIn ? const HomeScreen() : const WelcomeScreen(),
    );
  }
}
