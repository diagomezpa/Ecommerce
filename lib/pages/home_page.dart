import 'package:flutter/material.dart';
import 'package:fake_maker_api_pragma_api/fake_maker_api_pragma_api.dart';
import 'package:pragma_design_system/pragma_design_system.dart';
import 'product_detail_page.dart';
import 'product_list_page.dart';
import 'search_page.dart';
import 'cart_page.dart';
import 'support_page.dart';
import '../extensions/category_extensions.dart';
import '../helpers/product_classifier.dart';
import '../helpers/price_formatter.dart';

/// HomePage - Main entry point for the eCommerce application
///
/// This page serves as the primary navigation hub displaying featured products,
/// promotional products, and quick access actions for core app functionality.
///
/// **Features:**
/// - Featured products section (high rating products from API)
/// - Promotional products section (low price products from API)
/// - Quick access cards for catalog, search, and cart
/// - Loading, success, and error states using ProductBloc
/// - Navigation to ProductDetailPage on product selection
/// - Smart product classification using business rules
///
/// **Business Rules:**
/// - Featured products: rating >= 4.0
/// - Promotional products: price < $50
///
/// **Design System Usage:**
/// - AppSection: Semantic blocks for featured, promotional and quick access sections
/// - AppCard: Quick action cards only
/// - AppText: Typography hierarchy throughout
/// - AppButton: Quick access actions
/// - AppSpacer: Consistent spacing
/// - AppEmptyStateSection: Error state handling
/// - ProductListTemplate: Product grid template from design system (TEMPLATE)
///
/// **State Management:**
/// - Uses ProductBloc for all products data fetching
/// - Product classification handled by ProductClassifier helper
/// - State derived from data presence (no explicit loading flags)
///
/// **Architecture:**
/// - HomePage: Main orchestration widget
/// - _FeaturedProductsSection: High-rated products display section
/// - _PromotionalProductsSection: Low-priced products display section
/// - _QuickActionsSection: Access shortcuts section
/// - Follows Atomic Design principles with proper separation
class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.productBlocFactory = initializeProductBloc,
    this.cartBlocFactory = initializeCartBloc,
  });

  final ProductBloc Function(ProductLoadedCallback onProductLoaded)
      productBlocFactory;
  final CartBloc Function(CartLoadedCallback onCartLoaded) cartBlocFactory;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  late final ProductBloc _productBloc;
  final List<Product> _allProducts = [];
  String? _errorMessage;

  /// Loading state derived from data presence
  bool get _isLoading => _allProducts.isEmpty && _errorMessage == null;

  @override
  void initState() {
    super.initState();
    
    // Initialize ProductBloc to load all products
    _productBloc = widget.productBlocFactory((productOrProducts) {
      if (mounted) {
        setState(() {
          // Handle different response types from the bloc
          if (productOrProducts is List<Product>) {
            // LoadProducts returns List<Product> directly
            _allProducts.clear();
            _allProducts.addAll(productOrProducts);
            _errorMessage = null;
          } else if (productOrProducts is String) {
            // Error case - the callback sends error messages as strings
            _errorMessage = productOrProducts;
            _allProducts.clear();
          }
        });
      }
    });

    // Load all products for classification
    _loadAllProducts();
  }

  void _loadAllProducts() {
    // Reset state
    setState(() {
      _allProducts.clear();
      _errorMessage = null;
    });

    // Load all products using LoadProducts event
    _productBloc.eventSink.add(LoadProducts());
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
                  cartBloc: widget.cartBlocFactory((state) {}),
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

    if (_allProducts.isNotEmpty) {
      return _buildSuccessState(_allProducts);
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
      description: 'We couldn\'t load the products. Please try again.',
      primaryAction: AppButton(
        text: 'Retry',
        onPressed: () {
          setState(() {
            _errorMessage = null;
            _allProducts.clear();
          });
          _loadAllProducts();
        },
      ),
    );
  }

  /// Main success state with featured products, promotional products and quick actions
  Widget _buildSuccessState(List<Product> products) {
    // Classify products using business rules
    final classification = ProductClassifier.classifyProducts(products);
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ATOM: Top spacing
          const AppSpacer(size: AppSpacerSize.large),
          
          // MOLECULE: Featured Products Section (High rating products)
          if (classification.hasFeaturedProducts)
            _FeaturedProductsSection(
              products: classification.featured.take(6).toList(), // Limit for better UX
              onProductTap: _navigateToProductDetail,
            ),
          
          // ATOM: Section spacing
          if (classification.hasFeaturedProducts && classification.hasPromotionalProducts)
            const AppSpacer(size: AppSpacerSize.extraLarge),
          
          // MOLECULE: Promotional Products Section (Low price products)
          if (classification.hasPromotionalProducts)
            _PromotionalProductsSection(
              products: classification.promotional.take(6).toList(), // Limit for better UX
              onProductTap: _navigateToProductDetail,
            ),
          
          // ATOM: Section spacing
          const AppSpacer(size: AppSpacerSize.extraLarge),
          
          // MOLECULE: Quick Actions Section
          _QuickActionsSection(
            allProducts: products,
            cartBlocFactory: widget.cartBlocFactory,
          ),
          
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
/// Shows products with high ratings (>= 4.0)
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
                        subtitle: product.category.displayName,
                        price: PriceFormatter.format(product.price),
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
}

/// MOLECULE: Promotional Products Section using ProductListTemplate
/// Uses design system template for optimal product display structure
/// Shows products with low prices (< $50)
class _PromotionalProductsSection extends StatelessWidget {
  const _PromotionalProductsSection({
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
        title: 'Special Offers',
        child: Column(
          children: [
            // ATOM: Section spacing
            const AppSpacer(size: AppSpacerSize.medium),
            
            // TEMPLATE: Product list template from design system
            ProductListTemplate(
              products: products
                  .map((product) => AppProductListItem(
                        title: product.title,
                        subtitle: product.category.displayName,
                        price: PriceFormatter.format(product.price),
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
}

/// MOLECULE: Quick Actions Section
/// Provides access to core app functionality
class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection({
    required this.allProducts,
    required this.cartBlocFactory,
  });

  final List<Product> allProducts;
  final CartBloc Function(CartLoadedCallback onCartLoaded) cartBlocFactory;

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
            
            // Cart and Support cards row
            Row(
              children: [
                // Cart access card
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.shopping_cart,
                    title: 'Shopping Cart',
                    subtitle: 'View your items',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CartPage(
                          cartBloc: cartBlocFactory((state) {}),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // ATOM: Horizontal spacing
                const AppSpacer(size: AppSpacerSize.medium),
                
                // Support access card
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.support_agent,
                    title: 'Support',
                    subtitle: 'Get help',
                    onTap: () => _navigateToSupport(context),
                  ),
                ),
              ],
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

  /// Navigate to support page
  void _navigateToSupport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SupportPage(),
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