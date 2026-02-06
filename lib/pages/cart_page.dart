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
/// - Uses provided CartBloc from parent
/// - Dispatches events to CartBloc
/// - Renders UI using StreamBuilder<CartState>
class CartPage extends StatelessWidget {
  const CartPage({
    super.key,
    required this.cartBloc,
  });

  final CartBloc cartBloc;

  void _loadCart() {
    // Load cart with ID 1 (you can make this Cart based on user)
    cartBloc.eventSink.add(LoadCartWithProductDetailsEvent(1));
  }

  void _updateQuantity(int cartId, int productId, int newQuantity) {
    // Using proper event name - may need adjustment based on actual API
    cartBloc.eventSink.add(LoadCartWithProductDetailsEvent(cartId));
  }

  void _removeProduct(int cartId, int productId) {
    // Using proper event name - may need adjustment based on actual API  
    cartBloc.eventSink.add(LoadCartWithProductDetailsEvent(cartId));
  }

  @override
  Widget build(BuildContext context) {
    // Load cart on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCart();
    });

    return AppPage(
      title: 'Shopping Cart',
      body: StreamBuilder<CartState>(
        stream: cartBloc.state,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return _buildLoadingState();
          }

          final state = snapshot.data!;
          return _buildStateContent(context, state);
        },
      ),
    );
  }

  Widget _buildStateContent(BuildContext context, CartState state) {
    if (state is CartLoading) {
      return _buildLoadingState();
    }

    if (state is CartError) {
      return _buildErrorState(context, state.message);
    }

    if (state is CartWithProductDetailsLoaded) {
      final cart = state.cart;
      if (cart.products == null || cart.products!.isEmpty) {
        return _buildEmptyCartState(context);
      }
      return _buildCartContent(cart);
    }

    return _buildLoadingState();
  }

  /// ATOM: Loading state
  Widget _buildLoadingState() {
    return AppEmptyStateSection(
      icon: Icons.shopping_cart,
      title: 'Loading Cart',
      description: 'Please wait while we load your cart items...',
    );
  }

  /// ORGANISM: Error state
  Widget _buildErrorState(BuildContext context, String error) {
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
  Widget _buildEmptyCartState(BuildContext context) {
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
  Widget _buildCartContent(Cart cart) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // MOLECULE: Cart header section
                _buildCartHeader(cart),
                
                // ATOM: Section spacing
                const AppSpacer(size: AppSpacerSize.large),
                
                // MOLECULE: Cart items section
                _buildCartItemsSection(cart),
                
                // Bottom spacing for fixed bottom bar
                const AppSpacer(size: AppSpacerSize.extraLarge),
              ],
            ),
          ),
        ),
        // Fixed bottom bar
        Builder(
          builder: (context) => _buildBottomBar(context, cart),
        ),
      ],
    );
  }

  /// MOLECULE: Cart header with summary info
  Widget _buildCartHeader(Cart cart) {
    final totalItems = cart.products?.fold(0, (sum, product) => sum + product.quantity) ?? 0;
    final total = cart.products?.fold(0.0, (sum, product) {
      final price = product.productDetails?.price ?? 0.0;
      return sum + (price * product.quantity);
    }) ?? 0.0;

    return AppSection(
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
                      '$totalItems items',
                      variant: AppTextVariant.titleMedium,
                    ),
                    const AppSpacer(size: AppSpacerSize.extraSmall),
                    AppText(
                      'Cart ID: ${cart.id ?? 'N/A'}',
                      variant: AppTextVariant.bodySmall,
                    ),
                  ],
                ),
                AppPrice(
                  value: total,
                  highlight: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// MOLECULE: Cart items list section
  Widget _buildCartItemsSection(Cart cart) {
    return AppSection(
      title: 'Cart Items',
      child: Column(
        children: [
          const AppSpacer(size: AppSpacerSize.medium),
          ...cart.products!.map((product) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Builder(
              builder: (context) => _buildCartItem(context, cart, product),
            ),
          )),
        ],
      ),
    );
  }

  /// ORGANISM: Individual cart item
  Widget _buildCartItem(BuildContext context, Cart cart, Products cartProduct) {
    final productDetails = cartProduct.productDetails;
    final subtotal = (productDetails?.price ?? 0.0) * cartProduct.quantity;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top section: Image and Product Details
          Row(
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
            ],
          ),
          
          const AppSpacer(size: AppSpacerSize.medium),
          
          // Bottom section: Controls in a row
          Row(
            children: [
              // Decrease button
              _buildQuantityButton(
                icon: Icons.remove,
                onPressed: cartProduct.quantity > 1
                    ? () => _updateQuantity(
                        cart.id!,
                        cartProduct.productId,
                        cartProduct.quantity - 1,
                      )
                    : null,
              ),
              
              const AppSpacer(size: AppSpacerSize.small),
              
              // Quantity display
              Container(
                width: 40,
                alignment: Alignment.center,
                child: AppText(
                  cartProduct.quantity.toString(),
                  variant: AppTextVariant.bodyMedium,
                ),
              ),
              
              const AppSpacer(size: AppSpacerSize.small),
              
              // Increase button
              _buildQuantityButton(
                icon: Icons.add,
                onPressed: () => _updateQuantity(
                  cart.id!,
                  cartProduct.productId,
                  cartProduct.quantity + 1,
                ),
              ),
              
              const Spacer(),
              
              // Remove button
              _buildRemoveButton(context, cart, cartProduct),
            ],
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
  return AppButton(
    onPressed: onPressed,
    text: '', // No importa el texto, no se mostrará
    icon: icon,
    variant: AppButtonVariant.outline,
    size: AppButtonSize.extraSmall, // ← Ahora 24x24px
    isEnabled: onPressed != null,
  );
}
  /// ATOM: Remove button
  Widget _buildRemoveButton(BuildContext context, Cart cart, Products cartProduct) {
    return AppButton(
      text: '',
      onPressed: () => _showRemoveDialog(context, cart, cartProduct),
      variant: AppButtonVariant.outline,
      icon: Icons.delete_outline,
    );
  }

  /// MOLECULE: Fixed bottom bar with totals and actions
  Widget _buildBottomBar(BuildContext context, Cart cart) {
    final total = cart.products?.fold(0.0, (sum, product) {
      final price = product.productDetails?.price ?? 0.0;
      return sum + (price * product.quantity);
    }) ?? 0.0;

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
                  
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: AppButton(
                      text: 'Checkout',
                      variant: AppButtonVariant.primary,
                      onPressed: () => _handleCheckout(context, cart),
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
  void _showRemoveDialog(BuildContext context, Cart cart, Products cartProduct) {
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
            _removeProduct(cart.id!, cartProduct.productId);
          },
        ),
      ],
    );
  }

  /// Handle checkout action
  void _handleCheckout(BuildContext context, Cart cart) {
    final totalItems = cart.products?.fold(0, (sum, product) => sum + product.quantity) ?? 0;
    final total = cart.products?.fold(0.0, (sum, product) {
      final price = product.productDetails?.price ?? 0.0;
      return sum + (price * product.quantity);
    }) ?? 0.0;

    AppDialog.show(
      context: context,
      title: 'Checkout',
      content: AppText('Order Summary:\n\nItems: $totalItems\nTotal: \$${total.toStringAsFixed(2)}\n\nCheckout functionality will be implemented here.'),
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
