import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../utils/myntra_theme.dart';
import '../viewmodels/location_viewmodel.dart';
import '../viewmodels/product_viewmodel.dart';
import '../viewmodels/wishlist_viewmodel.dart';
import 'product_detail_view.dart';
import 'tabs/categories_tab.dart';
import 'tabs/profile_tab.dart';
import 'tabs/wishlist_tab.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  int _selectedBottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductViewModel>(context, listen: false).loadInitialData();
      Provider.of<LocationViewModel>(context, listen: false).fetchLocation();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final locationVM = Provider.of<LocationViewModel>(context, listen: false);
      if (locationVM.isGpsDisabled) {
        locationVM.fetchLocation();
      }
    }
  }

  void _showLocationBottomSheet(BuildContext context) {
    final locationVM = Provider.of<LocationViewModel>(context, listen: false);
    final customController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'CHOOSE DELIVERY LOCATION',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      color: MyntraColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Option 1: Auto-Detect GPS Location
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: MyntraColors.primary, width: 1.2),
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFFFF0F3),
                ),
                child: ListTile(
                  leading: const Icon(Icons.my_location, color: MyntraColors.primary),
                  title: const Text(
                    'Use Current GPS Location',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: MyntraColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    locationVM.isGpsDisabled
                        ? 'GPS is OFF. Tap "Enable GPS" below.'
                        : 'Tap to auto-detect your exact address',
                    style: TextStyle(
                      fontSize: 12,
                      color: locationVM.isGpsDisabled ? Colors.red : MyntraColors.textSecondary,
                    ),
                  ),
                  trailing: locationVM.isGpsDisabled
                      ? ElevatedButton(
                          onPressed: () {
                            locationVM.openLocationSettings();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MyntraColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          ),
                          child: const Text('TURN ON GPS', style: TextStyle(fontSize: 10)),
                        )
                      : TextButton(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            await locationVM.fetchLocation();
                          },
                          child: const Text(
                            'DETECT',
                            style: TextStyle(
                              color: MyntraColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                  onTap: () async {
                    if (locationVM.isGpsDisabled) {
                      locationVM.openLocationSettings();
                    } else {
                      Navigator.pop(ctx);
                      await locationVM.fetchLocation();
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Option 2: Enter Pincode / Address manually
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: customController,
                      decoration: InputDecoration(
                        hintText: 'Enter Delivery Pincode or Address',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(color: MyntraColors.border),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (customController.text.trim().isNotEmpty) {
                        locationVM.updateManualAddress(customController.text.trim());
                        Navigator.pop(ctx);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyntraColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    child: const Text('CHECK'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Option 3: Quick Select Popular Cities
              const Text(
                'POPULAR CITIES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: MyntraColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _CityChip(
                    city: 'Bengaluru',
                    pincode: '560038',
                    state: 'Karnataka',
                    onTap: () {
                      locationVM.selectPresetCity('Bengaluru', 'Karnataka', '560038');
                      Navigator.pop(ctx);
                    },
                  ),
                  _CityChip(
                    city: 'Mumbai',
                    pincode: '400001',
                    state: 'Maharashtra',
                    onTap: () {
                      locationVM.selectPresetCity('Mumbai', 'Maharashtra', '400001');
                      Navigator.pop(ctx);
                    },
                  ),
                  _CityChip(
                    city: 'New Delhi',
                    pincode: '110001',
                    state: 'Delhi',
                    onTap: () {
                      locationVM.selectPresetCity('New Delhi', 'Delhi', '110001');
                      Navigator.pop(ctx);
                    },
                  ),
                  _CityChip(
                    city: 'Hyderabad',
                    pincode: '500081',
                    state: 'Telangana',
                    onTap: () {
                      locationVM.selectPresetCity('Hyderabad', 'Telangana', '500081');
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PopScope(
        canPop: _selectedBottomNavIndex == 0,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (_selectedBottomNavIndex != 0) {
            setState(() {
              _selectedBottomNavIndex = 0;
            });
          }
        },
        child: IndexedStack(
          index: _selectedBottomNavIndex,
          children: [
            _buildHomeFeedTab(context),
            CategoriesTab(
              onNavigateToTab: (tabIndex) {
                setState(() {
                  _selectedBottomNavIndex = tabIndex;
                });
              },
            ),
            WishlistTab(
              onExploreMore: () {
                setState(() {
                  _selectedBottomNavIndex = 0;
                });
              },
            ),
            const ProfileTab(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedBottomNavIndex,
        onTap: (index) {
          setState(() {
            _selectedBottomNavIndex = index;
          });
        },
        selectedItemColor: MyntraColors.primary,
        unselectedItemColor: MyntraColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            activeIcon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeFeedTab(BuildContext context) {
    final locationVM = Provider.of<LocationViewModel>(context);
    final productVM = Provider.of<ProductViewModel>(context);
    final wishlistVM = Provider.of<WishlistViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [MyntraColors.primary, Color(0xFFFF527B)],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.shopping_bag, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            const Text(
              'MAISHA',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: MyntraColors.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          // Wishlist Action with Badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.favorite_border, color: MyntraColors.textPrimary),
                tooltip: 'Wishlist',
                onPressed: () {
                  setState(() {
                    _selectedBottomNavIndex = 2;
                  });
                },
              ),
              if (wishlistVM.itemCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: MyntraColors.primary,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${wishlistVM.itemCount}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: MyntraColors.textPrimary),
            tooltip: 'Profile',
            onPressed: () {
              setState(() {
                _selectedBottomNavIndex = 3;
              });
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: MyntraColors.primary,
        onRefresh: () async {
          await Future.wait([
            productVM.refresh(),
            locationVM.fetchLocation(),
          ]);
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Myntra Delivery Location Strip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: const BoxDecoration(
                  color: Color(0xFFFAFAFA),
                  border: Border(
                    top: BorderSide(color: MyntraColors.border),
                    bottom: BorderSide(color: MyntraColors.border),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: MyntraColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: RichText(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 12,
                            color: MyntraColors.textSecondary,
                          ),
                          children: [
                            const TextSpan(text: 'Deliver to: '),
                            TextSpan(
                              text: locationVM.shortDisplay,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: MyntraColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _showLocationBottomSheet(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: MyntraColors.primary),
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.white,
                        ),
                        child: const Text(
                          'CHANGE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: MyntraColors.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // If GPS is turned off notification banner
              if (locationVM.isGpsDisabled)
                Container(
                  color: const Color(0xFFFFF4E5),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: Colors.orange),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'GPS is turned off. Tap to turn on for auto-detection.',
                          style: TextStyle(fontSize: 11, color: Color(0xFF663C00)),
                        ),
                      ),
                      TextButton(
                        onPressed: () => locationVM.openLocationSettings(),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 24),
                        ),
                        child: const Text(
                          'ENABLE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: MyntraColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // 2. Clean Search Bar (camera & mic icons removed!)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => productVM.setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Search for clothes, brands, products...',
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: MyntraColors.textMuted,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: MyntraColors.textSecondary,
                      size: 20,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              productVM.setSearchQuery('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: MyntraColors.background,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: MyntraColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: MyntraColors.border),
                    ),
                  ),
                ),
              ),

              // 3. Category Stories Row
              if (productVM.categories.isNotEmpty) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 90,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: productVM.categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final cat = productVM.categories[index];
                      final isSelected = productVM.selectedCategory == cat;

                      return GestureDetector(
                        onTap: () => productVM.setCategory(cat),
                        child: Column(
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? MyntraColors.primary : Colors.transparent,
                                  width: 2.2,
                                ),
                              ),
                              padding: const EdgeInsets.all(3),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _getCategoryColor(cat),
                                ),
                                child: Icon(
                                  _getCategoryIcon(cat),
                                  size: 26,
                                  color: isSelected ? Colors.white : MyntraColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              cat == 'all' ? 'All' : cat[0].toUpperCase() + cat.substring(1),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? MyntraColors.primary : MyntraColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],

              // 4. Hero Promotional Banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF2B0938),
                        Color(0xFF5D1263),
                        Color(0xFFFF3F6C),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(25),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: MyntraColors.accentOrange,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'GRAND FASHION CARNIVAL',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              '50-80% OFF',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              '+ EXTRA \$15 OFF ON 1ST ORDER',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFFFD1DC),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 12,
                        bottom: 8,
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          size: 80,
                          color: Colors.white.withAlpha(35),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 5. Section Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      productVM.selectedCategory == 'all'
                          ? 'TRENDING PRODUCTS'
                          : productVM.selectedCategory.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: MyntraColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${productVM.products.length} Products',
                      style: const TextStyle(
                        fontSize: 12,
                        color: MyntraColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),

              // 6. Products Grid
              Builder(
                builder: (context) {
                  if (productVM.isLoading) {
                    return const SizedBox(
                      height: 300,
                      child: Center(
                        child: CircularProgressIndicator(color: MyntraColors.primary),
                      ),
                    );
                  }

                  if (productVM.errorMessage != null) {
                    return Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          const Icon(Icons.error_outline, size: 40, color: MyntraColors.primary),
                          const SizedBox(height: 8),
                          Text(productVM.errorMessage!, textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => productVM.loadInitialData(),
                            child: const Text('RETRY'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (productVM.products.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Center(
                        child: Text(
                          'No products found matching your search.',
                          style: TextStyle(color: MyntraColors.textMuted),
                        ),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.58,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: productVM.products.length,
                    itemBuilder: (context, index) {
                      final product = productVM.products[index];
                      return _MyntraProductCard(
                        product: product,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailView(product: product),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'all':
        return const Color(0xFFFFE0E6);
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
      case 'all':
        return Icons.auto_awesome;
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

class _CityChip extends StatelessWidget {
  final String city;
  final String pincode;
  final String state;
  final VoidCallback onTap;

  const _CityChip({
    required this.city,
    required this.pincode,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: const Icon(Icons.location_city, size: 16, color: MyntraColors.primary),
      label: Text('$city ($pincode)', style: const TextStyle(fontSize: 12)),
      backgroundColor: MyntraColors.background,
      side: const BorderSide(color: MyntraColors.border),
      onPressed: onTap,
    );
  }
}

class _MyntraProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _MyntraProductCard({
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final originalPrice = product.price * 1.45;
    final wishlistVM = Provider.of<WishlistViewModel>(context);
    final isWishlisted = wishlistVM.isWishlisted(product.id);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: MyntraColors.border, width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack Container with Interactive Wishlist & Rating
            Expanded(
              flex: 6,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.all(12),
                    child: Hero(
                      tag: 'product-${product.id}',
                      child: Image.network(
                        product.image,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Center(
                          child: Icon(Icons.broken_image, color: Colors.grey),
                        ),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: MyntraColors.primary,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Interactive Wishlist Icon (Top Right)
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
                            backgroundColor:
                                isWishlisted ? Colors.black87 : MyntraColors.primary,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(220),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(15),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          isWishlisted ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: isWishlisted
                              ? MyntraColors.primary
                              : MyntraColors.textSecondary,
                        ),
                      ),
                    ),
                  ),

                  // Rating Badge (Bottom Left)
                  Positioned(
                    bottom: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(235),
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(20),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            product.rating.rate.toString(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: MyntraColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(Icons.star, size: 10, color: MyntraColors.greenBadge),
                          const SizedBox(width: 3),
                          Text(
                            '| ${product.rating.count}',
                            style: const TextStyle(
                              fontSize: 9,
                              color: MyntraColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Product Details Block
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Brand / Category Tag
                    Text(
                      _getBrandName(product.category),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                        color: MyntraColors.textPrimary,
                      ),
                    ),

                    // Subtitle / Title
                    Text(
                      product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: MyntraColors.textSecondary,
                      ),
                    ),

                    // Price Section
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
                            decoration: TextDecoration.lineThrough,
                            color: MyntraColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '(30% OFF)',
                          style: TextStyle(
                            fontSize: 10,
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
        return 'MYNTRA EXCLUSIVE';
    }
  }
}
