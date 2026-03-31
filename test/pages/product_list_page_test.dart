import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:fake_maker_api_pragma_api/core/error/failures.dart';
import 'package:fake_maker_api_pragma_api/fake_maker_api_pragma_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pragma_app_shell/pages/product_detail_page.dart';
import 'package:pragma_app_shell/pages/product_list_page.dart';

class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return FakeHttpClient();
  }
}

class FakeHttpClient implements HttpClient {
  bool _autoUncompress = true;

  @override
  bool get autoUncompress => _autoUncompress;

  @override
  set autoUncompress(bool value) {
    _autoUncompress = value;
  }

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => FakeHttpClientRequest();

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      FakeHttpClientRequest();

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeHttpClientRequest implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async => FakeHttpClientResponse();

  @override
  Encoding get encoding => utf8;

  @override
  set encoding(Encoding value) {}

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  static final Uint8List _transparentImage = Uint8List.fromList(<int>[
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
    0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
    0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
    0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
    0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
    0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
    0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
    0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
    0x42, 0x60, 0x82,
  ]);

  @override
  int get statusCode => HttpStatus.ok;

  @override
  int get contentLength => _transparentImage.length;

  @override
  bool get persistentConnection => false;

  @override
  bool get isRedirect => false;

  @override
  X509Certificate? get certificate => null;

  @override
  HttpConnectionInfo? get connectionInfo => null;

  @override
  List<RedirectInfo> get redirects => const <RedirectInfo>[];

