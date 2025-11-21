import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<AuthResult> signup(String email, String password) async {
    try {
      final response = await _apiClient.signup(email, password);
      print('Signup response: $response'); // Debug
      
      final user = response['user'];
      final session = response['session'];

      if (user == null) {
        return AuthResult.failure(error: 'No user data received');
      }

      // Supabase session structure: session.access_token or session.accessToken
      String? accessToken;
      if (session != null) {
        accessToken = session['access_token'] ?? 
                     session['accessToken'] ?? 
                     (session is Map ? session['access_token'] : null);
      }

      if (accessToken != null) {
        await _storage.write(key: 'auth_token', value: accessToken);
        await _storage.write(key: 'user_id', value: user['id']?.toString() ?? '');
        await _storage.write(key: 'user_email', value: user['email']?.toString() ?? '');
      } else {
        print('Warning: No access token in session: $session');
        // Still return success if user exists, token might be in different format
        if (user['id'] != null) {
          await _storage.write(key: 'user_id', value: user['id']?.toString() ?? '');
          await _storage.write(key: 'user_email', value: user['email']?.toString() ?? '');
        }
      }

      return AuthResult.success(user: user, session: session);
    } catch (e, stackTrace) {
      print('Signup error: $e');
      print('Stack trace: $stackTrace');
      return AuthResult.failure(error: e.toString());
    }
  }

  Future<AuthResult> login(String email, String password) async {
    try {
      final response = await _apiClient.login(email, password);
      print('Login response: $response'); // Debug
      
      final user = response['user'];
      final session = response['session'];

      if (user == null) {
        return AuthResult.failure(error: 'No user data received. Check your credentials.');
      }

      // Supabase session structure: session.access_token or session.accessToken
      String? accessToken;
      if (session != null) {
        accessToken = session['access_token'] ?? 
                     session['accessToken'] ?? 
                     (session is Map ? session['access_token'] : null);
      }

      if (accessToken != null) {
        await _storage.write(key: 'auth_token', value: accessToken);
        await _storage.write(key: 'user_id', value: user['id']?.toString() ?? '');
        await _storage.write(key: 'user_email', value: user['email']?.toString() ?? '');
      } else {
        print('Warning: No access token in session: $session');
        // Still return success if user exists
        if (user['id'] != null) {
          await _storage.write(key: 'user_id', value: user['id']?.toString() ?? '');
          await _storage.write(key: 'user_email', value: user['email']?.toString() ?? '');
        }
      }

      return AuthResult.success(user: user, session: session);
    } catch (e, stackTrace) {
      print('Login error: $e');
      print('Stack trace: $stackTrace');
      return AuthResult.failure(error: e.toString());
    }
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: 'user_id');
  }

  Future<String?> getUserEmail() async {
    return await _storage.read(key: 'user_email');
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'user_id');
    await _storage.delete(key: 'user_email');
  }
}

class AuthResult {
  final bool success;
  final Map<String, dynamic>? user;
  final Map<String, dynamic>? session;
  final String? error;

  AuthResult.success({this.user, this.session})
      : success = true,
        error = null;

  AuthResult.failure({this.error})
      : success = false,
        user = null,
        session = null;
}

