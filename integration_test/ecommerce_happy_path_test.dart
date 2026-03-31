import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pragma_design_system/pragma_design_system.dart';
import 'package:pragma_app_shell/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('completes the ecommerce happy path without real network calls', (
    tester,
  ) async {
    await HttpOverrides.runZoned(() async {
      await tester.pumpWidget(const app.MyApp());
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Use API Demo Credentials'), findsOneWidget);

      // Use the app's own demo-credentials shortcut to avoid fragile field selectors.
      await tester.tap(find.text('Use API Demo Credentials'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Login Successful'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Pragma Store'), findsOneWidget);
      expect(find.text('Quick Access'), findsOneWidget);

      await _tapVisibleText(tester, 'Catalog');
      await tester.pumpAndSettle();

      expect(find.text('Product Catalog'), findsOneWidget);
      final productTileFinder = find.byType(AppProductListItem);
      await _pumpUntilVisible(tester, productTileFinder);
      await tester.ensureVisible(productTileFinder.first);
      await tester.tap(productTileFinder.first);
      await tester.pumpAndSettle();

      expect(find.text('Product Details'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Add to Cart'), findsOneWidget);

      await tester.tap(find.text('Add to Cart'));
      await tester.pumpAndSettle();

      expect(find.text('Product added to cart!'), findsOneWidget);

      await tester.tap(find.byTooltip('Shopping Cart'));
      await tester.pumpAndSettle();

      expect(find.text('Shopping Cart'), findsOneWidget);
      await _pumpUntilVisible(tester, find.text('Checkout'));
      expect(find.text('Checkout'), findsOneWidget);

      await tester.tap(find.text('Checkout'));
      await tester.pumpAndSettle();

      expect(find.text('Checkout'), findsWidgets);
      expect(find.textContaining('Order Summary:'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    }, createHttpClient: (_) => _FakeHttpClient());
  });
}

Future<void> _tapVisibleText(WidgetTester tester, String text) async {
  final finder = find.text(text);
  await _pumpUntilVisible(tester, finder);
  await tester.ensureVisible(finder.first);
  await tester.tap(finder.first);
}

Future<void> _pumpUntilVisible(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
  Duration step = const Duration(milliseconds: 100),
}) async {
  final end = DateTime.now().add(timeout);

  while (DateTime.now().isBefore(end)) {
    await tester.pump(step);
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }

  fail('Finder never became visible: $finder');
}

class _MockStore {
  static const String productTitle = 'Integration Test Backpack';

  static Map<String, dynamic> productJson(int id) {
    return {
      'id': id,
      'title': productTitle,
      'price': 29.99,
      'description':
          'A lightweight backpack used to validate the ecommerce happy path.',
      'category': 'electronics',
      'image': 'https://images.example.com/products/$id.png',
      'rating': {'rate': 4.7, 'count': 120},
    };
  }

  static Map<String, dynamic> cartJson() {
    return {
      'id': 1,
      'userId': 1,
      'date': '2025-01-01T00:00:00.000Z',
      'products': [
        {'productId': 1, 'quantity': 2},
      ],
    };
  }
}

class _FakeHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async =>
      _FakeHttpClientRequest('GET', url);

  @override
  Future<HttpClientRequest> postUrl(Uri url) async =>
      _FakeHttpClientRequest('POST', url);

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      _FakeHttpClientRequest(method, url);

  @override
  void close({bool force = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpClientRequest implements HttpClientRequest {
  _FakeHttpClientRequest(this.method, this.uri);

  @override
  final String method;

  @override
  final Uri uri;

  final BytesBuilder _requestBody = BytesBuilder();

  @override
  final HttpHeaders headers = _FakeHttpHeaders();

  @override
  Encoding encoding = utf8;

  @override
  bool followRedirects = true;

  @override
  int maxRedirects = 5;

  @override
  bool persistentConnection = true;

  @override
  int contentLength = -1;

  @override
  void add(List<int> data) {
    _requestBody.add(data);
  }

  @override
  Future<void> addStream(Stream<List<int>> stream) async {
    await for (final chunk in stream) {
      add(chunk);
    }
  }

  @override
  void write(Object? object) {
    add(encoding.encode(object?.toString() ?? ''));
  }

  @override
  void writeAll(Iterable<dynamic> objects, [String separator = '']) {
    write(objects.join(separator));
  }

  @override
  void writeCharCode(int charCode) {
    write(String.fromCharCode(charCode));
  }

  @override
  void writeln([Object? object = '']) {
    write('${object ?? ''}\n');
  }

  @override
  Future<void> flush() async {}

  @override
  void abort([Object? exception, StackTrace? stackTrace]) {}

  @override
  Future<HttpClientResponse> close() async {
    final path = uri.path;

    if (uri.host == 'fakestoreapi.com') {
      if (method == 'POST' && path == '/auth/login') {
        return _FakeHttpClientResponse.json({
          'token': 'integration-test-token',
        });
      }

      if (method == 'GET' && path == '/products') {
        return _FakeHttpClientResponse.json([_MockStore.productJson(1)]);
      }

      if (method == 'GET' && path == '/products/1') {
        return _FakeHttpClientResponse.json(_MockStore.productJson(1));
      }

      if (method == 'GET' && path == '/carts/1') {
        return _FakeHttpClientResponse.json(_MockStore.cartJson());
      }

      return _FakeHttpClientResponse.text(
        'Not Found',
        statusCode: HttpStatus.notFound,
      );
    }

    // Network images are replaced with a tiny valid PNG.
    return _FakeHttpClientResponse.bytes(_transparentImageBytes);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  _FakeHttpClientResponse(this._bytes, this.statusCode, this.headers);

  factory _FakeHttpClientResponse.json(Object jsonBody) {
    return _FakeHttpClientResponse(
      Uint8List.fromList(utf8.encode(jsonEncode(jsonBody))),
      HttpStatus.ok,
      _FakeHttpHeaders(contentType: ContentType.json),
    );
  }

  factory _FakeHttpClientResponse.text(
    String body, {
    int statusCode = HttpStatus.ok,
  }) {
    return _FakeHttpClientResponse(
      Uint8List.fromList(utf8.encode(body)),
      statusCode,
      _FakeHttpHeaders(contentType: ContentType.text),
    );
  }

  factory _FakeHttpClientResponse.bytes(Uint8List bytes) {
    return _FakeHttpClientResponse(
      bytes,
      HttpStatus.ok,
      _FakeHttpHeaders(contentType: ContentType('image', 'png')),
    );
  }

  final Uint8List _bytes;

  @override
  final int statusCode;

  @override
  final HttpHeaders headers;

  @override
  int get contentLength => _bytes.length;

  @override
  bool get persistentConnection => false;

  @override
  bool get isRedirect => false;

  @override
  List<RedirectInfo> get redirects => const [];

  @override
  List<Cookie> get cookies => const [];

  @override
  String get reasonPhrase => 'OK';

  @override
  X509Certificate? get certificate => null;

  @override
  HttpConnectionInfo? get connectionInfo => null;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  Future<Socket> detachSocket() {
    throw UnimplementedError();
  }

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([_bytes]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpHeaders implements HttpHeaders {
  _FakeHttpHeaders({ContentType? contentType}) : _contentType = contentType;

  final Map<String, List<String>> _values = <String, List<String>>{};
  ContentType? _contentType;

  @override
  ContentType? get contentType => _contentType;

  @override
  set contentType(ContentType? value) {
    _contentType = value;
  }

  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {
    _values.putIfAbsent(name.toLowerCase(), () => <String>[]).add('$value');
  }

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    _values[name.toLowerCase()] = <String>['$value'];
  }

  @override
  void remove(String name, Object value) {
    _values[name.toLowerCase()]?.remove('$value');
  }

  @override
  void removeAll(String name) {
    _values.remove(name.toLowerCase());
  }

  @override
  List<String>? operator [](String name) => _values[name.toLowerCase()];

  @override
  String? value(String name) {
    final values = this[name];
    if (values == null || values.isEmpty) {
      return null;
    }
    return values.first;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final Uint8List _transparentImageBytes = Uint8List.fromList(<int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0xF8,
  0xCF,
  0xC0,
  0x00,
  0x00,
  0x03,
  0x01,
  0x01,
  0x00,
  0x18,
  0xDD,
  0x8D,
  0xB1,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);
