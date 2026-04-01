import 'package:flutter/widgets.dart';

import 'game_controller.dart';

class GameScope extends InheritedNotifier<GameController> {
  const GameScope({super.key, required super.notifier, required super.child});

  static GameController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<GameScope>();
    assert(scope != null, 'GameScope not found in widget tree.');
    return scope!.notifier!;
  }
}
