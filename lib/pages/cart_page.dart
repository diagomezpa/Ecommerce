import 'package:flutter/material.dart';
import 'package:fake_maker_api_pragma_api/fake_maker_api_pragma_api.dart';
import 'package:pragma_design_system/pragma_design_system.dart';

/// CartPage - Shopping cart management for the eCommerce application
///
/// This page displays the shopping cart with product details, quantity management,
/// item removal, and total calculation.
///
/// **Features:**
/// - Lista de productos en carrito with product details
/// - Quantity controls (+ / - buttons)
/// - Remove product functionality with confirmation
/// - Total calculation and display
/// - Empty cart state handling
/// - Loading and error states
///
/// **Design System Usage:**
/// - AppPage: Main page structure
/// - AppSection: Content sections
/// - AppCard: Item cards and surfaces
/// - AppButton: Action buttons
/// - AppText: Typography hierarchy
/// - AppSpacer: Consistent spacing
/// - AppImage: Product images
/// - AppPrice: Price formatting
/// - AppEmptyStateSection: Empty and error states
///
/// **State Management:**
/// - Uses CartBloc with LoadCartWithProductDetailsEvent
/// - Handles cart updates and deletions
/// - State derived from cart data presence
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late final CartBloc cartBloc;
  Cart? cart;
  String? errorMessage;
  
  /// Loading state derived from cart data presence
  bool get isLoading => cart == null && errorMessage == null;

  @override
  void initState() {
    super.initState();
    _initializeCartBloc();
    _loadCart();
  }

  void _initializeCartBloc() {
    cartBloc = initializeCartBloc((cartState) {
      // Handle cart state changes
    });

    cartBloc.state.listen((state) {
      if (mounted) {
        setState(() {
          if (state is CartWithProductDetailsLoaded) {
            cart = state.cart;
            errorMessage = null;
          } else if (state is CartUpdated) {
            // Reload cart after update
            _loadCart();
          } else if (state is CartDeleted) {
            // Handle cart deletion
            cart = state.cart;
            errorMessage = null;
          }
        });
      }
    });
  }

  void _loadCart() {
    // Load cart with ID 1 (you can make this Cart based on user)
    cartBloc.eventSink.add(LoadCartWithProductDetailsEvent(1));
  }

  void _updateQuantity(int productId, int newQuantity) {
    if (cart != null && cart!.products != null) {
      // For now, just update locally - in a real app you'd implement proper cart update
      final updatedProducts = cart!.products!.map((product) {
        if (product.productId == productId) {
          // Since we don't have copyWith, we'll create a simplified update
          // In practice, you'd use your API's cart update functionality
          product.quantity = newQuantity;
        }
        return product;
      }).toList();

      setState(() {
        cart = Cart(
          id: cart!.id,
          userId: cart!.userId,
          date: cart!.date,
          products: updatedProducts,
        );
      });

      // Note: In real implementation, you'd call the appropriate cart update API
      // cartBloc.eventSink.add(UpdateCartEvent(cart!.id!));
    }
  }

  void _removeProduct(int productId) {
    if (cart != null && cart!.products != null) {
      final updatedProducts = cart!.products!
          .where((product) => product.productId != productId)
          .toList();

      setState(() {
        cart = Cart(
          id: cart!.id,
          userId: cart!.userId,
          date: cart!.date,
          products: updatedProducts,
        );
      });

      // Note: In real implementation, you'd call the appropriate cart update API
      // cartBloc.eventSink.add(UpdateCartEvent(cart!.id!));
    }
  }

  double _calculateTotal() {
    if (cart?.products == null) return 0.0;
    
    return cart!.products!.fold(0.0, (total, product) {
      final price = product.productDetails?.price ?? 0.0;
      return total + (price * product.quantity);
    });
  }

  int _getTotalItems() {
    if (cart?.products == null) return 0;
    
    return cart!.products!.fold(0, (total, product) {
      return total + product.quantity;
    });
  }

  @override
  void dispose() {
    cartBloc.eventSink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppText(
          'Shopping Cart',
          variant: AppTextVariant.titleLarge,
        ),
        elevation: 0,
      ),
      body: _buildBody(),
      bottomNavigationBar: cart?.products?.isNotEmpty == true 
          ? _buildBottomBar() 
          : null,
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (errorMessage != null) {
      return _buildErrorState(errorMessage!);
    }

    if (cart?.products == null || cart!.products!.isEmpty) {
      return _buildEmptyCartState();
    }

    return _buildCartContent();
  }

  /// ATOM: Loading state
  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  /// ORGANISM: Error state
  Widget _buildErrorState(String error) {
    return AppEmptyStateSection(
      icon: Icons.error_outline,
      title: 'Error Loading Cart',
      description: error,
      primaryAction: AppButton(
        text: 'Try Again',
        onPressed: _loadCart,
      ),
      secondaryAction: AppButton(
        text: 'Go Back',
        variant: AppButtonVariant.outline,
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  /// ORGANISM: Empty cart state
  Widget _buildEmptyCartState() {
    return AppEmptyStateSection(
      icon: Icons.shopping_cart_outlined,
      title: 'Your Cart is Empty',
      description: 'Add some products to get started shopping',
      primaryAction: AppButton(
        text: 'Continue Shopping',
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  /// Main cart content with products
  Widget _buildCartContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ATOM: Top spacing
          const AppSpacer(size: AppSpacerSize.large),
          
          // MOLECULE: Cart header section
          _buildCartHeader(),
          
          // ATOM: Section spacing
          const AppSpacer(size: AppSpacerSize.large),
          
          // MOLECULE: Cart items section
          _buildCartItemsSection(),
          
          // Bottom spacing for fixed bottom bar
          const AppSpacer(size: AppSpacerSize.extraLarge),
          const AppSpacer(size: AppSpacerSize.extraLarge),
        ],
      ),
    );
  }

  /// MOLECULE: Cart header with summary info
  Widget _buildCartHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: AppSection(
        title: 'Cart Summary',
        child: Column(
          children: [
            const AppSpacer(size: AppSpacerSize.small),
            AppCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        '${_getTotalItems()} items',
                        variant: AppTextVariant.titleMedium,
                      ),
                      const AppSpacer(size: AppSpacerSize.extraSmall),
                      AppText(
                        'Cart ID: ${cart?.id ?? 'N/A'}',
                        variant: AppTextVariant.bodySmall,
                      ),
                    ],
                  ),
                  AppPrice(
                    value: _calculateTotal(),
                    highlight: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// MOLECULE: Cart items list section
  Widget _buildCartItemsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: AppSection(
        title: 'Cart Items',
        child: Column(
          children: [
            const AppSpacer(size: AppSpacerSize.medium),
            ...cart!.products!.map((product) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _buildCartItem(product),
            )),
          ],
        ),
      ),
    );
  }

  /// ORGANISM: Individual cart item
  Widget _buildCartItem(dynamic cartProduct) {
    final productDetails = cartProduct.productDetails;
    final subtotal = (productDetails?.price ?? 0.0) * cartProduct.quantity;

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          AppImage(
            imageUrl: productDetails?.image ?? '',
            width: 80,
            height: 80,
            fit: BoxFit.contain,
          ),
          
          const AppSpacer(size: AppSpacerSize.medium),
          
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  productDetails?.title ?? 'Product ID: ${cartProduct.productId}',
                  variant: AppTextVariant.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const AppSpacer(size: AppSpacerSize.small),
                
                AppPrice(
                  value: productDetails?.price ?? 0.0,
                ),
                
                const AppSpacer(size: AppSpacerSize.small),
                
                AppText(
                  'Subtotal: \$${subtotal.toStringAsFixed(2)}',
                  variant: AppTextVariant.bodyMedium,
                ),
              ],
            ),
          ),
          
          const AppSpacer(size: AppSpacerSize.medium),
          
          // Quantity Controls and Remove Button
          Column(
            children: [
              _buildQuantityControls(cartProduct),
              const AppSpacer(size: AppSpacerSize.small),
              _buildRemoveButton(cartProduct),
            ],
          ),
        ],
      ),
    );
  }

  /// MOLECULE: Quantity controls
  Widget _buildQuantityControls(Products cartProduct) {
    return AppCard(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrease button
          _buildQuantityButton(
            icon: Icons.remove,
            onPressed: cartProduct.quantity > 1
                ? () => _updateQuantity(
                    cartProduct.productId,
                    cartProduct.quantity - 1,
                  )
                : null,
          ),
          
          // Quantity display
          Container(
            width: 40,
            alignment: Alignment.center,
            child: AppText(
              cartProduct.quantity.toString(),
              variant: AppTextVariant.bodyMedium,
            ),
          ),
          
          // Increase button
          _buildQuantityButton(
            icon: Icons.add,
            onPressed: () => _updateQuantity(
              cartProduct.productId,
              cartProduct.quantity + 1,
            ),
          ),
        ],
      ),
    );
  }

  /// ATOM: Individual quantity button
  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton(
        onPressed: onPressed,
        icon: AppIcon(
          icon,
          size: AppIconSize.small,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }

  /// ATOM: Remove button
  Widget _buildRemoveButton(Products cartProduct) {
    return IconButton(
      onPressed: () => _showRemoveDialog(cartProduct),
      icon: const AppIcon(
        Icons.delete_outline,
        color: Colors.red,
        size: AppIconSize.small,
      ),
    );
  }

  /// MOLECULE: Fixed bottom bar with totals and actions
  Widget _buildBottomBar() {
    final total = _calculateTotal();
    
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AppCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Total display
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    'Total:',
                    variant: AppTextVariant.titleLarge,
                  ),
                  AppPrice(
                    value: total,
                    highlight: true,
                  ),
                ],
              ),
              
              const AppSpacer(size: AppSpacerSize.medium),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Continue Shopping',
                      variant: AppButtonVariant.outline,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  
                  const AppSpacer(size: AppSpacerSize.medium),
                  
                  Expanded(
                    child: AppButton(
                      text: 'Checkout',
                      variant: AppButtonVariant.primary,
                      onPressed: _handleCheckout,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show remove item confirmation dialog
  void _showRemoveDialog(Products cartProduct) {
    AppDialog.show(
      context: context,
      title: 'Remove Item',
       content: AppText('Are you sure you want to remove "${cartProduct.productDetails?.title ?? 'this item'}" from your cart?'),
      
      actions: [
        AppButton(
          text: 'Cancel',
          variant: AppButtonVariant.outline,
          onPressed: () => Navigator.pop(context),
        ),
        AppButton(
          text: 'Remove',
          variant: AppButtonVariant.primary,
          onPressed: () {
            Navigator.pop(context);
            _removeProduct(cartProduct.productId);
          },
        ),
      ],
    );
  }

  /// Handle checkout action
  void _handleCheckout() {
    AppDialog.show(
      context: context,
      title: 'Checkout',
      content: AppText('Order Summary:\n\nItems: ${_getTotalItems()}\nTotal: \$${_calculateTotal().toStringAsFixed(2)}\n\nCheckout functionality will be implemented here.'),
      actions: [
        AppButton(
          text: 'OK',
          variant: AppButtonVariant.primary,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
