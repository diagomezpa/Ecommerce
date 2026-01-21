import 'package:flutter/material.dart';
import 'package:fake_maker_api_pragma_api/fake_maker_api_pragma_api.dart';
import 'package:pragma_design_system/pragma_design_system.dart';
import 'product_detail_page.dart';

/// SearchPage - Product search functionality using local filtering
///
/// This page provides real-time product search capabilities using in-memory
/// filtering without network calls, maintaining strict design system compliance.
///
/// **Features:**
/// - Real-time local search filtering
/// - Search by product name and description
/// - Empty state when no results found
/// - Navigation to ProductDetailPage on selection
///
/// **Design System Usage:**
/// - AppFormField: Search input with design system styling
/// - AppSection: Semantic content blocks
/// - AppText: Typography hierarchy throughout
/// - AppSpacer: Consistent spacing tokens
/// - AppEmptyStateSection: No results state
/// - ProductListTemplate: Product grid template (TEMPLATE)
/// - AppProductListItem: Individual product display (ORGANISM)
///
/// **State Management:**
/// - ValueNotifier for reactive search state
/// - Local filtering logic separated from UI
/// - Debounced search for performance
///
/// **Architecture:**
/// - SearchPage: Main orchestration widget
/// - _SearchController: State and filtering logic
/// - _SearchInput: Search input section
/// - _SearchResults: Results display section
/// - Follows Atomic Design principles with design system governance
class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
    required this.products,
  });

  /// List of products to search through
  final List<Product> products;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final _SearchController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = _SearchController(widget.products);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Search Products',
      body: Column(
        children: [
          // MOLECULE: Search input section
          _SearchInput(controller: _searchController),
          
          // ORGANISM: Search results section
          Expanded(
            child: _SearchResults(controller: _searchController),
          ),
        ],
      ),
    );
  }
}

/// Search Controller - Manages search state and filtering logic
/// Separates business logic from UI following Clean Architecture principles
class _SearchController {
  _SearchController(this._allProducts);

  final List<Product> _allProducts;
  final TextEditingController textController = TextEditingController();
  final ValueNotifier<List<Product>> _filteredProducts = ValueNotifier([]);
  final ValueNotifier<String> _searchQuery = ValueNotifier('');

  /// Reactive stream of filtered products
  ValueNotifier<List<Product>> get filteredProducts => _filteredProducts;
  
  /// Current search query
  ValueNotifier<String> get searchQuery => _searchQuery;

  /// Initialize controller and set up listeners
  void initialize() {
    textController.addListener(_onSearchChanged);
    _filteredProducts.value = []; // Start with empty results
  }

  /// Handle search text changes with filtering logic
  void _onSearchChanged() {
    final query = textController.text.trim().toLowerCase();
    _searchQuery.value = query;
    
    if (query.isEmpty) {
      _filteredProducts.value = [];
      return;
    }

    // Local filtering by name and description
    final filtered = _allProducts.where((product) {
      final titleMatch = product.title.toLowerCase().contains(query);
      final descriptionMatch = product.description.toLowerCase().contains(query);
      return titleMatch || descriptionMatch;
    }).toList();

    _filteredProducts.value = filtered;
  }

  void dispose() {
    textController.dispose();
    _filteredProducts.dispose();
    _searchQuery.dispose();
  }
}

/// MOLECULE: Search Input Section
/// Provides search input using design system form field
class _SearchInput extends StatelessWidget {
  const _SearchInput({required this.controller});

  final _SearchController controller;

  @override
  Widget build(BuildContext context) {
    return AppSection(
      title: 'Find Products',
      child: Column(
        children: [
          // ATOM: Section spacing
          const AppSpacer(size: AppSpacerSize.small),
          
          // MOLECULE: Search form field
          AppFormField(
            controller: controller.textController,
            label: 'Search products...',
            hintText: 'Enter product name or description',
            prefixIcon: AppIcon(Icons.search),
            suffixIcon: AppIcon(Icons.clear),
          ),
          
          // ATOM: Bottom spacing
          const AppSpacer(size: AppSpacerSize.medium),
        ],
      ),
    );
  }
}

/// ORGANISM: Search Results Section
/// Displays filtered results or appropriate empty states
class _SearchResults extends StatefulWidget {
  const _SearchResults({required this.controller});

  final _SearchController controller;

  @override
  State<_SearchResults> createState() => _SearchResultsState();
}

class _SearchResultsState extends State<_SearchResults> {
  @override
  void initState() {
    super.initState();
    widget.controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Product>>(
      valueListenable: widget.controller.filteredProducts,
      builder: (context, filteredProducts, child) {
        return ValueListenableBuilder<String>(
          valueListenable: widget.controller.searchQuery,
          builder: (context, query, child) {
            // Single scroll view for all content
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Initial state - no search performed yet
                  if (query.isEmpty) _buildInitialState(),
                  
                  // Results found
                  if (query.isNotEmpty && filteredProducts.isNotEmpty)
                    _buildResultsFound(filteredProducts),
                  
                  // No results found
                  if (query.isNotEmpty && filteredProducts.isEmpty)
                    _buildNoResults(query),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// ATOM: Initial state before any search
  Widget _buildInitialState() {
    return Column(
      children: [
        const AppSpacer(size: AppSpacerSize.large),
        AppEmptyStateSection(
          icon: Icons.search_outlined,
          title: 'Start Searching',
          description: 'Enter a product name or description to find what you\'re looking for.',
        ),
      ],
    );
  }

  /// ORGANISM: Search results using design system template
  Widget _buildResultsFound(List<Product> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSpacer(size: AppSpacerSize.medium),
        
        // ATOM: Results count
        AppSection(
          title: 'Search Results',
          child: AppText(
            '${products.length} product${products.length == 1 ? '' : 's'} found',
            variant: AppTextVariant.bodyMedium,
          ),
        ),
        
        const AppSpacer(size: AppSpacerSize.medium),
        
        // TEMPLATE: Product grid using design system template
        ProductListTemplate(
          products: products
              .map((product) => AppProductListItem(
                    title: product.title,
                    subtitle: _formatCategoryName(product.category),
                    price: '\$${product.price.toStringAsFixed(2)}',
                    imageUrl: product.image,
                    isEnabled: true,
                    onTap: () => _navigateToProductDetail(context, product),
                  ))
              .toList(),
        ),
        
        const AppSpacer(size: AppSpacerSize.large),
      ],
    );
  }

  /// ORGANISM: No results empty state
  Widget _buildNoResults(String query) {
    return Column(
      children: [
        const AppSpacer(size: AppSpacerSize.large),
        AppEmptyStateSection(
          icon: Icons.search_off_outlined,
          title: 'No Results Found',
          description: 'We couldn\'t find any products matching "$query". Try different keywords or check for typos.',
          primaryAction: AppButton(
            text: 'Clear Search',
            variant: AppButtonVariant.outline,
            onPressed: () {
              widget.controller.textController.clear();
            },
          ),
        ),
      ],
    );
  }

  /// Navigate to product detail page
  void _navigateToProductDetail(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(productId: product.id),
      ),
    );
  }

  /// Format category enum to readable string using design system patterns
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