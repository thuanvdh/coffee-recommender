import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  HttpOverrides.global = TestHttpOverrides();
  GoogleFonts.config.allowRuntimeFetching = false;
  await testMain();
}

class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return MockHttpClient();
  }
}

class MockHttpClient implements HttpClient {
  @override
  bool autoUncompress = true;
  @override
  Duration? connectionTimeout;
  @override
  Duration idleTimeout = const Duration(seconds: 15);
  @override
  int? maxConnectionsPerHost;
  @override
  String? userAgent;

  @override
  set connectionFactory(dynamic f) {}

  @override
  void addCredentials(Uri url, String realm, HttpClientCredentials credentials) {}
  @override
  void addProxyCredentials(String host, int port, String realm, HttpClientCredentials credentials) {}
  @override
  set badCertificateCallback(bool Function(X509Certificate cert, String host, int port)? callback) {}
  @override
  set keyLog(void Function(String line)? callback) {}
  @override
  set findProxy(String Function(Uri url)? callback) {}
  @override
  set authenticate(Future<bool> Function(Uri url, String scheme, String realm)? callback) {}
  @override
  set authenticateProxy(Future<bool> Function(String host, int port, String scheme, String realm)? callback) {}

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async => MockHttpClientRequest();
  @override
  Future<HttpClientRequest> open(String method, String host, int port, String path) async => MockHttpClientRequest();
  @override
  Future<HttpClientRequest> get(String host, int port, String path) async => MockHttpClientRequest();
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => MockHttpClientRequest();
  @override
  Future<HttpClientRequest> post(String host, int port, String path) async => MockHttpClientRequest();
  @override
  Future<HttpClientRequest> postUrl(Uri url) async => MockHttpClientRequest();
  @override
  Future<HttpClientRequest> put(String host, int port, String path) async => MockHttpClientRequest();
  @override
  Future<HttpClientRequest> putUrl(Uri url) async => MockHttpClientRequest();
  @override
  Future<HttpClientRequest> delete(String host, int port, String path) async => MockHttpClientRequest();
  @override
  Future<HttpClientRequest> deleteUrl(Uri url) async => MockHttpClientRequest();
  @override
  Future<HttpClientRequest> head(String host, int port, String path) async => MockHttpClientRequest();
  @override
  Future<HttpClientRequest> headUrl(Uri url) async => MockHttpClientRequest();
  @override
  Future<HttpClientRequest> patch(String host, int port, String path) async => MockHttpClientRequest();
  @override
  Future<HttpClientRequest> patchUrl(Uri url) async => MockHttpClientRequest();
  @override
  void close({bool force = false}) {}
}

class MockHttpClientRequest implements HttpClientRequest {
  @override
  bool followRedirects = true;
  @override
  int maxRedirects = 5;
  @override
  bool persistentConnection = true;
  @override
  final HttpHeaders headers = MockHttpHeaders();

  @override
  void add(List<int> data) {}
  @override
  void addError(Object error, [StackTrace? stackTrace]) {}
  @override
  Future addStream(Stream<List<int>> stream) async {}
  @override
  Future<HttpClientResponse> close() async => MockHttpClientResponse();
  @override
  Future<HttpClientResponse> get done async => MockHttpClientResponse();
  @override
  void write(Object? obj) {}
  @override
  void writeAll(Iterable objects, [String separator = ""]) {}
  @override
  void writeCharCode(int charCode) {}
  @override
  void writeln([Object? obj = ""]) {}
  @override
  Encoding encoding = utf8;
  
  @override
  void abort([Object? exception, StackTrace? stackTrace]) {}
  @override
  Future flush() async {}
  
  @override
  HttpConnectionInfo? get connectionInfo => null;
  @override
  List<Cookie> get cookies => [];
  @override
  String get method => '';
  @override
  Uri get uri => Uri();
  @override
  int get contentLength => 0;
  @override
  set contentLength(int value) {}
  @override
  bool get bufferOutput => true;
  @override
  set bufferOutput(bool value) {}
}

class MockHttpHeaders implements HttpHeaders {
  @override
  List<String>? operator [](String name) => null;
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}
  @override
  void clear() {}
  @override
  void forEach(void Function(String name, List<String> values) action) {}
  @override
  String? value(String name) => null;
  @override
  void remove(String name, Object value) {}
  @override
  void removeAll(String name) {}
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
  @override
  bool chunkedTransferEncoding = false;
  @override
  int contentLength = 0;
  @override
  ContentType? contentType;
  @override
  DateTime? date;
  @override
  DateTime? expires;
  @override
  set host(String? value) {}
  @override
  String? get host => null;
  @override
  DateTime? ifModifiedSince;
  @override
  bool persistentConnection = true;
  @override
  set port(int? value) {}
  @override
  int? get port => null;
  @override
  void noFolding(String name) {}
}

class MockHttpClientResponse extends Stream<List<int>> implements HttpClientResponse {
  @override
  int get statusCode => 200;
  @override
  String get reasonPhrase => 'OK';
  @override
  int get contentLength => 0;
  @override
  HttpClientResponseCompressionState get compressionState => HttpClientResponseCompressionState.notCompressed;
  @override
  final HttpHeaders headers = MockHttpHeaders();
  @override
  final List<Cookie> cookies = [];
  @override
  final bool isRedirect = false;
  @override
  final List<RedirectInfo> redirects = [];

  @override
  X509Certificate? get certificate => null;

  @override
  bool get persistentConnection => true;

  @override
  Future<HttpClientResponse> redirect([String? method, Uri? url, bool? followRedirects]) async => this;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([<int>[]]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  HttpConnectionInfo? get connectionInfo => null;
  @override
  Future<Socket> detachSocket() async => throw UnimplementedError();
}
