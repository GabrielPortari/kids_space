import '../model/company.dart';
import 'package:dio/dio.dart';
import 'api_client.dart';
import '../util/network_exceptions.dart';

// Serviço de empresas com Dio e interceptors para token/refresh.
// O serviço aceita callbacks opcionais para obter token atual e para
// executar refresh-token quando receber 401.
class CompanyService {
  final String baseUrl;
  late final Dio _dio;

  /// Optional: callback that returns the current auth token (or null).
  final Future<String?> Function()? tokenProvider;

  /// Optional: callback that attempts to refresh the token and returns the new token (or null).
  final Future<String?> Function()? refreshToken;

  CompanyService({
    this.baseUrl = 'http://10.0.2.2:3000',
    this.tokenProvider,
    this.refreshToken,
  }) {
    // Initialize shared ApiClient (idempotent)
    ApiClient().init(baseUrl: baseUrl, tokenProvider: tokenProvider, refreshToken: refreshToken);
    _dio = ApiClient().dio;
  }

  /// Busca empresas pela API `/companies`. Em caso de erro retorna `mockCompanies`.
  Future<List<Company>> getAllCompanies() async {
    try {
      final resp = await _dio.get('/company');
      if (resp.statusCode == 200) {
        final data = resp.data as List<dynamic>;
        final companies = data.map((e) => Company.fromJson(Map<String, dynamic>.from(e as Map))).toList();
        return companies;
      } else {
        
        throw NetworkException('API returned status ${resp.statusCode}', statusCode: resp.statusCode);
      }
    } on DioException catch (e) {
      throw mapDioException(e);
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }
}
