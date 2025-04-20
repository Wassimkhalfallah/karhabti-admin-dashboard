import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class AuthService {
  final SupabaseClient _client = SupabaseConfig.client;
  
  // Stream qui émet l'état d'authentification actuel
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Vérifier si l'utilisateur est connecté
  bool get isAuthenticated => _client.auth.currentUser != null;

  // Obtenir l'utilisateur actuel
  User? get currentUser => _client.auth.currentUser;
  
  // Connexion avec email et mot de passe
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw Exception('Une erreur inattendue est survenue lors de la connexion');
    }
  }
  
  // Inscription avec email et mot de passe
  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw Exception('Une erreur inattendue est survenue lors de l\'inscription');
    }
  }
  
  // Réinitialisation du mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Une erreur est survenue lors de la réinitialisation du mot de passe');
    }
  }
  
  // Mise à jour du mot de passe
  Future<UserResponse> updatePassword(String newPassword) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return response;
    } catch (e) {
      throw Exception('Une erreur est survenue lors de la mise à jour du mot de passe');
    }
  }
  
  // Mise à jour des informations du profil
  Future<UserResponse> updateProfile({String? email, Map<String, dynamic>? data}) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(
          email: email,
          data: data,
        ),
      );
      return response;
    } catch (e) {
      throw Exception('Une erreur est survenue lors de la mise à jour du profil');
    }
  }
  
  // Déconnexion
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw Exception('Une erreur est survenue lors de la déconnexion');
    }
  }
  
  // Vérifier si l'email est disponible
  Future<bool> isEmailAvailable(String email) async {
    try {
      // Cette fonction est un exemple et nécessite une implémentation personnalisée
      // car Supabase ne fournit pas directement cette fonctionnalité
      final response = await _client
          .from('admin_users')
          .select('email')
          .eq('email', email)
          .maybeSingle();
      
      return response == null; // Si aucun résultat, l'email est disponible
    } catch (e) {
      throw Exception('Une erreur est survenue lors de la vérification de l\'email');
    }
  }
  
  // Obtenir le rôle de l'utilisateur actuel
  Future<String?> getUserRole() async {
    try {
      if (currentUser == null) {
        return null;
      }
      
      final response = await _client
          .from('admin_users')
          .select('role')
          .eq('id', currentUser!.id)
          .maybeSingle();
      
      return response?['role'] as String?;
    } catch (e) {
      throw Exception('Une erreur est survenue lors de la récupération du rôle');
    }
  }
}
