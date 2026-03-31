import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:fake_maker_api_pragma_api/core/error/failures.dart';
import 'package:fake_maker_api_pragma_api/fake_maker_api_pragma_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pragma_app_shell/pages/cart_page.dart';
import 'package:pragma_app_shell/pages/home_page.dart';
import 'package:pragma_app_shell/pages/product_detail_page.dart';
import 'package:pragma_app_shell/pages/product_list_page.dart';
import 'package:pragma_app_shell/pages/search_page.dart';
import 'package:pragma_app_shell/pages/support_page.dart';

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

class FakeCartRepository implements CartRepository {
  FakeCartRepository({required this.cart});

  final Cart cart;

  @override
  Future<Either<Failure, Cart>> createCart(Cart cart) async => Right(cart);

  @override
  Future<Either<Failure, Cart>> deleteCart(int id) async => Right(cart);

  @override
  Future<Either<Failure, Cart>> fetchCartById(int id) async => Right(cart);

  @override
  Future<Either<Failure, Cart>> fetchCartWithProductDetailsById(int id) async =>
      Right(cart);

  @override
  Future<Either<Failure, List<Cart>>> fetchCarts() async => Right([cart]);

  @override
  Future<Either<Failure, List<Cart>>> fetchCartsWithProductDetails() async =>
      Right([cart]);

