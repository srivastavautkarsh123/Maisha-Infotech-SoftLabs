import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/myntra_theme.dart';
import '../../viewmodels/product_viewmodel.dart';
import '../category_products_view.dart';

class CategoriesTab extends StatelessWidget {
  final Function(int) onNavigateToTab;

  const CategoriesTab({
    super.key,
    required this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    final productVM = Provider.of<ProductViewModel>(context);
    final categories = productVM.categories.where((c) => c != 'all').toList();

    return Scaffold(
      backgroundColor: MyntraColors.background,
      appBar: AppBar(
        title: const Text(
          'ALL CATEGORIES',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            color: MyntraColors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Top Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2B0938), MyntraColors.primary],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.category, color: Colors.white, size: 36),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EXPLORE COLLECTIONS',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Curated styles across fashion, accessories & tech',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Categories List
          ...categories.map((category) {
            final catProducts = productVM.products
                .where((p) => p.category.toLowerCase() == category.toLowerCase())
                .toList();

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: MyntraColors.border),
              ),
              color: Colors.white,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoryProductsView(category: category),
                    ),
                  );
                  if (result is int) {
                    onNavigateToTab(result);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: _getCategoryColor(category),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getCategoryIcon(category),
                          color: MyntraColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
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
                            const SizedBox(height: 4),
                            Text(
                              '${catProducts.length} items available',
                              style: const TextStyle(
                                fontSize: 12,
                                color: MyntraColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: MyntraColors.textMuted,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _getCategoryColor(String cat) {
    switch (cat.toLowerCase()) {
      case "men's clothing":
        return const Color(0xFFE3F2FD);
      case "women's clothing":
        return const Color(0xFFFCE4EC);
      case 'jewelery':
        return const Color(0xFFFFF8E1);
      case 'electronics':
        return const Color(0xFFE8F5E9);
      default:
        return const Color(0xFFF3E5F5);
    }
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat.toLowerCase()) {
      case "men's clothing":
        return Icons.male;
      case "women's clothing":
        return Icons.female;
      case 'jewelery':
        return Icons.diamond_outlined;
      case 'electronics':
        return Icons.devices_other;
      default:
        return Icons.checkroom;
    }
  }
}
