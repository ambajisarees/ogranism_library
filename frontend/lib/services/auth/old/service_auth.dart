import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/service_supabase.dart';


class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _db = SupabaseService();

  User? get currentUser => _db.client.auth.currentUser;

  Future<AuthResponse> signIn(String email, String password) async {
    return await _db.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUp(String email, String password) async {
    return await _db.client.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<bool> checkEmailExists(String email) async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .rpc('check_email_exists', params: {'email_to_check': email});
      return response as bool;
    } catch (e) {
      debugPrint('Error checking email exists: $e');
      return true; // Fallback: assume it exists to prevent unauthorized signup
    }
  }

  Future<void> signOut() async {
    await _db.client.auth.signOut();
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await _db.client
          .schema('IMMBE2627')
          .from('sb_APP_PROFILES')
          .select('*, sb_USER_ROLES(name)')
          .eq('id', userId)
          .maybeSingle();
      return response;
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return null;
    }
  }
}
