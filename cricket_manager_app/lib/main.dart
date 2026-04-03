import 'package:flutter/material.dart';

import 'game/game_controller.dart';
import 'game/game_scope.dart';
import 'game/models.dart';
import 'screens/dashboard_screen.dart';
import 'screens/finance_screen.dart';
import 'screens/league_screen.dart';
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
  bool _achievementShowing = false;

  @override
  void initState() {
    super.initState();
    _controller = GameController();
    _controller.addListener(_onControllerSignal);
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

  void _onControllerSignal() {
    if (_achievementShowing || !mounted) {
      return;
    }
    final next = _controller.takeNextAchievement();
    if (next == null) {
      return;
    }
    _achievementShowing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(_achievementSnack(next)).closed.whenComplete(() {
        _achievementShowing = false;
        _onControllerSignal();
      });
    });
  }

  SnackBar _achievementSnack(UnlockedAchievement unlocked) {
    return SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF101B13),
      duration: const Duration(seconds: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFF4A9E72)),
      ),
      content: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF5ECC8F),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.emoji_events, color: Color(0xFF0F2A1C)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'ACHIEVEMENT UNLOCKED',
                  style: TextStyle(
                    color: Color(0xFF9EDDBD),
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  unlocked.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  unlocked.description,
                  style: const TextStyle(color: Color(0xFFC7E7D5)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerSignal);
    _iapService.dispose();
    _controller.disposeController();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const DashboardScreen(),
      const SquadScreen(),
      const LeagueScreen(),
      const FinanceScreen(),
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
              seedColor: const Color(0xFF2B6E53),
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF0C0F14),
            cardTheme: CardThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 0,
              margin: EdgeInsets.zero,
            ),
            snackBarTheme: const SnackBarThemeData(
              insetPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
          themeMode: ThemeMode.dark,
          home: Scaffold(
            body: SafeArea(child: pages[_index]),
            bottomNavigationBar: NavigationBar(
              height: 70,
              selectedIndex: _index,
              onDestinationSelected: (index) => setState(() => _index = index),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.groups_rounded),
                  label: 'Team',
                ),
                NavigationDestination(
                  icon: Icon(Icons.emoji_events_outlined),
                  label: 'League',
                ),
                NavigationDestination(
                  icon: Icon(Icons.apartment_rounded),
                  label: 'Club',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
