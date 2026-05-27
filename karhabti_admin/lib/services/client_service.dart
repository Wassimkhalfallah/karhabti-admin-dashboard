// ignore_for_file: unused_element

import 'package:flutter/foundation.dart';

import '../models/client_model.dart';
import 'database_service.dart';
import '../config/supabase_config.dart';

class ClientService {
  final DatabaseService _databaseService = DatabaseService();
  static const String _clientsTable = 'client';
  static const String _userVehiclesTable = 'user_vehicles';

  // Test database connectivity
  Future<bool> testDatabaseConnection() async {
    return await _databaseService.testConnection();
  }

  // Get all clients with optional filtering and pagination
  Future<List<Client>> getAllClients({
    String? orderBy,
    bool ascending = false,
    int? limit,
    int? offset,
    Map<String, dynamic>? filters,
  }) async {
    try {
      if (kDebugMode) {
        print('🔍 Récupération des clients avec auth...');
      }
      if (kDebugMode) {
        print(
        '📊 Connexion Supabase: ${SupabaseConfig.client.auth.currentSession != null ? 'active' : 'inactive'}',
      );
      }

      // 1. Récupérer la table client avec join vers auth.users pour l'email
      var query = SupabaseConfig.client
          .from(_clientsTable)
          .select('id, nom_client, created_at, notifications_enabled, '
                  'fcm_token, type_client, telephone')
          .order(orderBy ?? 'created_at', ascending: ascending);
      // Appliquer la limite si spécifiée
      if (limit != null && offset != null) {
        query = query.range(offset, offset + limit - 1) as dynamic;
      } else if (limit != null) {
        query = query.limit(limit) as dynamic;
      }

      final clientsData = await query;

      if (kDebugMode) {
        print('📊 Clients trouvés dans la table client: ${clientsData.length}');
      }

      if (clientsData.isEmpty) {
        if (kDebugMode) {
          print('⚠️ Aucun client trouvé dans la table client');
        }
        return [];
      }

      // 2. Convertir les résultats en objets Client
      final List<Client> clients = [];

      for (var json in clientsData) {
        try {
          // Extraire l'email depuis le join auth
          String? email = json['auth'] != null ? json['auth']['email'] : null;

          // Supprimer les données auth avant conversion
          var clientJson = Map<String, dynamic>.from(json);
          clientJson.remove('auth');

          final client = Client.fromJson(clientJson);
          clients.add(client.copyWith(email: email));
        } catch (e) {
          if (kDebugMode) {
            print('❌ Erreur conversion client: $e');
          }
          if (kDebugMode) {
            print('⚠️ JSON problématique: $json');
          }
        }
      }

      if (kDebugMode) {
        print('✅ ${clients.length} clients convertis avec succès');
      }

      // 3. Enrichir chaque client avec le nombre de véhicules
      for (int i = 0; i < clients.length; i++) {
        try {
          final vehicleCount = await _countVehiclesForClient(clients[i].id);
          clients[i] = clients[i].copyWith(vehicleCount: vehicleCount);
          if (kDebugMode) {
            print('🚗 Client ${clients[i].nomClient}: $vehicleCount véhicules');
          }
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Erreur comptage véhicules pour ${clients[i].id}: $e');
          }
        }
      }

      // 4. Appliquer les filtres si nécessaire
      if (filters != null && filters.isNotEmpty) {
        return _applyFilters(clients, filters);
      }

      return clients;
    } catch (e) {
      if (kDebugMode) {
        print('❌ ERREUR FATALE dans getAllClients: $e');
      }
      if (kDebugMode) {
        print(StackTrace.current);
      }
      return [];
    }
  }

  // Applique les filtres manuellement à une liste de clients
  List<Client> _applyFilters(
    List<Client> clients,
    Map<String, dynamic> filters,
  ) {
    return clients.where((client) {
      bool shouldInclude = true;
      filters.forEach((key, value) {
        if (key == 'notifications_enabled') {
          shouldInclude = shouldInclude && client.notificationsEnabled == value;
        }
        if (key == 'type_client' && value != null) {
          shouldInclude = shouldInclude && client.typeClient == value;
        }
      });
      return shouldInclude;
    }).toList();
  }

  // Récupère l'email d'un utilisateur depuis le service auth de Supabase
  // Note: cette méthode nécessite des droits admin, donc on pourrait avoir des limitations
  Future<String?> _getEmailFromAuth(String userId) async {
    try {
      // Simplifié pour éviter les erreurs d'autorisation
      // On pourrait aussi stocker l'email directement dans la table client
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la récupération de l\'email: $e');
      }
      return null;
    }
  }

  // Compte le nombre de véhicules associés à un client
  Future<int> _countVehiclesForClient(String userId) async {
    try {
      final response = await SupabaseConfig.client
          .from('user_vehicles')
          .select('*')
          .eq('user_id', userId);

      return response.length;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors du comptage des véhicules: $e');
      }
      return 0;
    }
  }

  // Get active clients (avec notifications activées)
  Future<List<Client>> getActiveClients({
    String? orderBy,
    bool ascending = false,
    int? limit,
    int? offset,
  }) async {
    return getAllClients(
      orderBy: orderBy,
      ascending: ascending,
      limit: limit,
      offset: offset,
      filters: {'notifications_enabled': true},
    );
  }

  // Get a client by ID with enriched data
  Future<Client?> getClientById(String id) async {
    try {
      final data =
          await SupabaseConfig.client
              .from(_clientsTable)
              .select('*, auth:auth.users(email)')
              .eq('id', id)
              .single();

      // Extract email from auth join if available
      String? email = data['auth'] != null ? data['auth']['email'] : null;

      // Remove auth data before conversion
      var clientData = Map<String, dynamic>.from(data);
      clientData.remove('auth');

      Client client = Client.fromJson(clientData);

      // Count vehicles
      int vehicleCount = await _countVehiclesForClient(client.id);

      return client.copyWith(email: email, vehicleCount: vehicleCount);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors de la récupération du client: $e');
      }
      return null;
    }
  }

  // Create a new client
  Future<Client?> createClient(Client client) async {
    final data = await _databaseService.create(_clientsTable, client.toJson());
    if (data == null) return null;
    return Client.fromJson(data);
  }

  // Update a client
  Future<Client?> updateClient(Client client) async {
    final data = await _databaseService.update(
      _clientsTable,
      client.id,
      client.toJson(),
    );
    if (data == null) return null;
    return Client.fromJson(data);
  }

  // Delete a client
  Future<void> deleteClient(String id) async {
    await _databaseService.delete(_clientsTable, id);
  }

  // Count clients with optional filters
  Future<int> countClients({Map<String, dynamic>? filters}) async {
    return await _databaseService.count(_clientsTable, filters: filters);
  }

  // Get recently created clients (in last X days)
  Future<List<Client>> getRecentlyCreatedClients(
    int days, {
    int limit = 10,
  }) async {
    final now = DateTime.now();
    final dateCutoff = now.subtract(Duration(days: days));

    final clients = await getAllClients(
      orderBy: 'created_at',
      ascending: false,
      limit: limit,
    );

    return clients.where((client) {
      return client.createdAt.isAfter(dateCutoff);
    }).toList();
  }

  // Get clients with most vehicles
  Future<List<Client>> getClientsWithMostVehicles({int limit = 10}) async {
    final clients = await getAllClients();

    // Trier par nombre de véhicules (ordre décroissant)
    clients.sort((a, b) => b.vehicleCount.compareTo(a.vehicleCount));

    // Retourner uniquement les premiers clients (limite)
    return clients.take(limit).toList();
  }

  // Get client statistics for dashboard
  Future<Map<String, dynamic>> getClientStats() async {
    try {
      if (kDebugMode) {
        print('📊 Récupération des statistiques clients...');
      }

      // Récupérer tous les clients
      final clients = await getAllClients();
      if (kDebugMode) {
        print('👥 Nombre total de clients: ${clients.length}');
      }

      // Calculer les statistiques
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      // Clients créés ce mois-ci
      final newClientsThisMonth =
          clients
              .where((client) => client.createdAt.isAfter(startOfMonth))
              .length;

      // Clients professionnels
      final professionalClients =
          clients
              .where(
                (client) => client.typeClient?.toLowerCase() == 'professionnel',
              )
              .length;

      // Clients avec notifications activées
      final clientsWithNotifications =
          clients.where((client) => client.notificationsEnabled).length;

      // Clients avec au moins un véhicule
      final clientsWithVehicles =
          clients.where((client) => client.vehicleCount > 0).length;

      if (kDebugMode) {
        print(
        '📈 Stats calculées - Nouveaux: $newClientsThisMonth, Pros: $professionalClients',
      );
      }
      if (kDebugMode) {
        print(
        '📈 Stats calculées - Avec notifs: $clientsWithNotifications, Avec véhicules: $clientsWithVehicles',
      );
      }

      return {
        'total': clients.length,
        'new_month': newClientsThisMonth,
        'professional': professionalClients,
        'with_notifications': clientsWithNotifications,
        'with_vehicles': clientsWithVehicles,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors du calcul des statistiques client: $e');
      }
      return {
        'total': 0,
        'new_month': 0,
        'professional': 0,
        'with_notifications': 0,
        'with_vehicles': 0,
      };
    }
  }

  // Get professional clients only
  Future<List<Client>> getProfessionalClients({
    String? orderBy,
    bool ascending = false,
    int? limit,
    int? offset,
  }) async {
    try {
      final data = await SupabaseConfig.client
          .from(_clientsTable)
          .select('*')
          .eq('type_client', 'Professionnel')
          .order(orderBy ?? 'created_at', ascending: ascending);

      List<Client> clients = data.map((json) => Client.fromJson(json)).toList();

      // Enrichir avec le nombre de véhicules
      for (int i = 0; i < clients.length; i++) {
        int vehicleCount = await _countVehiclesForClient(clients[i].id);
        clients[i] = clients[i].copyWith(vehicleCount: vehicleCount);
      }

      return clients;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la récupération des clients professionnels: $e');
      }
      return [];
    }
  }

  // Récupérer les véhicules d'un client avec des détails complets
  Future<List<Map<String, dynamic>>> getVehiclesForClient(String userId) async {
    try {
      if (kDebugMode) {
        print('🔍 Récupération des véhicules pour le client: $userId');
      }

      // Liste des noms de tables possibles pour les véhicules des utilisateurs
      final possibleTableNames = [
        _userVehiclesTable, // user_vehicule
        'user_vehicules', // avec un "s"
        'user_vehicles', // autre orthographe
        'vehicule_user', // ordre inversé
        'vehicules_user', // ordre inversé avec un "s"
      ];

      List<Map<String, dynamic>>? joinData;
      String? usedTable;

      // Essayer chaque nom de table possible
      for (final tableName in possibleTableNames) {
        try {
          if (kDebugMode) {
            print('🔍 Essai avec la table "$tableName"...');
          }
          final result = await SupabaseConfig.client
              .from(tableName)
              .select('immatriculation')
              .eq('user_id', userId);

          joinData = List<Map<String, dynamic>>.from(result);
          usedTable = tableName;
          if (kDebugMode) {
            print('✅ Succès avec la table "$tableName"!');
          }
          break;
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Échec avec la table "$tableName": $e');
          }
        }
      }

      if (joinData == null || joinData.isEmpty) {
        if (kDebugMode) {
          print('📊 Aucun véhicule trouvé pour ce client avec aucune table');
        }
        return [];
      }

      if (kDebugMode) {
        print('📊 Immatriculations trouvées dans $usedTable: ${joinData.length}');
      }

      // Extraire les immatriculations
      final immatriculations =
          joinData.map((item) => item['immatriculation'].toString()).toList();

      // Essayer différents noms pour la table des voitures
      final possibleCarTableNames = ['voiture', 'vehicule', 'vehicles', 'cars'];

      List<Map<String, dynamic>>? vehiclesData;
      String? usedCarTable;

      // Essayer chaque nom de table possible pour les voitures
      for (final tableName in possibleCarTableNames) {
        try {
          if (kDebugMode) {
            print('🔍 Essai avec la table "$tableName" pour les voitures...');
          }

          if (immatriculations.isEmpty) {
            if (kDebugMode) {
              print('⚠️ Aucune immatriculation à rechercher');
            }
            break;
          }

          // Utiliser une approche de filtrage in
          final result = await SupabaseConfig.client
              .from(tableName)
              .select('*')
              .filter('immatriculation', 'in', immatriculations);

          vehiclesData = List<Map<String, dynamic>>.from(result);
          usedCarTable = tableName;
          if (kDebugMode) {
            print('✅ Succès avec la table "$tableName" pour les voitures!');
          }
          break;
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Échec avec la table "$tableName" pour les voitures: $e');
          }
        }
      }

      if (vehiclesData == null || vehiclesData.isEmpty) {
        if (kDebugMode) {
          print('📊 Aucun détail de véhicule trouvé dans aucune table');
        }
        return [];
      }

      if (kDebugMode) {
        print(
          '📊 Détails de ${vehiclesData.length} véhicules récupérés depuis $usedCarTable',
        );
      }

      return vehiclesData;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors de la récupération des véhicules: $e');
      }
      if (kDebugMode) {
        print(StackTrace.current);
      } 
      return [];
    }
  }

  // Méthode pour lister toutes les tables disponibles
  Future<void> listAllTables() async {
    try {
      if (kDebugMode) {
        print('📋 Tentative de listage des tables disponibles...');
      }

      // Requête SQL pour lister toutes les tables du schéma public
      final result = await SupabaseConfig.client.rpc('list_all_tables');

      if (kDebugMode) {
        print('📊 Tables trouvées: $result');
      }
      return;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors du listage des tables: $e');
      }

      // Essayer une autre approche
      try {
        final result = await SupabaseConfig.client
            .from('pg_tables')
            .select('tablename')
            .eq('schemaname', 'public');

        if (kDebugMode) {
          print('📊 Tables (approche 2): $result');
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Échec de la seconde approche: $e');
        }
      }
    }
  }
}
