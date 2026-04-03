import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum IapGrantType { ownersPack, cashCr }

class IapGrant {
  const IapGrant.ownersPack() : type = IapGrantType.ownersPack, cashCr = 0;

  const IapGrant.cash(this.cashCr) : type = IapGrantType.cashCr;

  final IapGrantType type;
  final double cashCr;
}

class IapCatalogItem {
  const IapCatalogItem({
    required this.id,
    required this.title,
    required this.fallbackPrice,
    required this.consumable,
    this.cashCr = 0,
  });

  final String id;
  final String title;
  final String fallbackPrice;
  final bool consumable;
  final double cashCr;
}

class IapService extends ChangeNotifier {
  IapService();

  static const String ownersPackId = 'owners_pack_unlock';
  static const String cashPackSmallId = 'cash_pack_10cr';
  static const String cashPackMediumId = 'cash_pack_30cr';
  static const String cashPackLargeId = 'cash_pack_70cr';

  static const List<IapCatalogItem> catalog = <IapCatalogItem>[
    IapCatalogItem(
      id: ownersPackId,
      title: 'Owner\'s Pack',
      fallbackPrice: '₹950',
      consumable: false,
    ),
    IapCatalogItem(
      id: cashPackSmallId,
      title: 'Auction Boost 10 Cr',
      fallbackPrice: '₹89',
      consumable: true,
      cashCr: 10,
    ),
    IapCatalogItem(
      id: cashPackMediumId,
      title: 'Auction Boost 30 Cr',
      fallbackPrice: '₹249',
      consumable: true,
      cashCr: 30,
    ),
    IapCatalogItem(
      id: cashPackLargeId,
      title: 'Auction Boost 70 Cr',
      fallbackPrice: '₹499',
      consumable: true,
      cashCr: 70,
    ),
  ];

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  final Map<String, ProductDetails> _storeProducts = <String, ProductDetails>{};
  final Set<String> _processedPurchaseIds = <String>{};

  bool loading = false;
  bool storeAvailable = false;
  bool ownersPackOwned = false;
  String? lastError;

  void Function(IapGrant grant)? onGrant;

  Future<void> initialize() async {
    loading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    ownersPackOwned = prefs.getBool(_ownersPackKey) ?? false;

    storeAvailable = await _iap.isAvailable();
    if (!storeAvailable) {
      loading = false;
      lastError = 'Store unavailable on this platform/device.';
      notifyListeners();
      return;
    }

    _purchaseSub ??= _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _purchaseSub?.cancel(),
      onError: (Object e) {
        lastError = e.toString();
        notifyListeners();
      },
    );

    final response = await _iap.queryProductDetails(
      catalog.map((e) => e.id).toSet(),
    );

    if (response.error != null) {
      lastError = response.error!.message;
    }

    for (final p in response.productDetails) {
      _storeProducts[p.id] = p;
    }

    loading = false;
    notifyListeners();
  }

  ProductDetails? productDetail(String productId) => _storeProducts[productId];

  String displayPrice(String productId) {
    final detail = _storeProducts[productId];
    if (detail != null) return detail.price;
    final item = catalog.firstWhere(
      (e) => e.id == productId,
      orElse: () => const IapCatalogItem(
        id: '',
        title: '',
        fallbackPrice: '',
        consumable: true,
      ),
    );
    return item.fallbackPrice;
  }

  Future<void> buyProduct(String productId) async {
    if (!storeAvailable) {
      lastError = 'Store unavailable.';
      notifyListeners();
      return;
    }

    final details = productDetail(productId);
    if (details == null) {
      lastError = 'Product not loaded: $productId';
      notifyListeners();
      return;
    }

    final item = catalog.firstWhere((e) => e.id == productId);
    final param = PurchaseParam(productDetails: details);
    lastError = null;
    notifyListeners();

    if (item.consumable) {
      await _iap.buyConsumable(purchaseParam: param);
    } else {
      await _iap.buyNonConsumable(purchaseParam: param);
    }
  }

  Future<void> restorePurchases() async {
    if (!storeAvailable) return;
    await _iap.restorePurchases();
  }

  void _onPurchaseUpdate(List<PurchaseDetails> updates) async {
    for (final purchase in updates) {
      if (purchase.status == PurchaseStatus.pending) {
        continue;
      }
      if (purchase.status == PurchaseStatus.error) {
        lastError = purchase.error?.message ?? 'Purchase failed';
      }
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        final key =
            '${purchase.purchaseID ?? purchase.transactionDate}-${purchase.productID}';
        if (!_processedPurchaseIds.contains(key)) {
          _processedPurchaseIds.add(key);
          await _grantForProductId(purchase.productID);
        }
      }
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
    notifyListeners();
  }

  Future<void> _grantForProductId(String productId) async {
    if (productId == ownersPackId) {
      if (!ownersPackOwned) {
        ownersPackOwned = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_ownersPackKey, true);
        onGrant?.call(const IapGrant.ownersPack());
      }
      return;
    }

    final item = catalog.firstWhere(
      (e) => e.id == productId,
      orElse: () => const IapCatalogItem(
        id: '',
        title: '',
        fallbackPrice: '',
        consumable: true,
      ),
    );
    if (item.cashCr > 0) {
      onGrant?.call(IapGrant.cash(item.cashCr));
    }
  }

  @override
  void dispose() {
    _purchaseSub?.cancel();
    super.dispose();
  }
}

const String _ownersPackKey = 'owners_pack_owned_v1';
