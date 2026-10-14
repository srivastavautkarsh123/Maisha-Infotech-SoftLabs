import 'dart:math';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/notification_service.dart';

class CheckoutViewModel extends ChangeNotifier {
  final NotificationService _notificationService;

  CheckoutViewModel({NotificationService? notificationService})
      : _notificationService = notificationService ?? NotificationService();

  bool _isProcessing = false;
  String? _errorMessage;
  String? _placedOrderId;

  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;
  String? get placedOrderId => _placedOrderId;

  Future<bool> placeOrder({
    required Product product,
    required String deliveryAddress,
  }) async {
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (deliveryAddress.trim().isEmpty ||
          deliveryAddress.contains('not detected')) {
        throw 'Please provide a valid delivery address before proceeding.';
      }

      // Simulate order processing delay
      await Future.delayed(const Duration(seconds: 2));

      // Generate randomized Order ID
      final orderId = 'ORD-${Random().nextInt(900000) + 100000}';
      _placedOrderId = orderId;
      _isProcessing = false;
      notifyListeners();

      // Trigger Push Notification for Success
      await _notificationService.showOrderSuccessNotification(
        orderId: orderId,
        productTitle: product.title,
        totalAmount: product.price,
      );

      return true;
    } catch (e) {
      _isProcessing = false;
      _errorMessage = e.toString();
      notifyListeners();

      // Trigger Push Notification for Failure
      await _notificationService.showOrderFailureNotification(
        reason: _errorMessage ?? 'Checkout encountered an unexpected error.',
      );

      return false;
    }
  }

  void reset() {
    _isProcessing = false;
    _errorMessage = null;
    _placedOrderId = null;
    notifyListeners();
  }
}
