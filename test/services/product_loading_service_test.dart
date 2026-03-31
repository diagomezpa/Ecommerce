import 'package:dartz/dartz.dart';
import 'package:fake_maker_api_pragma_api/core/error/failures.dart';
import 'package:fake_maker_api_pragma_api/fake_maker_api_pragma_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pragma_app_shell/services/product_loading_service.dart';

class FakeProductRepository implements ProductRepository {
  FakeProductRepository({
    required this.productsResult,
    required this.product,
    this.delay = Duration.zero,
  });

  final Either<Failure, List<Product>> productsResult;
  final Product product;
  final Duration delay;

  @override
  Future<Either<Failure, Product>> createProduct(Product product) async =>
      Right(product);

  @override
  Future<Either<Failure, Product>> deleteProduct(int id) async => Right(product);

  @override
  Future<Either<Failure, Product>> fetchProductById(int id) async => Right(product);

  @override
  Future<Either<Failure, List<Product>>> fetchProducts() async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    return productsResult;
  }

  @override
  Future<Either<Failure, Product>> updateProduct(int id, Product product) async =>
      Right(product);
}

Product buildProduct({
  int id = 1,
  String title = 'Test Product',
  double price = 9.99,
}) {
  return Product(
    id: id,
    title: title,
    price: price,
    description: '$title description',
    category: Category.ELECTRONICS,
    image: 'https://example.com/$id.jpg',
    rating: Rating(rate: 4.5, count: 10),
  );
}

ProductBloc createControlledProductBloc({
  required Either<Failure, List<Product>> productsResult,
  Duration delay = Duration.zero,
}) {
  final repository = FakeProductRepository(
    productsResult: productsResult,
    product: buildProduct(),
    delay: delay,
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

void main() {
  group('ProductLoadingService Tests', () {
    group('loadAllProducts', () {
      test('returns success when bloc emits ProductsLoaded', () async {
        final products = [buildProduct(title: 'Loaded Product')];
        final bloc = createControlledProductBloc(productsResult: Right(products));

        final result = await ProductLoadingService.loadAllProducts(bloc);

        expect(result.isSuccess, true);
        expect(result.hasData, true);
        expect(result.hasError, false);
        expect(result.data, hasLength(1));
        expect(result.data.first.title, 'Loaded Product');

        bloc.dispose();
      });

      test('returns error when bloc emits ProductError', () async {
        final bloc = createControlledProductBloc(
          productsResult: Left(ServerFailure('server failure')),
        );

        final result = await ProductLoadingService.loadAllProducts(bloc);

        expect(result.isSuccess, false);
        expect(result.hasError, true);
        expect(result.error, 'Error al cargar el producto');
        expect(result.data, isEmpty);

        bloc.dispose();
      });

      test('returns timeout error when bloc does not respond in time', () async {
        final bloc = createControlledProductBloc(
          productsResult: Right([buildProduct()]),
          delay: const Duration(milliseconds: 50),
        );

        final result = await ProductLoadingService.loadAllProducts(
          bloc,
          timeout: const Duration(milliseconds: 5),
        );

        expect(result.isSuccess, false);
        expect(result.hasError, true);
        expect(result.error, 'Request timed out. Please try again.');

        await Future<void>.delayed(const Duration(milliseconds: 60));
        bloc.dispose();
      });

      test('returns catch error when adding event fails', () async {
        final bloc = createControlledProductBloc(
          productsResult: Right([buildProduct()]),
        );
        bloc.dispose();

        final result = await ProductLoadingService.loadAllProducts(bloc);

        expect(result.isSuccess, false);
        expect(result.hasError, true);
        expect(result.error, contains('Failed to load products:'));
      });
    });

    group('initializeWithCallback', () {
      test('delegates to the provided initializer', () {
        final bloc = createControlledProductBloc(productsResult: const Right(<Product>[]));
        dynamic capturedCallback;

        final result = ProductLoadingService.initializeWithCallback(
          (_) {},
          initializer: (callback) {
            capturedCallback = callback;
            return bloc;
          },
        );

        expect(result, same(bloc));
        expect(capturedCallback, isA<Function>());

        bloc.dispose();
      });
    });

    group('hasValidProducts', () {
      test('returns true for non-empty list', () {
        expect(ProductLoadingService.hasValidProducts([buildProduct()]), true);
      });

      test('returns false for empty or null lists', () {
        expect(ProductLoadingService.hasValidProducts(<Product>[]), false);
        expect(ProductLoadingService.hasValidProducts(null), false);
      });
    });

    group('ProductLoadResult', () {
      test('success factory populates data state', () {
        final products = [buildProduct(id: 1), buildProduct(id: 2)];

        final result = ProductLoadResult.success(products);

        expect(result.isSuccess, true);
        expect(result.hasData, true);
        expect(result.hasError, false);
        expect(result.products, products);
        expect(result.data, hasLength(2));
        expect(result.errorMessage, isNull);
      });

      test('error factory populates error state', () {
        final result = ProductLoadResult.error('Failed to load products');

        expect(result.isSuccess, false);
        expect(result.hasData, false);
        expect(result.hasError, true);
        expect(result.error, 'Failed to load products');
        expect(result.products, isNull);
        expect(result.data, isEmpty);
      });

      test('success with empty list reports no data', () {
        final result = ProductLoadResult.success(<Product>[]);

        expect(result.isSuccess, true);
        expect(result.hasData, false);
        expect(result.hasError, false);
        expect(result.data, isEmpty);
      });

      test('supports multiple products and preserves values', () {
        final products = List.generate(
          3,
          (index) => buildProduct(
            id: index + 1,
            title: 'Product ${index + 1}',
            price: (index + 1) * 10.0,
          ),
        );

        final result = ProductLoadResult.success(products);

        expect(result.data, hasLength(3));
        expect(result.data.first.title, 'Product 1');
        expect(result.data.last.price, 30.0);
      });

      test('preserves empty special and long error messages', () {
        final emptyResult = ProductLoadResult.error('');
        final longError = 'Error: ' + ('Very long error message ' * 20);
        final specialError = 'Error with special chars: áéíóú, ñÑ, @#\$%^&*()';

        final longResult = ProductLoadResult.error(longError);
        final specialResult = ProductLoadResult.error(specialError);

        expect(emptyResult.error, isEmpty);
        expect(longResult.error, longError);
        expect(specialResult.error, specialError);
      });
    });
  });
}
