import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../utils/myntra_theme.dart';
import '../viewmodels/checkout_viewmodel.dart';
import '../viewmodels/location_viewmodel.dart';
import 'order_success_view.dart';

class CheckoutView extends StatefulWidget {
  final Product product;

  const CheckoutView({
    super.key,
    required this.product,
  });

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    final locationVM = Provider.of<LocationViewModel>(context, listen: false);
    _addressController = TextEditingController(text: locationVM.address);
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handlePlaceOrder() async {
    final checkoutVM = Provider.of<CheckoutViewModel>(context, listen: false);

    final success = await checkoutVM.placeOrder(
      product: widget.product,
      deliveryAddress: _addressController.text.trim(),
    );

    if (mounted) {
      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OrderSuccessView(
              orderId: checkoutVM.placedOrderId ?? 'ORD-000000',
              product: widget.product,
              deliveryAddress: _addressController.text.trim(),
            ),
          ),
        );
      } else if (checkoutVM.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(checkoutVM.errorMessage!),
            backgroundColor: MyntraColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final checkoutVM = Provider.of<CheckoutViewModel>(context);
    final locationVM = Provider.of<LocationViewModel>(context);
    final originalPrice = widget.product.price * 1.45;
    final discount = originalPrice - widget.product.price;

    return Scaffold(
      backgroundColor: MyntraColors.background,
      appBar: AppBar(
        title: const Text(
          'CHECKOUT',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: MyntraColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Step Progress Indicator
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('BAG', style: TextStyle(fontSize: 11, color: MyntraColors.textMuted)),
                  Text(' -------- ', style: TextStyle(color: MyntraColors.border)),
                  Text('ADDRESS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: MyntraColors.greenBadge)),
                  Text(' -------- ', style: TextStyle(color: MyntraColors.border)),
                  Text('PAYMENT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: MyntraColors.primary)),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Delivery Address Box
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 18, color: MyntraColors.primary),
                          SizedBox(width: 6),
                          Text(
                            'DELIVERY ADDRESS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                              color: MyntraColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () async {
                          await locationVM.fetchLocation();
                          _addressController.text = locationVM.address;
                        },
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: const Text(
                          'DETECT GPS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: MyntraColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _addressController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: MyntraColors.background,
                      contentPadding: const EdgeInsets.all(12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: MyntraColors.border),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(Icons.flash_on, size: 14, color: MyntraColors.greenBadge),
                      SizedBox(width: 4),
                      Text(
                        'Estimated Delivery: Express by Tomorrow',
                        style: TextStyle(fontSize: 11, color: MyntraColors.greenBadge, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Item Preview
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 70,
                    height: 80,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      border: Border.all(color: MyntraColors.border),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Image.network(
                      widget.product.image,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: MyntraColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.product.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: MyntraColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '\$${widget.product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: MyntraColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '\$${originalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 12,
                                decoration: TextDecoration.lineThrough,
                                color: MyntraColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Payment Mode (COD)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PAYMENT OPTION',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      color: MyntraColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: MyntraColors.primary, width: 1.2),
                      borderRadius: BorderRadius.circular(4),
                      color: const Color(0xFFFFF0F3),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.payments_outlined, color: MyntraColors.primary, size: 24),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cash on Delivery (Cash / UPI on Arrival)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: MyntraColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Pay at your doorstep with Cash or QR scan',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: MyntraColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.check_circle, color: MyntraColors.primary, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Price Details Card
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PRICE DETAILS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      color: MyntraColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total MRP', style: TextStyle(fontSize: 13, color: MyntraColors.textSecondary)),
                      Text('\$${originalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Discount on MRP', style: TextStyle(fontSize: 13, color: MyntraColors.textSecondary)),
                      Text('-\$${discount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, color: MyntraColors.greenBadge)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Delivery Fee', style: TextStyle(fontSize: 13, color: MyntraColors.textSecondary)),
                      Text('FREE', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: MyntraColors.greenBadge)),
                    ],
                  ),
                  const Divider(height: 24, color: MyntraColors.border),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: MyntraColors.textPrimary),
                      ),
                      Text(
                        '\$${widget.product.price.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: MyntraColors.textPrimary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 90),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: MyntraColors.border)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\$${widget.product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: MyntraColors.textPrimary,
                      ),
                    ),
                    const Text(
                      'VIEW DETAILS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: MyntraColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: checkoutVM.isProcessing ? null : _handlePlaceOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyntraColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: checkoutVM.isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'PLACE ORDER',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