  @override
  HttpHeaders get headers => FakeHttpHeaders();

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable(<List<int>>[_transparentImage]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeHttpHeaders implements HttpHeaders {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeProductRepository implements ProductRepository {
  FakeProductRepository({
    required this.productsResponses,
    required this.productById,
    this.fetchDelay = Duration.zero,
  });

  final List<Either<Failure, List<Product>>> productsResponses;
  final Map<int, Product> productById;
  final Duration fetchDelay;
  int _fetchProductsCalls = 0;

  Either<Failure, List<Product>> get _nextProductsResponse {
    if (_fetchProductsCalls < productsResponses.length) {
      return productsResponses[_fetchProductsCalls++];
    }
    return productsResponses.last;
  }

  @override
  Future<Either<Failure, Product>> createProduct(Product product) async =>
      Right(product);

  @override
  Future<Either<Failure, Product>> deleteProduct(int id) async =>
      Right(productById[id] ?? productById.values.first);

  @override
  Future<Either<Failure, Product>> fetchProductById(int id) async =>
      Right(productById[id] ?? productById.values.first);

  @override
  Future<Either<Failure, List<Product>>> fetchProducts() async {
    if (fetchDelay > Duration.zero) {
      await Future<void>.delayed(fetchDelay);
    }
    return _nextProductsResponse;
  }

  @override
  Future<Either<Failure, Product>> updateProduct(int id, Product product) async =>
      Right(product);
}

ProductBloc createControlledProductBloc({
  required List<Either<Failure, List<Product>>> productsResponses,
  required Map<int, Product> productById,
  Duration fetchDelay = Duration.zero,
}) {
  final repository = FakeProductRepository(
    productsResponses: productsResponses,
    productById: productById,
    fetchDelay: fetchDelay,
  );
  final getProduct = GetProduct(repository);
  final getProducts = GetProducts(repository);
  final createProduct = CreateProduct(repository);
  final deleteProduct = DeleteProduct(repository);
  final updateProduct = UpdateProduct(repository, getProduct);

  return ProductBloc(
    getProduct,
    getProducts,
    createProduct,
    deleteProduct,
    updateProduct,
  );
}

Product buildProduct({
  required int id,
  required String title,
  required double price,
  required Category category,
}) {
  return Product(
    id: id,
    title: title,
    price: price,
    description: '$title description',
    category: category,
    image: '',
    rating: Rating(rate: 4.4, count: 100),
  );
}

void main() {
  group('ProductListPage Widget Tests', () {
    late List<Product> products;
    late Map<int, Product> productById;
    HttpOverrides? originalHttpOverrides;

    setUpAll(() {
      originalHttpOverrides = HttpOverrides.current;
      HttpOverrides.global = TestHttpOverrides();
    });

    tearDownAll(() {
      HttpOverrides.global = originalHttpOverrides;
    });

    setUp(() {
      products = [
        buildProduct(
          id: 1,
          title: 'Laptop Pro',
          price: 1200,
          category: Category.ELECTRONICS,
        ),
        buildProduct(
          id: 2,
          title: 'Golden Ring',
          price: 399,
          category: Category.JEWELERY,
        ),
        buildProduct(
          id: 3,
          title: 'Basic Shirt',
          price: 35,
          category: Category.MENS_CLOTHING,
        ),
        buildProduct(
          id: 4,
          title: 'Summer Dress',
          price: 55,
          category: Category.WOMENS_CLOTHING,
        ),
      ];
      productById = {for (final product in products) product.id: product};
    });

    ProductListPage buildPage({required ProductBloc productBloc}) {
      return ProductListPage(
        productBlocFactory: (onProductLoaded) {
          productBloc.state.listen((state) {
            if (state is ProductsLoaded) {
              onProductLoaded(state.products);
            } else if (state is ProductLoaded) {
              onProductLoaded(state.product);
            } else if (state is ProductError) {
              onProductLoaded(state.message);
            }
          });
          return productBloc;
        },
      );
    }

    testWidgets('should show loading state before products arrive', (WidgetTester tester) async {
      final productBloc = createControlledProductBloc(
        productsResponses: [Right(products)],
        productById: productById,
        fetchDelay: const Duration(milliseconds: 300),
      );

      await tester.pumpWidget(
        MaterialApp(home: buildPage(productBloc: productBloc)),
      );
      await tester.pump();

      expect(find.byType(ProductListPage), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump();

      productBloc.dispose();
    });

    testWidgets('should render full catalog with filter section and all products', (WidgetTester tester) async {
      final productBloc = createControlledProductBloc(
        productsResponses: [Right(products)],
        productById: productById,
      );

      await tester.pumpWidget(
        MaterialApp(home: buildPage(productBloc: productBloc)),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Product Catalog'), findsOneWidget);
      expect(find.text('Filter by Category'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Electronics'), findsAtLeastNWidgets(1));
      expect(find.text('Jewelry'), findsAtLeastNWidgets(1));
      expect(find.text("Men's Clothing"), findsAtLeastNWidgets(1));
      expect(find.text("Women's Clothing"), findsAtLeastNWidgets(1));
      expect(find.text('Showing all 4 products'), findsOneWidget);
      expect(find.text('All Products'), findsOneWidget);
      expect(find.text('Laptop Pro'), findsOneWidget);
      expect(find.text('Golden Ring'), findsOneWidget);
      expect(find.text('Basic Shirt'), findsOneWidget);
      expect(find.text('Summer Dress'), findsOneWidget);

      productBloc.dispose();
    });

    testWidgets('should filter products by category and update counts', (WidgetTester tester) async {
      final productBloc = createControlledProductBloc(
        productsResponses: [Right(products)],
        productById: productById,
      );

      await tester.pumpWidget(
        MaterialApp(home: buildPage(productBloc: productBloc)),
      );
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Electronics').first);
      await tester.pump();

      expect(find.text('Showing 1 of 4 products'), findsOneWidget);
      expect(find.text('Electronics'), findsAtLeastNWidgets(2));
      expect(find.text('Laptop Pro'), findsOneWidget);
      expect(find.text('Golden Ring'), findsNothing);
      expect(find.text('Basic Shirt'), findsNothing);

      await tester.tap(find.text('All'));
      await tester.pump();

      expect(find.text('Showing all 4 products'), findsOneWidget);
      expect(find.text('Golden Ring'), findsOneWidget);

      productBloc.dispose();
    });

    testWidgets('should show empty state when selected filter has no results', (WidgetTester tester) async {
      final onlyElectronicsBloc = createControlledProductBloc(
        productsResponses: [
          Right([
            buildProduct(
              id: 10,
              title: 'Only Laptop',
              price: 999,
              category: Category.ELECTRONICS,
            ),
          ]),
        ],
        productById: {
          10: buildProduct(
            id: 10,
            title: 'Only Laptop',
            price: 999,
            category: Category.ELECTRONICS,
          ),
        },
      );

      await tester.pumpWidget(
        MaterialApp(home: buildPage(productBloc: onlyElectronicsBloc)),
      );
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Jewelry'));
      await tester.pump();

      expect(find.text('Showing 0 of 1 products'), findsOneWidget);
      expect(find.text('No products found'), findsOneWidget);
      expect(find.text('Try selecting a different category or clear all filters.'), findsOneWidget);
      expect(find.byIcon(Icons.filter_list_off), findsOneWidget);

      onlyElectronicsBloc.dispose();
    });

    testWidgets('should navigate to product detail when product is tapped', (WidgetTester tester) async {
      final productBloc = createControlledProductBloc(
        productsResponses: [Right(products)],
        productById: productById,
      );

      await tester.pumpWidget(
        MaterialApp(home: buildPage(productBloc: productBloc)),
      );
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Laptop Pro').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(ProductDetailPage), findsOneWidget);

      productBloc.dispose();
    });

    testWidgets('should show error state and recover on retry', (WidgetTester tester) async {
      final productBloc = createControlledProductBloc(
        productsResponses: [
          Left(ServerFailure('boom')),
          Right(products),
        ],
        productById: productById,
      );

      await tester.pumpWidget(
        MaterialApp(home: buildPage(productBloc: productBloc)),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Unable to Load Catalog'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Filter by Category'), findsOneWidget);
      expect(find.text('All Products'), findsOneWidget);

      productBloc.dispose();
    });

    testWidgets('should dispose safely when removed from widget tree', (WidgetTester tester) async {
      final productBloc = createControlledProductBloc(
        productsResponses: [Right(products)],
        productById: productById,
      );

      await tester.pumpWidget(
        MaterialApp(home: buildPage(productBloc: productBloc)),
      );
      await tester.pump();

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('Different Page'))),
      );
      await tester.pumpAndSettle();

      expect(find.text('Different Page'), findsOneWidget);
    });
  });
}