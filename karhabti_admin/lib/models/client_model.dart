// Modèle pour les clients conforme à la structure réelle de la base de données
import 'package:flutter/foundation.dart';

class Client {
  final String id;
  final String nomClient;
  final DateTime createdAt;
  final bool notificationsEnabled;
  final String? fcmToken;
  final String? typeClient; // Professionnel ou Particulier
  final String? telephone;

  // Champs virtuels (non stockés directement dans la table client)
  final String? email; // Récupéré depuis le service auth de Supabase
  final int
  vehicleCount; // Calculé à partir de la table de liaison user_vehicules

  Client({
    required this.id,
    required this.nomClient,
    required this.createdAt,
    required this.notificationsEnabled,
    this.fcmToken,
    this.typeClient,
    this.telephone,
    this.email,
    this.vehicleCount = 0,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    try {
      if (kDebugMode) {
        print('🔄 Conversion JSON en Client: $json');
      }

      // Récupérer l'ID et vérifier qu'il n'est pas nul
      final id = json['id']?.toString() ?? '';
      if (id.isEmpty) {
        if (kDebugMode) {
          print('⚠️ ID client manquant ou vide');
        }
      }

      // Récupérer le nom du client avec une valeur par défaut
      final nomClient = json['nom_client']?.toString() ?? 'Client sans nom';

      // Convertir la date avec gestion des erreurs
      DateTime createdAt;
      try {
        createdAt =
            json['created_at'] != null
                ? DateTime.parse(json['created_at'].toString())
                : DateTime.now();
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Erreur de conversion de date: $e');
        }
        createdAt = DateTime.now();
      }

      // Récupérer le statut des notifications avec valeur par défaut à false
      final notificationsEnabled = json['notifications_enabled'] == true;

      return Client(
        id: id,
        nomClient: nomClient,
        createdAt: createdAt,
        notificationsEnabled: notificationsEnabled,
        fcmToken: json['fcm_token']?.toString(),
        typeClient: json['type_client']?.toString(),
        telephone: json['telephone']?.toString(),
        email:
            json['email']
                ?.toString(), // Sera rempli manuellement après la requête auth
        vehicleCount:
            json['vehicle_count'] is int
                ? json['vehicle_count']
                : 0, // Calculé après la requête
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors de la conversion JSON en Client: $e');
        print('JSON problématique: $json');
      }

      // Retourner un client par défaut en cas d'erreur
      return Client(
        id: 'error-${DateTime.now().millisecondsSinceEpoch}',
        nomClient: 'Erreur de conversion',
        createdAt: DateTime.now(),
        notificationsEnabled: false,
        vehicleCount: 0,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom_client': nomClient,
      'created_at': createdAt.toIso8601String(),
      'notifications_enabled': notificationsEnabled,
      'fcm_token': fcmToken,
      'type_client': typeClient,
      'telephone': telephone,
      // Les champs virtuels ne sont pas inclus dans le toJson
      // car ils ne sont pas stockés directement dans la table client
    };
  }

  // Modification pour ajouter des données virtuelles (email, vehicleCount)
  Client copyWith({
    String? id,
    String? nomClient,
    DateTime? createdAt,
    bool? notificationsEnabled,
    String? fcmToken,
    String? typeClient,
    String? telephone,
    String? email,
    int? vehicleCount,
  }) {
    return Client(
      id: id ?? this.id,
      nomClient: nomClient ?? this.nomClient,
      createdAt: createdAt ?? this.createdAt,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      fcmToken: fcmToken ?? this.fcmToken,
      typeClient: typeClient ?? this.typeClient,
      telephone: telephone ?? this.telephone,
      email: email ?? this.email,
      vehicleCount: vehicleCount ?? this.vehicleCount,
    );
  }

  @override
  String toString() {
    if (kDebugMode) {
      return 'Client{id: $id, nom: $nomClient, type: $typeClient, véhicules: $vehicleCount}';
    }
    return 'Client{id: $id, nom: $nomClient, type: $typeClient, véhicules: $vehicleCount}';
  }
}
