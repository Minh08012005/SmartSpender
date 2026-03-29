import 'package:flutter/material.dart';
import '../core/strings.dart';
import '../views/home/home_screen.dart';
import '../views/statistic/statistic_screen.dart';
import '../views/wallet/wallet_screen.dart';
import '../views/profile/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(), // Home
    StatisticScreen(), // Statistic
    WalletScreen(), // Wallet
    ProfileScreen(), // Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: _screens[_currentIndex],
        ),
      ),

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 16,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              activeIcon: Icon(Icons.home_rounded),
              label: AppStrings.navHome,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              activeIcon: Icon(Icons.bar_chart_rounded),
              label: AppStrings.navStatistic,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_rounded),
              activeIcon: Icon(Icons.account_balance_wallet_rounded),
              label: AppStrings.navWallet,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: AppStrings.navProfile,
            ),
          ],
        ),
      ),
    );
  }
}
