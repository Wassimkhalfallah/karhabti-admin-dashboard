import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../services/responsable_technicien_service.dart';

enum UserRole { admin, responsableTechnicien, client, unknown }

class AuthService {
  final SupabaseClient _client = SupabaseConfig.client;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  bool get isAuthenticated => _client.auth.currentUser != null;

  User? get currentUser => _client.auth.currentUser;

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
      throw Exception(
        'Une erreur inattendue est survenue lors de la connexion',
      );
    }
  }

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
      throw Exception(
        'Une erreur est survenue lors de l\'inscription',
      );
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception(
        'Une erreur est survenue lors de la réinitialisation du mot de passe',
      );
    }
  }

  Future<UserResponse> updatePassword(String newPassword) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return response;
    } catch (e) {
      throw Exception(
        'Une erreur est survenue lors de la mise à jour du mot de passe',
      );
    }
  }

  Future<UserResponse> updateProfile({
    String? email,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(email: email, data: data),
      );
      return response;
    } catch (e) {
      throw Exception(
        'Une erreur est survenue lors de la mise à jour du profil',
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw Exception('Une erreur est survenue lors de la déconnexion');
    }
  }

  Future<bool> isEmailAvailable(String email) async {
    try {
      final response =
          await _client
              .from('admin_users')
              .select('email')
              .eq('email', email)
              .maybeSingle();

      return response == null;
    } catch (e) {
      throw Exception(
        'Une erreur est survenue lors de la vérification de l\'email',
      );
    }
  }

  Future<String?> getUserRole() async {
    try {
      if (currentUser == null) {
        return null;
      }

      final response =
          await _client
              .from('admin_users')
              .select('role')
              .eq('id', currentUser!.id)
              .maybeSingle();

      return response?['role'] as String?;
    } catch (e) {
      throw Exception(
        'Une erreur est survenue lors de la récupération du rôle',
      );
    }
  }


  /// Vérifie si l'utilisateur est un administrateur en consultant les deux tables possibles
  Future<bool> isAdmin(String userId) async {
    try {
      final adminCheck = await _client
          .from('admins')
          .select('id')
          .eq('id', userId)
          .maybeSingle();
      if (adminCheck != null) return true;

      final adminUserCheck = await _client
          .from('admin_users')
          .select('user_id')
          .eq('user_id', userId)
          .maybeSingle();
      if (adminUserCheck != null) return true;
    } catch (e) {
      if (kDebugMode) print('Erreur lors de la vérification admin: $e');
    }
    return false;
  }

  /// Crée un responsable technicien avec gestion des permissions d'admin
  /// Captures l'ID admin avant le signUp pour éviter les conflits de session
  Future<Map<String, dynamic>> createResponsableUser(
    String email,
    String password,
    String nomComplet,
    String? telephone,
  ) async {
    try {
      // ÉTAPE CRUCIALE : Capturer l'ID de l'administrateur AVANT de créer le nouvel utilisateur.
      // Car Supabase Auth peut changer le 'currentUser' lors d'un signUp réussi.
      final adminId = _client.auth.currentUser?.id;
      
      if (adminId == null) {
        return {'success': false, 'error': 'Administrateur non authentifié.'};
      }

      if (kDebugMode) {
        print('Admin ID capturé avant signUp: $adminId');
      }

      // Étape 1 : Création du compte responsable dans Supabase Auth
      final authResponse = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        return {
          'success': false,
          'error': 'Échec de la création de l\'utilisateur Supabase: ${authResponse.user?.id ?? 'Erreur inconnue'}',
        };
      }

      final newUserId = authResponse.user?.id;
      if (newUserId == null) {
        return {'success': false, 'error': 'ID du nouveau responsable non récupéré.'};
      }

      // Étape 2 : Créer l'entrée dans la table responsables_techniciens
      // Utiliser le service avec l'ID admin capturé
      final service = ResponsableTechnicienService();
      try {
        await service.createResponsable(
          userId: newUserId,
          nomComplet: nomComplet,
          telephone: telephone,
        );
        
        return {
          'success': true,
          'userId': newUserId,
          'responsableId': currentUser?.id,
        };
      } catch (dbError) {
        // Nettoyer l'utilisateur Supabase en cas d'échec de la base de données
        try {
          await _client.auth.admin.deleteUser(newUserId);
        } catch (cleanupError) {
          // Ignorer les erreurs de nettoyage
        }
        
        return {
          'success': false,
          'error': 'Échec de la création dans la base de données: ${dbError.toString()}',
        };
      }
    } on AuthException catch (e) {
      return {'success': false, 'error': 'Erreur Auth: ${e.message}'};
    } catch (e) {
      return {'success': false, 'error': 'Erreur: ${e.toString()}'};
    }
  }
Future<Map<String, dynamic>> createGarageForResponsable({
    required String responsableId,
    required String nomGarage,
    required String adresse,
    required String ville,
    required String codePostal,
    String? telephoneGarage,
  }) async {
    try {
      // Insérer le nouveau garage
      final List<Map<String, dynamic>> response = await _client
          .from('garages')
          .insert({
            'nom': nomGarage,
            'adresse': adresse,
            'ville': ville,
            'code_postal': codePostal,
            'telephone': telephoneGarage,
            'created_by': responsableId, // Le responsable est le créateur initial
          })
          .select('id'); // Récupérer l'ID du garage créé

      if (response.isEmpty || response.first['id'] == null) {
        return {'success': false, 'error': 'Impossible de créer le garage.'};
      }

      final garageId = response.first['id'];

      // Mettre à jour la table responsables_techniciens avec le garage_id
      await _client
          .from('responsables_techniciens')
          .update({'garage_id': garageId})
          .eq('id', responsableId);

      return {'success': true, 'garageId': garageId};
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la création du garage pour le responsable: $e');
      }
      return {'success': false, 'error': 'Erreur lors de la création du garage: ${e.toString()}'};
    }
  }
}
