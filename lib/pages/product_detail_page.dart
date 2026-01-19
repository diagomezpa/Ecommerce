import 'package:flutter/material.dart';
import 'package:fake_maker_api_pragma_api/fake_maker_api_pragma_api.dart';
import 'package:pragma_design_system/pragma_design_system.dart';

/// ProductDetailPage - A comprehensive product detail view for eCommerce
///
/// This page displays detailed product information using the design system
/// components and handles loading, success, and error states through ProductBloc.
/// 
/// **Features:**
/// - Clean, responsive product detail layout with fixed bottom CTA
/// - Loading state derived from product data presence
/// - Error handling with AppEmptyStateSection
/// - Product image, title, price, category badge, and description display
/// - Fixed primary CTA button for optimal accessibility
/// - Scroll support for main content with preserved bottom action
///
/// **Design System Usage:**
/// - AppImage: Product image display with network loading
/// - AppText: Typography hierarchy (title, subtitle, body)
/// - AppPrice: Formatted price display with consistent styling
/// - AppSection: Structured content sections
/// - AppSpacer: Consistent spacing throughout
/// - AppButton: Primary CTA button
/// - AppEmptyStateSection: Error state handling
/// - Container: Category badge with design system colors
///
/// **State Management:**
/// - Uses ProductBloc for data fetching
/// - Dispatches LoadProduct event on initialization
/// - State derived from data presence (eliminates explicit loading flag)
///
/// **Layout Structure:**
/// 1. Product image (full width, fixed height)
/// 2. Product title (large, bold)
/// 3. Product price (using AppPrice component)
/// 4. Product category (styled badge)
/// 5. Product description (in its own section)
/// 6. Fixed add to cart button (bottom, always accessible)
class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({
    super.key,
    required this.productId,
  });

  /// The ID of the product to display
  final int productId;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late final ProductBloc _productBloc;
  Product? _loadedProduct;
  String? _errorMessage;

  /// Loading state is derived from data presence
  bool get _isLoading => _loadedProduct == null && _errorMessage == null;

  @override
  void initState() {
    super.initState();
    
    // Initialize ProductBloc with the correct callback pattern
    _productBloc = initializeProductBloc((productOrProducts) {
      if (mounted) {
        setState(() {
          if (productOrProducts is Product) {
            _loadedProduct = productOrProducts;
            _errorMessage = null;
          } else if (productOrProducts is ProductDeleted) {
            _loadedProduct = productOrProducts.product;
            _errorMessage = null;
          } else if (productOrProducts is String) {
            // Error case - the callback sometimes sends error messages as strings
            _errorMessage = productOrProducts;
            _loadedProduct = null;
          }
        });
      }
    });

    // Load the product data (loading state derived automatically)
    _productBloc.eventSink.add(LoadProduct(widget.productId));
  }

  @override
  void dispose() {
    // Note: eventSink.close() is handled here since ProductBloc doesn't expose
    // a dispose() method. This ensures proper cleanup of the stream.
    _productBloc.eventSink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppText(
          'Product Details',
          variant: AppTextVariant.titleLarge,
        ),
        elevation: 0,
      ),
      body: _buildBody(),
      bottomNavigationBar: _loadedProduct != null 
          ? _buildFixedBottomCTA(_loadedProduct!)
          : null,
    );
  }

  /// Builds the main body content based on current state
  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_loadedProduct != null) {
      return _buildSuccessState(_loadedProduct!);
    }

    if (_errorMessage != null) {
      return _buildErrorState(_errorMessage!);
    }

    // Initial state - show loading
    return _buildLoadingState();
  }

  /// Builds the loading state UI
  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  /// Builds the error state UI using AppEmptyStateSection
  Widget _buildErrorState(String errorMessage) {
    return AppEmptyStateSection(
      icon: Icons.error_outline,
      title: 'Unable to Load Product',
      description: errorMessage,
      primaryAction: AppButton(
        text: 'Try Again',
        onPressed: () {
          // Retry loading the product (reset state and reload)
          setState(() {
            _errorMessage = null;
            _loadedProduct = null;
          });
          _productBloc.eventSink.add(LoadProduct(widget.productId));
        },
      ),
      secondaryAction: AppButton(
        text: 'Go Back',
        variant: AppButtonVariant.outline,
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  /// Builds the success state UI with product information
  /// Uses Design System components exclusively following Atomic Design
  Widget _buildSuccessState(Product product) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ATOM: Product Image with height constraint only
          _buildProductImage(product),
          
          // ATOM: Spacing
          const AppSpacer(size: AppSpacerSize.large),
          
          // MOLECULE: Main product info wrapped in AppCard surface
          _buildProductInfoCard(product),
          
          // ATOM: Spacing
          const AppSpacer(size: AppSpacerSize.medium),
          
          // MOLECULE: Description section using AppSection
          _buildProductDescription(product),
          
          // Bottom spacing for fixed CTA
          const AppSpacer(size: AppSpacerSize.extraLarge),
        ],
      ),
    );
  }

  /// ATOM: Product image with technical constraints only
  Widget _buildProductImage(Product product) {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: AppImage(
        imageUrl: product.image,
        fit: BoxFit.contain,
        semanticLabel: 'Image of ${product.title}',
      ),
    );
  }

  /// MOLECULE: Product info card - wraps main product data in AppCard surface
  Widget _buildProductInfoCard(Product product) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ATOM: Product title
            _buildProductTitle(product),
            
            // ATOM: Spacing
            const AppSpacer(size: AppSpacerSize.medium),
            
            // MOLECULE: Price component
            _buildProductPrice(product),
            
            // ATOM: Spacing
            const AppSpacer(size: AppSpacerSize.small),
            
            // MOLECULE: Category badge using AppCard
            _buildProductCategoryBadge(product),
          ],
        ),
      ),
    );
  }

  /// ATOM: Product title text
  Widget _buildProductTitle(Product product) {
    return AppText(
      product.title,
      variant: AppTextVariant.headlineSmall,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// MOLECULE: Product price using AppPrice component
  Widget _buildProductPrice(Product product) {
    return AppPrice(
      value: product.price,
      highlight: true,
    );
  }

  /// MOLECULE: Product category badge using AppCard for visual surface
  /// No Container styling - AppCard provides the semantic surface
  Widget _buildProductCategoryBadge(Product product) {
    return SizedBox(
      width: 120, // Technical constraint only
      child: AppCard(
        child: AppText(
          _formatCategoryName(product.category),
          variant: AppTextVariant.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// MOLECULE: Product description using AppSection semantic block
  Widget _buildProductDescription(Product product) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: AppSection(
        title: 'Description',
        child: AppText(
          product.description,
          variant: AppTextVariant.bodyLarge,
          textAlign: TextAlign.justify,
        ),
      ),
    );
  }

  /// ATOM: Add to cart button
  Widget _buildAddToCartButton() {
    return SizedBox(
      width: double.infinity,
      child: AppButton(
        text: 'Add to Cart',
        variant: AppButtonVariant.primary,
        size: AppButtonSize.large,
        icon: Icons.shopping_cart,
        onPressed: () {
          // Handle add to cart action
          _handleAddToCart();
        },
      ),
    );
  }

  /// MOLECULE: Fixed bottom CTA using AppCard for visual surface
  /// SafeArea is technical wrapper, AppCard provides semantic surface
  Widget _buildFixedBottomCTA(Product product) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AppCard(
          child: _buildAddToCartButton(),
        ),
      ),
    );
  }

  /// Handles the add to cart action
  void _handleAddToCart() {
    // Show confirmation snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Product added to cart!'),
        duration: Duration(seconds: 2),
      ),
    );
    
    // Here you would typically:
    // 1. Dispatch an event to CartBloc to add the product
    // 2. Navigate to cart or show success feedback
    // 3. Update any cart counters or badges
    // For this demo, we're just showing a snackbar
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