  @override
  Future<Either<Failure, Cart>> updateCart(int id, Cart cart) async =>
      Right(cart);
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

CartBloc createControlledCartBloc(Cart cart) {
  final repository = FakeCartRepository(cart: cart);
  final getCarts = GetCarts(repository);
  final getCart = GetCart(repository);
  final deleteCart = DeleteCart(repository);
  final createCart = CreateCart(repository);
  final updateCart = UpdateCart(repository, getCart);

  return CartBloc(
    getCarts,
    getCart,
    deleteCart,
    createCart,
    updateCart,
    repository,
  );
}

Product buildProduct({
  required int id,
  required String title,
  required double price,
  required double rating,
  required Category category,
}) {
  return Product(
    id: id,
    title: title,
    price: price,
    description: '$title description',
    category: category,
    image: '',
    rating: Rating(rate: rating, count: 100),
  );
}

Cart buildCart() {
  return Cart(
    id: 1,
    userId: 1,
    date: DateTime.now(),
    products: [
      Products(productId: 1, quantity: 1),
    ],
  );
}

void main() {
  group('HomePage Widget Tests', () {
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
          title: 'Featured Phone',
          price: 999.99,
          rating: 4.8,
          category: Category.ELECTRONICS,
        ),
        buildProduct(
          id: 2,
          title: 'Budget Shirt',
          price: 29.99,
          rating: 3.8,
          category: Category.MENS_CLOTHING,
        ),
        buildProduct(
          id: 3,
          title: 'Promo Headphones',
          price: 49.99,
          rating: 4.3,
          category: Category.ELECTRONICS,
        ),
      ];
      productById = {for (final product in products) product.id: product};
    });

    HomePage buildHomePage({
      required ProductBloc productBloc,
      CartBloc? cartBloc,
    }) {
      final effectiveCartBloc = cartBloc ?? createControlledCartBloc(buildCart());
      return HomePage(
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
        cartBlocFactory: (_) => effectiveCartBloc,
      );
    }

    testWidgets('should show loading state before products arrive', (WidgetTester tester) async {
      final productBloc = createControlledProductBloc(
        productsResponses: [Right(products)],
        productById: productById,
        fetchDelay: const Duration(milliseconds: 300),
      );

      await tester.pumpWidget(
        MaterialApp(home: buildHomePage(productBloc: productBloc)),
      );
      await tester.pump();

      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump();

      productBloc.dispose();
    });

    testWidgets('should render success state with featured promotional and quick access sections', (WidgetTester tester) async {
      final productBloc = createControlledProductBloc(
        productsResponses: [Right(products)],
        productById: productById,
      );

      await tester.pumpWidget(
        MaterialApp(home: buildHomePage(productBloc: productBloc)),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Pragma Store'), findsOneWidget);
      expect(find.text('Featured Products'), findsOneWidget);
      expect(find.text('Special Offers'), findsOneWidget);
      expect(find.text('Quick Access'), findsOneWidget);
      expect(find.text('Featured Phone'), findsOneWidget);
      expect(find.text('Promo Headphones'), findsAtLeastNWidgets(1));
      expect(find.text('Budget Shirt'), findsOneWidget);
      expect(find.text('Catalog'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Shopping Cart'), findsAtLeastNWidgets(1));
      expect(find.text('Support'), findsOneWidget);

      productBloc.dispose();
    });

    testWidgets('should navigate to product detail when product is tapped', (WidgetTester tester) async {
      final productBloc = createControlledProductBloc(
        productsResponses: [Right(products)],
        productById: productById,
      );

      await tester.pumpWidget(
        MaterialApp(home: buildHomePage(productBloc: productBloc)),
      );
      await tester.pump();
      await tester.pump();

      await tester.ensureVisible(find.text('Featured Phone'));
      await tester.tap(find.text('Featured Phone').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(ProductDetailPage), findsOneWidget);

      productBloc.dispose();
    });

    testWidgets('should navigate through quick action cards', (WidgetTester tester) async {
      final productBloc = createControlledProductBloc(
        productsResponses: [Right(products)],
        productById: productById,
      );
      final cartBloc = createControlledCartBloc(buildCart());

      await tester.pumpWidget(
        MaterialApp(home: buildHomePage(productBloc: productBloc, cartBloc: cartBloc)),
      );
      await tester.pump();
      await tester.pump();

      await tester.ensureVisible(find.text('Catalog'));
      await tester.tap(find.text('Catalog').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(ProductListPage), findsOneWidget);

      await tester.pageBack();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await tester.ensureVisible(find.text('Search'));
      await tester.tap(find.text('Search').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(SearchPage), findsOneWidget);

      await tester.pageBack();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await tester.ensureVisible(find.text('Support'));
      await tester.tap(find.text('Support').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(SupportPage), findsOneWidget);

      await tester.pageBack();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await tester.ensureVisible(find.text('Shopping Cart').last);
      await tester.tap(find.text('Shopping Cart').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(CartPage), findsOneWidget);

      productBloc.dispose();
      cartBloc.dispose();
    });

    testWidgets('should open cart from app bar action', (WidgetTester tester) async {
      final productBloc = createControlledProductBloc(
        productsResponses: [Right(products)],
        productById: productById,
      );
      final cartBloc = createControlledCartBloc(buildCart());

      await tester.pumpWidget(
        MaterialApp(home: buildHomePage(productBloc: productBloc, cartBloc: cartBloc)),
      );
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byTooltip('Shopping Cart'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(CartPage), findsOneWidget);

      productBloc.dispose();
      cartBloc.dispose();
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
        MaterialApp(home: buildHomePage(productBloc: productBloc)),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Unable to Load Store'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Featured Products'), findsOneWidget);
      expect(find.text('Special Offers'), findsOneWidget);

      productBloc.dispose();
    });

    testWidgets('should show logout dialog and navigate to login route', (WidgetTester tester) async {
      final productBloc = createControlledProductBloc(
        productsResponses: [Right(products)],
        productById: productById,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: buildHomePage(productBloc: productBloc),
          routes: {
            '/login': (_) => const Scaffold(body: Text('Login Page')),
          },
        ),
      );
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      expect(find.text('Logout'), findsWidgets);
      expect(find.text('Are you sure you want to logout?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);

      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Logout').last);
      await tester.pumpAndSettle();

      expect(find.text('Login Page'), findsOneWidget);

      productBloc.dispose();
    });

    testWidgets('should dispose safely when removed from tree', (WidgetTester tester) async {
      final productBloc = createControlledProductBloc(
        productsResponses: [Right(products)],
        productById: productById,
      );

      await tester.pumpWidget(
        MaterialApp(home: buildHomePage(productBloc: productBloc)),
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