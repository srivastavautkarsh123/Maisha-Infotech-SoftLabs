import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../utils/myntra_theme.dart';
import '../viewmodels/wishlist_viewmodel.dart';
import 'checkout_view.dart';

class ProductDetailView extends StatelessWidget {
  final Product product;

  const ProductDetailView({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final originalPrice = product.price * 1.45;
    final wishlistVM = Provider.of<WishlistViewModel>(context);
    final isWishlisted = wishlistVM.isWishlisted(product.id);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          product.category.toUpperCase(),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: MyntraColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              isWishlisted ? Icons.favorite : Icons.favorite_border,
              color: isWishlisted ? MyntraColors.primary : MyntraColors.textPrimary,
            ),
            onPressed: () {
              wishlistVM.toggleWishlist(product);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isWishlisted ? 'Removed from Wishlist' : 'Added to Wishlist!',
                  ),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor:
                      isWishlisted ? Colors.black87 : MyntraColors.primary,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image
            Container(
              height: 340,
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Hero(
                tag: 'product-${product.id}',
                child: Image.network(
                  product.image,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Center(
                    child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
                  ),
                ),
              ),
            ),

            // Product Details Block
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand Name
                  Text(
                    _getBrandName(product.category),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: MyntraColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Full Title
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: MyntraColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Rating Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: MyntraColors.border),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          product.rating.rate.toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: MyntraColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.star, size: 13, color: MyntraColors.greenBadge),
                        const SizedBox(width: 6),
                        Text(
                          '|  ${product.rating.count} Ratings',
                          style: const TextStyle(
                            fontSize: 11,
                            color: MyntraColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Divider(color: MyntraColors.border),
                  const SizedBox(height: 12),

                  // Price Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: MyntraColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'MRP \$${originalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          decoration: TextDecoration.lineThrough,
                          color: MyntraColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '(30% OFF)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: MyntraColors.orangeOffer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'inclusive of all taxes',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: MyntraColors.greenBadge,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Delivery Highlights
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: MyntraColors.background,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: MyntraColors.border),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.local_shipping_outlined, size: 18, color: MyntraColors.textPrimary),
                            SizedBox(width: 8),
                            Text(
                              'Get it by Tomorrow • FREE Delivery',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: MyntraColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.payments_outlined, size: 18, color: MyntraColors.greenBadge),
                            SizedBox(width: 8),
                            Text(
                              'Pay on Delivery / Cash on Delivery Available',
                              style: TextStyle(
                                fontSize: 12,
                                color: MyntraColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Product Details / Description
                  const Text(
                    'PRODUCT DETAILS',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      color: MyntraColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: MyntraColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 90), // Spacing for bottom CTA
                ],
              ),
            ),
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
              // Wishlist Button
              Expanded(
                flex: 4,
                child: OutlinedButton.icon(
                  onPressed: () {
                    wishlistVM.toggleWishlist(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isWishlisted
                              ? 'Removed from Wishlist'
                              : 'Added to Wishlist!',
                        ),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor:
                            isWishlisted ? Colors.black87 : MyntraColors.primary,
                      ),
                    );
                  },
                  icon: Icon(
                    isWishlisted ? Icons.favorite : Icons.favorite_border,
                    color: isWishlisted ? MyntraColors.primary : MyntraColors.textPrimary,
                    size: 18,
                  ),
                  label: Text(
                    isWishlisted ? 'WISHLISTED' : 'WISHLIST',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: isWishlisted ? MyntraColors.primary : MyntraColors.textPrimary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isWishlisted ? MyntraColors.primary : MyntraColors.border,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Buy Now CTA Button
              Expanded(
                flex: 6,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CheckoutView(product: product),
                      ),
                    );
                  },
                  icon: const Icon(Icons.flash_on, color: Colors.white, size: 18),
                  label: const Text(
                    'BUY NOW',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyntraColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
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

  String _getBrandName(String category) {
    switch (category.toLowerCase()) {
      case "men's clothing":
        return 'ROADSTER';
      case "women's clothing":
        return 'MANGO';
      case 'jewelery':
        return 'ZAVERI PEARLS';
      case 'electronics':
        return 'BOAT';
      default:
        return 'MYNTRA';
    }
  }
}
