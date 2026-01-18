import 'package:flutter/material.dart';
import 'package:fake_maker_api_pragma_api/fake_maker_api_pragma_api.dart';
import 'package:pragma_design_system/pragma_design_system.dart';

/// ProductDetailPage - A comprehensive product detail view for eCommerce
///
/// This page displays detailed product information using the design system
/// components and handles loading, success, and error states through ProductBloc.
/// 
/// **Features:**
/// - Clean, responsive product detail layout
/// - Loading state with circular progress indicator
/// - Error handling with AppEmptyStateSection
/// - Product image, title, price, category, and description display
/// - Primary CTA button for adding to cart
/// - Scroll support for content overflow
///
/// **Design System Usage:**
/// - AppImage: Product image display with network loading
/// - AppText: Typography hierarchy (title, subtitle, body)
/// - AppPrice: Formatted price display
/// - AppSection: Structured content sections
/// - AppSpacer: Consistent spacing
/// - AppButton: Primary CTA button
/// - AppEmptyStateSection: Error state handling
///
/// **State Management:**
/// - Uses ProductBloc for data fetching
/// - Dispatches LoadProduct event on initialization
/// - Listens to ProductState stream for UI updates
///
/// **Layout Structure:**
/// 1. Product image (full width, fixed height)
/// 2. Product title (large, bold)
/// 3. Product price (highlighted)
/// 4. Product category (secondary text)
/// 5. Product description (in its own section)
/// 6. Add to cart button (bottom, primary action)
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
  bool _isLoading = false;

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
            _isLoading = false;
          } else if (productOrProducts is ProductDeleted) {
            _loadedProduct = productOrProducts.product;
            _errorMessage = null;
            _isLoading = false;
          } else if (productOrProducts is String) {
            // Error case - the callback sometimes sends error messages as strings
            _errorMessage = productOrProducts;
            _loadedProduct = null;
            _isLoading = false;
          }
        });
      }
    });

    // Set initial loading state
    setState(() {
      _isLoading = true;
    });

    // Load the product data
    _productBloc.eventSink.add(LoadProduct(widget.productId));
  }

  @override
  void dispose() {
    // Clean up resources
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: _buildBody(),
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
          // Retry loading the product
          setState(() {
            _isLoading = true;
            _errorMessage = null;
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
  Widget _buildSuccessState(Product product) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Product Image Section
          _buildProductImage(product),
          
          const AppSpacer(size: AppSpacerSize.large),
          
          // Product Information Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Title
                _buildProductTitle(product),
                
                const AppSpacer(size: AppSpacerSize.medium),
                
                // Product Price
                _buildProductPrice(product),
                
                const AppSpacer(size: AppSpacerSize.small),
                
                // Product Category
                _buildProductCategory(product),
                
                const AppSpacer(size: AppSpacerSize.large),
                
                // Product Description Section
                _buildProductDescription(product),
                
                const AppSpacer(size: AppSpacerSize.extraLarge),
                
                // Add to Cart Button
                _buildAddToCartButton(),
                
                const AppSpacer(size: AppSpacerSize.large),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the product image section
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

  /// Builds the product title
  Widget _buildProductTitle(Product product) {
    return AppText(
      product.title,
      variant: AppTextVariant.headlineSmall,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Builds the product price display
  Widget _buildProductPrice(Product product) {
    return AppText(
      '\$${product.price.toStringAsFixed(2)}',
      variant: AppTextVariant.titleLarge,
      color: Theme.of(context).colorScheme.primary,
    );
  }

  /// Builds the product category display
  Widget _buildProductCategory(Product product) {
    return AppText(
      _formatCategoryName(product.category),
      variant: AppTextVariant.titleMedium,
      color: Theme.of(context).colorScheme.secondary,
    );
  }

  /// Builds the product description section
  Widget _buildProductDescription(Product product) {
    return AppSection(
      title: 'Description',
      child: AppText(
        product.description,
        variant: AppTextVariant.bodyLarge,
        textAlign: TextAlign.justify,
      ),
    );
  }

  /// Builds the add to cart button
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