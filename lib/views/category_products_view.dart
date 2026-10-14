import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/myntra_theme.dart';
import '../viewmodels/product_viewmodel.dart';
import '../viewmodels/wishlist_viewmodel.dart';
import 'product_detail_view.dart';

class CategoryProductsView extends StatelessWidget {
  final String category;

  const CategoryProductsView({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final productVM = Provider.of<ProductViewModel>(context);
    final wishlistVM = Provider.of<WishlistViewModel>(context);

    final categoryProducts = productVM.products
        .where((p) => p.category.toLowerCase() == category.toLowerCase())
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: MyntraColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category[0].toUpperCase() + category.substring(1),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: MyntraColors.textPrimary,
              ),
            ),
            Text(
              '${categoryProducts.length} items',
              style: const TextStyle(
                fontSize: 11,
                color: MyntraColors.textMuted,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: MyntraColors.textPrimary),
            onPressed: () {
              Navigator.of(context).pop(2); // Can navigate to wishlist
            },
          ),
        ],
      ),
      body: categoryProducts.isEmpty
          ? const Center(
              child: Text(
                'No products available in this category.',
                style: TextStyle(color: MyntraColors.textMuted),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.58,
                crossAxisSpacing: 10,
                mainAxisSpacing: 12,
              ),
              itemCount: categoryProducts.length,
              itemBuilder: (context, index) {
                final product = categoryProducts[index];
                final originalPrice = product.price * 1.45;
                final isWishlisted = wishlistVM.isWishlisted(product.id);

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailView(product: product),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: MyntraColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image & Wishlist Container
                        Expanded(
                          flex: 6,
                          child: Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                child: Hero(
                                  tag: 'cat-product-${product.id}',
                                  child: Image.network(
                                    product.image,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 6,
                                right: 6,
                                child: GestureDetector(
                                  onTap: () {
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
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(220),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isWishlisted
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      size: 16,
                                      color: isWishlisted
                                          ? MyntraColors.primary
                                          : MyntraColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 6,
                                left: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(230),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        product.rating.rate.toString(),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 2),
                                      const Icon(
                                        Icons.star,
                                        size: 10,
                                        color: MyntraColors.greenBadge,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Info
                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  product.category.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: MyntraColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  product.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: MyntraColors.textSecondary,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '\$${product.price.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                        color: MyntraColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '\$${originalPrice.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        decoration:
                                            TextDecoration.lineThrough,
                                        color: MyntraColors.textMuted,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      '(30% OFF)',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: MyntraColors.orangeOffer,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
