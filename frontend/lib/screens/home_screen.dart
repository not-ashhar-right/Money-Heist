import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/session_provider.dart';
import '../providers/wallet_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WalletProvider>(context, listen: false).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessionProvider = Provider.of<SessionProvider>(context);
    final walletProvider = Provider.of<WalletProvider>(context);
    final String userName = sessionProvider.userEmail?.split('@')[0] ?? "User";

    return Scaffold(
      backgroundColor: const Color(0xFF001B10),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TOP BAR (PROFILE + SETTINGS)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Greeting
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hello, $userName!",
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Welcome to MoneyHeist",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green.shade300,
                        ),
                      ),
                    ],
                  ),

                  // Profile button
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/profile'),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.shade700,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // TOTAL BALANCE CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.green.shade600,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Total Balance",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "₹${walletProvider.balance.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Pending Investment\n₹${walletProvider.pendingInvestment.toStringAsFixed(2)}",
                          style: const TextStyle(fontSize: 13, color: Colors.white70),
                        ),
                        Text(
                          "Available\n₹${walletProvider.balance.toStringAsFixed(2)}",
                          style: const TextStyle(fontSize: 13, color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // FEATURES GRID (UPI, STOCKS)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _featureCard(
                    title: "UPI Payment",
                    icon: Icons.qr_code_scanner,
                    color: Colors.blue,
                    onTap: () => Navigator.pushNamed(context, '/upi'),
                  ),
                  _featureCard(
                    title: "Stocks",
                    icon: Icons.show_chart,
                    color: Colors.orange,
                    onTap: () => Navigator.pushNamed(context, '/stocks'),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _featureCard(
                    title: "Wallet",
                    icon: Icons.account_balance_wallet,
                    color: Colors.purple,
                    onTap: () => Navigator.pushNamed(context, '/wallet'),
                  ),
                  _featureCard(
                    title: "My Balance",
                    icon: Icons.account_balance,
                    color: Colors.green,
                    onTap: () => Navigator.pushNamed(context, '/mybalance'),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // QUICK STATS TITLE
              const Text(
                "Quick Stats",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              // QUICK STATS CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _statRow("Auto-Investment Rate", "1–10%"),
                    const SizedBox(height: 14),
                    _statRow("Stock Preference", "Short-Term"),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// FEATURE CARD (UPI / STOCKS / WALLET / MY BALANCE)
Widget _featureCard({
  required String title,
  required IconData icon,
  required Color color,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 150,
      padding: const EdgeInsets.symmetric(vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 32, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          )
        ],
      ),
    ),
  );
}

// STATS ROW
Widget _statRow(String label, String value) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 15,
        ),
      ),
      Text(
        value,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}
