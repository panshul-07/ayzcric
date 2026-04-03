import 'package:flutter/material.dart';

import 'game/game_controller.dart';
import 'game/game_scope.dart';
import 'screens/auction_screen.dart';
import 'screens/career_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/finance_screen.dart';
import 'screens/match_center_screen.dart';
import 'screens/squad_screen.dart';
import 'services/iap_scope.dart';
import 'services/iap_service.dart';

void main() {
  runApp(const CricketManagerApp());
}

class CricketManagerApp extends StatefulWidget {
  const CricketManagerApp({super.key});

  @override
  State<CricketManagerApp> createState() => _CricketManagerAppState();
}

class _CricketManagerAppState extends State<CricketManagerApp> {
  late final GameController _controller;
  late final IapService _iapService;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = GameController();
    _iapService = IapService();
    _iapService.onGrant = (grant) {
      switch (grant.type) {
        case IapGrantType.ownersPack:
          _controller.buyOwnersPack();
          break;
        case IapGrantType.cashCr:
          _controller.grantAuctionCash(grant.cashCr, source: 'IAP Cash Pack');
          break;
      }
    };
    _initIap();
  }

  Future<void> _initIap() async {
    await _iapService.initialize();
    if (_iapService.ownersPackOwned) {
      _controller.buyOwnersPack();
    }
  }

  @override
  void dispose() {
    _iapService.dispose();
    _controller.disposeController();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const DashboardScreen(),
      const MatchCenterScreen(),
      const AuctionScreen(),
      const SquadScreen(),
      const FinanceScreen(),
      const CareerScreen(),
    ];

    return GameScope(
      notifier: _controller,
      child: IapScope(
        iapService: _iapService,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Cricket Dynasty Manager',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0E7C66),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF4F8FB),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0E7C66),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            cardTheme: CardThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 1.5,
              margin: EdgeInsets.zero,
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1BAA8B),
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF101418),
            cardTheme: CardThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 1.5,
              margin: EdgeInsets.zero,
            ),
          ),
          themeMode: ThemeMode.system,
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Cricket Dynasty Manager'),
              actions: [
                IconButton(
                  tooltip: 'Start next fixture',
                  onPressed: _controller.startNextMatch,
                  icon: const Icon(Icons.play_circle_fill),
                ),
              ],
            ),
            body: SafeArea(child: pages[_index]),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (index) => setState(() => _index = index),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.sports_cricket),
                  label: 'Match',
                ),
                NavigationDestination(
                  icon: Icon(Icons.gavel),
                  label: 'Auction',
                ),
                NavigationDestination(icon: Icon(Icons.groups), label: 'Squad'),
                NavigationDestination(
                  icon: Icon(Icons.account_balance_wallet),
                  label: 'Finance',
                ),
                NavigationDestination(icon: Icon(Icons.flag), label: 'Career'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
