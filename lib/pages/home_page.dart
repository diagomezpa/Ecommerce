import 'package:flutter/material.dart';
import 'package:fake_maker_api_pragma_api/fake_maker_api_pragma_api.dart';
import 'package:pragma_design_system/pragma_design_system.dart';
import 'product_detail_page.dart';
import 'product_list_page.dart';
import 'search_page.dart';
import 'cart_page.dart';

/// HomePage - Main entry point for the eCommerce application
///
/// This page serves as the primary navigation hub displaying featured products
/// and quick access actions for core app functionality.
///
/// **Features:**
/// - Featured products section (4-6 products from API)
/// - Quick access cards for catalog, search, and cart
/// - Loading, success, and error states using ProductBloc
/// - Navigation to ProductDetailPage on product selection
///
/// **Design System Usage:**
/// - AppSection: Semantic blocks for featured and quick access sections
/// - AppCard: Quick action cards only
/// - AppText: Typography hierarchy throughout
/// - AppButton: Quick access actions
/// - AppSpacer: Consistent spacing
/// - AppEmptyStateSection: Error state handling
/// - ProductListTemplate: Product grid template from design system (TEMPLATE)
///
/// **State Management:**
/// - Uses ProductBloc for featured products data fetching
/// - Limits products to 6 items max from presentation layer
/// - State derived from data presence (no explicit loading flags)
///
/// **Architecture:**
/// - HomePage: Main orchestration widget
/// - _FeaturedProductsSection: Products display section
/// - _QuickActionsSection: Access shortcuts section
/// - Follows Atomic Design principles with proper separation
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  late final ProductBloc _productBloc;
  final List<Product> _featuredProducts = [];
  String? _errorMessage;
  int _loadedCount = 0;
  final int _targetCount = 6;
  final List<int> _featuredProductIds = [1, 2, 3, 4, 5, 6];

  /// Loading state derived from data presence
  bool get _isLoading => _loadedCount < _targetCount && _errorMessage == null;

  @override
  void initState() {
    super.initState();
    
    // Initialize ProductBloc to load featured products
    _productBloc = initializeProductBloc((productOrProducts) {
      if (mounted) {
        setState(() {
          if (productOrProducts is Product) {
            // Add product to featured list if not already present
            if (!_featuredProducts.any((p) => p.id == productOrProducts.id)) {
              _featuredProducts.add(productOrProducts);
              _loadedCount++;
            }
            _errorMessage = null;
          } else if (productOrProducts is ProductDeleted) {
            // Handle deleted product case
            final product = productOrProducts.product;
            if (!_featuredProducts.any((p) => p.id == product.id)) {
              _featuredProducts.add(product);
              _loadedCount++;
            }
            _errorMessage = null;
          } else if (productOrProducts is String) {
            _errorMessage = productOrProducts;
            _featuredProducts.clear();
            _loadedCount = 0;
          }
        });
      }
    });

    // Load featured products
    _loadFeaturedProducts();
  }

  void _loadFeaturedProducts() {
    // Reset state
    setState(() {
      _featuredProducts.clear();
      _loadedCount = 0;
      _errorMessage = null;
    });

    // Load featured products sequentially
    for (final productId in _featuredProductIds) {
      _productBloc.eventSink.add(LoadProduct(productId));
    }
  }

  @override
  void dispose() {
    // Note: eventSink.close() handled here since ProductBloc doesn't expose dispose()
    _productBloc.eventSink.close();
    super.dispose();
  }

  /// Show logout confirmation dialog
  void _showLogoutDialog(BuildContext context) {
    AppDialog.show(
      context: context,
      title: 'Logout',
      content: AppText('Are you sure you want to logout?'),
      actions: [
        AppButton(
          text: 'Cancel',
          variant: AppButtonVariant.outline,
          onPressed: () => Navigator.pop(context),
        ),
        AppButton(
          text: 'Logout',
          variant: AppButtonVariant.primary,
          onPressed: () {
            Navigator.pop(context); // Close dialog
            Navigator.pushReplacementNamed(context, '/login'); // Navigate to login
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppText(
          'Pragma Store',
          variant: AppTextVariant.titleLarge,
        ),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CartPage(
                  cartBloc: initializeCartBloc((state) {}),
                ),
              ),
            ),
            icon: const Icon(Icons.shopping_cart),
            tooltip: 'Shopping Cart',
          ),
          IconButton(
            onPressed: () => _showLogoutDialog(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  /// Builds main body content based on current state
  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_featuredProducts.isNotEmpty) {
      return _buildSuccessState(_featuredProducts);
    }

    if (_errorMessage != null) {
      return _buildErrorState(_errorMessage!);
    }

    return _buildLoadingState();
  }

  /// ATOM: Loading state with centered indicator
  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  /// ORGANISM: Error state using AppEmptyStateSection
  Widget _buildErrorState(String errorMessage) {
    return AppEmptyStateSection(
      icon: Icons.store_outlined,
      title: 'Unable to Load Store',
      description: 'We couldn\'t load the featured products. Please try again.',
      primaryAction: AppButton(
        text: 'Retry',
        onPressed: () {
          setState(() {
            _errorMessage = null;
            _featuredProducts.clear();
            _loadedCount = 0;
          });
          _loadFeaturedProducts();
        },
      ),
    );
  }

  /// Main success state with featured products and quick actions
  Widget _buildSuccessState(List<Product> products) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ATOM: Top spacing
          const AppSpacer(size: AppSpacerSize.large),
          
          // MOLECULE: Featured Products Section
          _FeaturedProductsSection(
            products: products,
            onProductTap: _navigateToProductDetail,
          ),
          
          // ATOM: Section spacing
          const AppSpacer(size: AppSpacerSize.extraLarge),
          
          // MOLECULE: Quick Actions Section
          _QuickActionsSection(allProducts: products),
          
          // ATOM: Bottom spacing
          const AppSpacer(size: AppSpacerSize.extraLarge),
        ],
      ),
    );
  }

  /// Navigation handler for product selection
  void _navigateToProductDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(productId: product.id),
      ),
    );
  }
}

