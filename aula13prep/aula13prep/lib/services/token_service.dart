class TokenService {
  String? _accessToken;

  String? get accessToken => _accessToken;
  void saveToken(String token) => _accessToken = token;
  void clearToken() => _accessToken = null;
}
