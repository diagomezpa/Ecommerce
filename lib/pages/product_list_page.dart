import 'package:flutter/material.dart';
import 'package:fake_maker_api_pragma_api/fake_maker_api_pragma_api.dart';
import 'package:pragma_design_system/pragma_design_system.dart';
import 'product_detail_page.dart';

/// ProductListPage - Complete catalog view for the eCommerce application
///
/// This page displays the complete product catalog with category filtering
/// capabilities, providing users with a comprehensive browsing experience.
///
/// **Features:**
/// - Complete product catalog from API using LoadProducts
/// - Category filtering (Electronics, Jewelry, Men's, Women's) in UI only
/// - No backend calls for filtering - operates on loaded data
/// - Loading, success, and error states using ProductBloc
/// - Navigation to ProductDetailPage on product selection
/// - Scroll support for large product lists
///
/// **Design System Usage:**
/// - AppSection: Semantic blocks for filters and product listing
/// - AppCard: Surface for filter chips
/// - AppText: Typography hierarchy throughout
/// - AppButton: Filter actions and error retries
/// - AppSpacer: Consistent spacing
/// - AppEmptyStateSection: Error and empty state handling
/// - ProductListTemplate: Main product grid template from design system (TEMPLATE)
///
/// **State Management:**
/// - Uses ProductBloc with LoadProducts for all products
/// - Client-side filtering by category (no new API calls)
/// - State derived from data presence for loading indication
///
/// **Architecture:**
/// - ProductListPage: Main orchestration widget
/// - _ProductFilterSection: Category filter controls
/// - _ProductListSection: Products display section
/// - Follows Atomic Design principles with proper separation
///
/// **Key Differences from HomePage:**
/// - Loads ALL products vs featured subset (6 items)
/// - Includes category filtering functionality
/// - Different UI layout focused on browsing vs discovery
/// - Uses LoadProducts event vs individual LoadProduct calls
/// - Optimized for catalog browsing vs quick access
class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late final ProductBloc _productBloc;
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  String? _errorMessage;
  Category? _selectedCategory;
  
  /// Loading state derived from data presence
  bool get _isLoading => _allProducts.isEmpty && _errorMessage == null;

  /// Available categories for filtering
  static const List<Category> _availableCategories = [
    Category.ELECTRONICS,
    Category.JEWELERY,
    Category.MENS_CLOTHING,
    Category.WOMENS_CLOTHING,
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize ProductBloc to load all products
    _productBloc = initializeProductBloc((productOrProducts) {
      if (mounted) {
        setState(() {
          // Handle different response types from the bloc
          if (productOrProducts is List<Product>) {
            // LoadProducts returns List<Product> directly
            _allProducts = productOrProducts;
            _filteredProducts = _allProducts;
            _errorMessage = null;
            _applyCurrentFilter();
          } else if (productOrProducts is String) {
            // Error case - the callback sends error messages as strings
            _errorMessage = productOrProducts;
            _allProducts.clear();
            _filteredProducts.clear();
          }
        });
      }
    });

    // Load all products
    _loadAllProducts();
  }

  void _loadAllProducts() {
    // Reset state
    setState(() {
      _allProducts.clear();
      _filteredProducts.clear();
      _errorMessage = null;
      _selectedCategory = null;
    });

    // Load all products using LoadProducts event
    _productBloc.eventSink.add(LoadProducts());
  }

  /// Apply category filter to the loaded products
  void _applyCurrentFilter() {
    if (_selectedCategory == null) {
      _filteredProducts = List.from(_allProducts);
    } else {
      _filteredProducts = _allProducts
          .where((product) => product.category == _selectedCategory)
          .toList();
    }
  }

  /// Handle category selection
  void _onCategorySelected(Category? category) {
    setState(() {
      _selectedCategory = category;
      _applyCurrentFilter();
    });
  }

  @override
  void dispose() {
    // Clean up ProductBloc resources
    _productBloc.eventSink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppText(
          'Product Catalog',
          variant: AppTextVariant.titleLarge,
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
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
      return _buildSuccessState();
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
      icon: Icons.error_outline,
      title: 'Unable to Load Catalog',
      description: 'We couldn\'t load the product catalog. Please try again.',
      primaryAction: AppButton(
        text: 'Retry',
        onPressed: () {
          setState(() {
            _errorMessage = null;
            _allProducts.clear();
            _filteredProducts.clear();
          });
          _loadAllProducts();
        },
      ),
    );
  }

  /// Main success state with filter controls and product grid
  Widget _buildSuccessState() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ATOM: Top spacing
          const AppSpacer(size: AppSpacerSize.large),
          
          // MOLECULE: Product Filter Section
          _ProductFilterSection(
            availableCategories: _availableCategories,
            selectedCategory: _selectedCategory,
            onCategorySelected: _onCategorySelected,
            totalProductCount: _allProducts.length,
            filteredProductCount: _filteredProducts.length,
          ),
          
          // ATOM: Section spacing
          const AppSpacer(size: AppSpacerSize.large),
          
          // MOLECULE: Product List Section
          _ProductListSection(
            products: _filteredProducts,
            selectedCategory: _selectedCategory,
            onProductTap: _navigateToProductDetail,
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

/// MOLECULE: Product Filter Section
/// Provides category filtering controls and result counts
class _ProductFilterSection extends StatelessWidget {
  const _ProductFilterSection({
    required this.availableCategories,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.totalProductCount,
    required this.filteredProductCount,
  });

  final List<Category> availableCategories;
  final Category? selectedCategory;
  final Function(Category?) onCategorySelected;
  final int totalProductCount;
  final int filteredProductCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: AppSection(
        title: 'Filter by Category',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ATOM: Section spacing
            const AppSpacer(size: AppSpacerSize.medium),
            
            // MOLECULE: Filter chips row
            _buildFilterChips(context),
            
            // ATOM: Filter spacing
            const AppSpacer(size: AppSpacerSize.medium),
            
            // ATOM: Results count
            _buildResultsCount(context),
          ],
        ),
      ),
    );
  }

  /// MOLECULE: Filter chips using AppCard surfaces
  Widget _buildFilterChips(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: [
        // "All" filter chip
        _FilterChip(
          label: 'All',
          isSelected: selectedCategory == null,
          onTap: () => onCategorySelected(null),
        ),
        
        // Category filter chips
        ...availableCategories.map((category) => _FilterChip(
          label: _formatCategoryName(category),
          isSelected: selectedCategory == category,
          onTap: () => onCategorySelected(category),
        )),
      ],
    );
  }

  /// ATOM: Results count text
  Widget _buildResultsCount(BuildContext context) {
    final String countText = selectedCategory == null
        ? 'Showing all $totalProductCount products'
        : 'Showing $filteredProductCount of $totalProductCount products';
    
    return AppText(
      countText,
      variant: AppTextVariant.bodyMedium,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
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

/// ATOM: Filter Chip using AppCard surface
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: isSelected 
                ? Theme.of(context).colorScheme.primaryContainer
                : null,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: AppText(
            label,
            variant: AppTextVariant.labelLarge,
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

/// MOLECULE: Product List Section using ProductListTemplate
/// Displays the filtered product grid with proper empty state handling
class _ProductListSection extends StatelessWidget {
  const _ProductListSection({
    required this.products,
    required this.selectedCategory,
    required this.onProductTap,
  });

  final List<Product> products;
  final Category? selectedCategory;
  final Function(Product) onProductTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: AppSection(
        title: _buildSectionTitle(),
        child: Column(
          children: [
            // ATOM: Section spacing
            const AppSpacer(size: AppSpacerSize.medium),
            
            // Conditional content based on filtered results
            if (products.isEmpty)
              _buildEmptyFilterState(context)
            else
              _buildProductGrid(),
          ],
        ),
      ),
    );
  }

  /// Dynamic section title based on selected filter
  String _buildSectionTitle() {
    if (selectedCategory == null) {
      return 'All Products';
    }
    
    switch (selectedCategory!) {
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

  /// TEMPLATE: Product grid using ProductListTemplate from design system
  Widget _buildProductGrid() {
    return ProductListTemplate(
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
    );
  }

  /// ORGANISM: Empty filter state using design system components
  Widget _buildEmptyFilterState(BuildContext context) {
    return Column(
      children: [
        // ATOM: Empty state spacing
        const AppSpacer(size: AppSpacerSize.extraLarge),
        
        // ATOM: Empty state icon
        Icon(
          Icons.filter_list_off,
          size: 64,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        
        // ATOM: Icon spacing
        const AppSpacer(size: AppSpacerSize.medium),
        
        // ATOM: Empty state title
        AppText(
          'No products found',
          variant: AppTextVariant.titleMedium,
          textAlign: TextAlign.center,
        ),
        
        // ATOM: Title spacing
        const AppSpacer(size: AppSpacerSize.small),
        
        // ATOM: Empty state description
        AppText(
          'Try selecting a different category or clear all filters.',
          variant: AppTextVariant.bodyMedium,
          textAlign: TextAlign.center,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        
        // ATOM: Description spacing
        const AppSpacer(size: AppSpacerSize.extraLarge),
      ],
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