import 'package:flutter/widgets.dart';

import 'iap_service.dart';

class IapScope extends InheritedWidget {
  const IapScope({super.key, required this.iapService, required super.child});

  final IapService iapService;

  static IapService of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<IapScope>();
    assert(scope != null, 'IapScope not found in widget tree.');
    return scope!.iapService;
  }

  @override
  bool updateShouldNotify(covariant IapScope oldWidget) {
    return oldWidget.iapService != iapService;
  }
}
