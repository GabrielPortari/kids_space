import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kids_space/service/api_client.dart';

/// BaseController fornece utilitários comuns para controllers (storage, api client).
class BaseController {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final ApiClient apiClient = ApiClient();

  BaseController();

  Future<String?> getIdToken() => secureStorage.read(key: 'idToken');
  Future<String?> getRefreshToken() => secureStorage.read(key: 'refreshToken');
}
