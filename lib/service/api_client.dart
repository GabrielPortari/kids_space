import 'dart:developer' as developer;
import 'package:dio/dio.dart';

// Cliente Dio reutilizável para a aplicação.
// Use ApiClient().init(...) uma vez na inicialização (ou passe callbacks no construtor
// de cada service que chamará ApiClient().init(...)).
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;

  Future<String?> Function()? tokenProvider;
  Future<String?> Function()? refreshToken;

  ApiClient._internal() {
    dio = Dio();
  }

  /// Inicializa o cliente com `baseUrl` e callbacks opcionais para token/refresh.
  void init({
    String baseUrl = 'http://10.0.2.2:3000',
    Future<String?> Function()? tokenProvider,
    Future<String?> Function()? refreshToken,
  }) {
    this.tokenProvider = tokenProvider;
    this.refreshToken = refreshToken;

    dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    );

    dio.interceptors.clear();
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        developer.log('ApiClient onRequest ${options.method} ${options.path}', name: 'ApiClient');
        try {
          final token = tokenProvider == null ? null : await tokenProvider();
          if (token != null) options.headers['Authorization'] = 'Bearer $token';
        } catch (e) {
          developer.log('ApiClient tokenProvider threw: $e', name: 'ApiClient');
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        developer.log('ApiClient onResponse ${response.requestOptions.method} ${response.requestOptions.path} status=${response.statusCode}', name: 'ApiClient');
        handler.next(response);
      },
      onError: (err, handler) async {
        developer.log('ApiClient onError ${err.requestOptions.method} ${err.requestOptions.path} error=${err.message}', name: 'ApiClient', error: err);
        if (err.response?.statusCode == 401 && refreshToken != null) {
          developer.log('ApiClient received 401, attempting refresh', name: 'ApiClient');
          try {
            final newToken = await refreshToken!();
            if (newToken != null) {
              final requestOptions = err.requestOptions;
              requestOptions.headers['Authorization'] = 'Bearer $newToken';
              try {
                final response = await dio.fetch(requestOptions);
                return handler.resolve(response);
              } catch (retryErr) {
                developer.log('ApiClient retry after refresh failed: $retryErr', name: 'ApiClient');
              }
            }
          } catch (e) {
            developer.log('ApiClient refreshToken threw: $e', name: 'ApiClient');
          }
        }
        handler.next(err);
      },
    ));
  }
}
