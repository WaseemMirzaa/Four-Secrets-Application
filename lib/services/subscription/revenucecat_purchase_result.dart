import 'package:purchases_flutter/models/customer_info_wrapper.dart';

class PurchaseResult {
  final CustomerInfo? info;
  final String? error;

  PurchaseResult({this.info, this.error});

  bool get isSuccess => info != null;
}
