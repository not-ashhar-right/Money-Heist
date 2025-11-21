import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/biometric_screen.dart';
import 'screens/home_screen.dart';

import 'screens/upi_payment_screen.dart';
import 'screens/scan_qr_screen.dart';
import 'screens/pay_phone_screen.dart';

import 'screens/stocks_screen.dart';
import 'screens/wallet_screen.dart';
import 'screens/my_balance_screen.dart';

import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';

import 'providers/session_provider.dart';
import 'providers/wallet_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // .env file not found, will use default values
    print("Warning: .env file not found. Using default API URL.");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create a ColorScheme with explicit dark brightness
    final ColorScheme scheme =
        ColorScheme.fromSeed(seedColor: Colors.green, brightness: Brightness.dark);

    final theme = ThemeData(
      // set brightness on ThemeData as well
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF001B10),
      colorScheme: scheme,
      useMaterial3: true,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SessionProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MoneyHeist',
        theme: theme,

        // First screen
        initialRoute: '/',

        // All routes
        routes: {
          '/': (context) => const WelcomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/biometric': (context) => const BiometricScreen(),
          '/home': (context) => const HomeScreen(),

          // UPI Payment Flow
          '/upi': (context) => const UpiPaymentScreen(),
          '/scan-qr': (context) => const ScanQrScreen(),
          '/pay-phone': (context) => const PayPhoneScreen(),

          // Stocks
          '/stocks': (context) => const StocksScreen(),

          // Wallet
          '/wallet': (context) => const WalletScreen(),

          // My Balance
          '/mybalance': (context) => const MyBalanceScreen(),

          // Profile
          '/profile': (context) => const ProfileScreen(),

          // Settings
          '/settings': (context) => const SettingsScreen(),
        },
      ),
    );
  }
}