/// MOLECULE: Featured Products Section using ProductListTemplate
/// Uses design system template for optimal product display structure
class _FeaturedProductsSection extends StatelessWidget {
  const _FeaturedProductsSection({
    required this.products,
    required this.onProductTap,
  });

  final List<Product> products;
  final Function(Product) onProductTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: AppSection(
        title: 'Featured Products',
        child: Column(
          children: [
            // ATOM: Section spacing
            const AppSpacer(size: AppSpacerSize.medium),
            
            // TEMPLATE: Product list template from design system
            ProductListTemplate(
              products: products
                  .map((product) => AppProductListItem(
                        title: product.title,
                        subtitle: _formatCategoryName(product.category),
                        price: '\$${product.price.toStringAsFixed(2)}',
                        imageUrl: product.image,
                        isEnabled: true,
                        onTap: () => onProductTap(product),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Formats the category enum to a readable string
  String _formatCategoryName(Category category) {
    switch (category) {
      case Category.ELECTRONICS:
        return 'Electronics';
      case Category.JEWELERY:
        return 'Jewelry';
      case Category.MENS_CLOTHING:
        return "Men's Clothing";
      case Category.WOMENS_CLOTHING:
        return "Women's Clothing";
    }
  }
}

/// MOLECULE: Quick Actions Section
/// Provides access to core app functionality
class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection({
    required this.allProducts,
  });

  final List<Product> allProducts;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: AppSection(
        title: 'Quick Access',
        child: Column(
          children: [
            // ATOM: Section spacing
            const AppSpacer(size: AppSpacerSize.medium),
            
            // Quick action cards grid
            Row(
              children: [
                // Catalog access card
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.grid_view,
                    title: 'Catalog',
                    subtitle: 'Browse all products',
                    onTap: () => _navigateToCatalog(context),
                  ),
                ),
                
                // ATOM: Horizontal spacing
                const AppSpacer(size: AppSpacerSize.medium),
                
                // Search access card
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.search,
                    title: 'Search',
                    subtitle: 'Find products',
                    onTap: () => _navigateToSearch(context),
                  ),
                ),
              ],
            ),
            
            // ATOM: Vertical spacing
            const AppSpacer(size: AppSpacerSize.medium),
            
            // Cart access card (full width)
            _QuickActionCard(
              icon: Icons.shopping_cart,
              title: 'Shopping Cart',
              subtitle: 'View your items',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartPage(
                    cartBloc: initializeCartBloc((state) {}),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Navigate to product catalog page
  void _navigateToCatalog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProductListPage(),
      ),
    );
  }

  /// Navigate to search page with all available products
  void _navigateToSearch(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchPage(products: allProducts),
      ),
    );
  }
}

/// MOLECULE: Quick Action Card
/// Individual action card using AppCard surface
class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // ATOM: Action icon
              Icon(
                icon,
                size: 48,
              ),
              
              // ATOM: Icon spacing
              const AppSpacer(size: AppSpacerSize.small),
              
              // ATOM: Action title
              AppText(
                title,
                variant: AppTextVariant.titleMedium,
                textAlign: TextAlign.center,
              ),
              
              // ATOM: Title spacing
              const AppSpacer(size: AppSpacerSize.small),
              
              // ATOM: Action subtitle
              AppText(
                subtitle,
                variant: AppTextVariant.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}