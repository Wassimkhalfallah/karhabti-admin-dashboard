import 'package:flutter/foundation.dart';

import '../models/vehicle_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VehicleService {
  final _supabase = Supabase.instance.client;
  static const String _vehiclesTable =
      'voiture'; // Table des véhicules (clé primaire: immatriculation)
  static const String _userVehiclesTable =
      'user_vehicles'; // Table de liaison (user_id, immatriculation)
  static const String _clientsTable =
      'client'; // Table des clients (id, nom_client, etc.)

  // Get all vehicles with optional filtering and pagination and client names
  Future<List<Vehicle>> getAllVehicles({
    String? orderBy,
    bool ascending = false,
    int? limit,
    int? offset,
    Map<String, dynamic>? filters,
    String? searchQuery,
  }) async {
    // Get vehicles data
    // Spécifier explicitement les colonnes à récupérer selon la structure exacte de la table
    dynamic query = _supabase
        .from(_vehiclesTable)
        .select(
          'immatriculation, marque, modele, annee, total_km, daily_km, moteur, poids',
        );

    // Apply filters if provided, en s'assurant de ne jamais utiliser 'type' comme filtre
    if (filters != null) {
      filters.forEach((key, value) {
        // Ne jamais essayer de filtrer par 'type' au niveau DB
        if (key != 'type') {
          query = query.eq(key, value);
        }
      });
    }

    // Apply search if provided
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or(
        'immatriculation.ilike.%$searchQuery%,marque.ilike.%$searchQuery%,modele.ilike.%$searchQuery%',
      );
    }

    // Apply ordering if provided
    if (orderBy != null) {
      query = query.order(orderBy, ascending: ascending);
    }

    // Apply pagination if provided
    if (limit != null) {
      query = query.limit(limit);
    }

    if (offset != null) {
      query = query.range(offset, offset + (limit ?? 20) - 1);
    }

    try {
      final data = await query;
      List<Vehicle> vehicles = [];

      // Conversion avec gestion des erreurs
      for (var json in data) {
        try {
          vehicles.add(Vehicle.fromJson(json));
        } catch (e) {
          if (kDebugMode) {
            print('Error converting vehicle data: $e');
          }
          if (kDebugMode) {
            print('Problematic JSON: $json');
          }
          // Continuer avec le véhicule suivant
        }
      }

      // Get client information for each vehicle
      for (var i = 0; i < vehicles.length; i++) {
        try {
          if (vehicles[i].registrationNumber.isEmpty) {
            if (kDebugMode) {
              print('Warning: registrationNumber is empty for vehicle');
            }
            continue;
          }

          // Get user_id from user_vehicules table
          final userVehicleData =
              await _supabase
                  .from(_userVehiclesTable)
                  .select('user_id')
                  .eq('immatriculation', vehicles[i].registrationNumber)
                  .maybeSingle();

          if (userVehicleData != null) {
            final userId = userVehicleData['user_id'];
            if (userId != null) {
              // Get client name from client table
              final clientData =
                  await _supabase
                      .from(_clientsTable)
                      .select('nom_client')
                      .eq('id', userId)
                      .maybeSingle();

              if (clientData != null) {
                final clientName = clientData['nom_client'];
                if (clientName != null) {
                  // Update vehicle with client name and user_id
                  vehicles[i] = vehicles[i].copyWith(
                    clientName: clientName,
                    userId: userId,
                  );
                }
              }
            }
          }
        } catch (e) {
          // Continue with next vehicle if any error occurs
          if (kDebugMode) {
            print('Error fetching client for vehicle: $e');
          }
        }
      }

      return vehicles;
    } catch (e) {
      if (kDebugMode) {
        print('Error in getAllVehicles: $e');
      }
      return []; // Retourner une liste vide en cas d'erreur
    }
    // Cette ligne est inaccessible
  }

  // Get vehicles by type (particulier/professionnel)
  // Cette méthode ne peut pas filtrer directement par type car ce champ n'existe pas dans la BDD
  // Nous récupérons tous les véhicules puis filtrons côté client
  Future<List<Vehicle>> getVehiclesByType(
    String type, {
    String? orderBy,
    bool ascending = false,
    int? limit,
    int? offset,
  }) async {
    // Récupérer tous les véhicules
    final allVehicles = await getAllVehicles(
      orderBy: orderBy,
      ascending: ascending,
      limit: null, // Pas de limite pour s'assurer d'avoir tous les véhicules
      offset: null,
      filters: null, // Pas de filtre sur type car cette colonne n'existe pas
    );

    // Filtrer côté client par le champ type
    final filteredVehicles =
        allVehicles
            .where(
              (vehicle) => vehicle.type.toLowerCase() == type.toLowerCase(),
            )
            .toList();

    // Appliquer la pagination côté client
    if (offset != null && limit != null) {
      final startIndex = offset;
      final endIndex = offset + limit;
      if (startIndex < filteredVehicles.length) {
        return filteredVehicles.sublist(
          startIndex,
          endIndex < filteredVehicles.length
              ? endIndex
              : filteredVehicles.length,
        );
      }
      return [];
    }

    // Si pas de pagination, retourner tous les véhicules filtrés
    return filteredVehicles;
  }

  // Get a vehicle by ID with client information
  Future<Vehicle?> getVehicleById(String immatriculation) async {
    try {
      final data = await _supabase
          .from(_vehiclesTable)
          .select(
            'immatriculation, marque, modele, annee, total_km, daily_km, moteur, poids',
          )
          .eq('immatriculation', immatriculation)
          .single()
          .catchError((_) => null);

      Vehicle vehicle = Vehicle.fromJson(data);

      // Vérifier que le registrationNumber n'est pas null
      try {
        // Get client ID from user_vehicules table
        final userVehicleData =
            await _supabase
                .from(_userVehiclesTable)
                .select('user_id')
                .eq('immatriculation', vehicle.registrationNumber)
                .maybeSingle();

        if (userVehicleData != null) {
          final userId = userVehicleData['user_id'];
          if (userId != null) {
            // Get client name from client table
            final clientData =
                await _supabase
                    .from(_clientsTable)
                    .select('nom_client')
                    .eq('id', userId)
                    .maybeSingle();

            if (clientData != null) {
              final clientName = clientData['nom_client'];
              if (clientName != null) {
                // Update vehicle with client name
                vehicle = vehicle.copyWith(clientName: clientName);
              }
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print(
            'Error fetching client for vehicle ${vehicle.registrationNumber}: $e',
          );
        }
      }
    
      return vehicle;
    } catch (e) {
      if (kDebugMode) {
        print('Error in getVehicleById: $e');
      }
      return null;
    }
  }

  // Get vehicles by user ID through user_vehicules table
  Future<List<Vehicle>> getVehiclesByUserId(String userId) async {
    try {
      final response = await _supabase
          .from(_userVehiclesTable)
          .select('immatriculation')
          .eq('user_id', userId);

      if (response.isEmpty) {
        return [];
      }

      List<Vehicle> vehicles = [];
      for (var item in response) {
        final immatriculation = item['immatriculation'];
        if (immatriculation != null) {
          try {
            final vehicleData =
                await _supabase
                    .from(_vehiclesTable)
                    .select(
                      'immatriculation, marque, modele, annee, total_km, daily_km, moteur, poids',
                    )
                    .eq('immatriculation', immatriculation)
                    .maybeSingle();

            if (vehicleData != null) {
              Vehicle vehicle = Vehicle.fromJson(vehicleData);
              // Add user information
              vehicle = vehicle.copyWith(userId: userId);

              final clientData =
                  await _supabase
                      .from(_clientsTable)
                      .select('nom_client')
                      .eq('id', userId)
                      .maybeSingle();

              if (clientData != null) {
                vehicle = vehicle.copyWith(
                  clientName: clientData['nom_client'],
                );
              }

              vehicles.add(vehicle);
            }
          } catch (e) {
            if (kDebugMode) {
              print(
                'Error fetching vehicle with immatriculation $immatriculation: $e',
              );
            }
          }
        }
      }

      return vehicles;
    } catch (e) {
      if (kDebugMode) {
        print('Error in getVehiclesByUserId: $e');
      }
      return [];
    }
  }

  // Create a new vehicle and add entry to user_vehicules if userId is provided
  Future<Vehicle?> createVehicle(Vehicle vehicle) async {
    try {
      // First insert the vehicle
      final vehicleData =
          await _supabase
              .from(_vehiclesTable)
              .insert(vehicle.toJson())
              .select()
              .single();

      // If userId is provided, create entry in user_vehicules table
      if (vehicle.userId.isNotEmpty) {
        await _supabase.from(_userVehiclesTable).insert({
          'immatriculation': vehicle.registrationNumber,
          'user_id': vehicle.userId,
        });
      }

      return Vehicle.fromJson(vehicleData);
    } catch (error) {
      if (kDebugMode) {
        print('Error creating vehicle: $error');
      }
      return null;
    }
  }

  // Update vehicle information and user relationship
  Future<Vehicle?> updateVehicle(Vehicle vehicle) async {
    try {
      // First, update in voiture table
      final vehicleData =
          await _supabase
              .from(_vehiclesTable)
              .update(vehicle.toJson())
              .eq(
                'immatriculation',
                vehicle.registrationNumber,
              ) // Utiliser immatriculation comme clé primaire
              .select()
              .single();

      // Then check if there's an existing user_vehicules entry
      final existingUserVehicle =
          await _supabase
              .from(_userVehiclesTable)
              .select()
              .eq('immatriculation', vehicle.registrationNumber)
              .maybeSingle();

      if (existingUserVehicle != null) {
        // Update existing entry if userId has changed
        if (existingUserVehicle['user_id'] != vehicle.userId &&
            vehicle.userId.isNotEmpty) {
          await _supabase
              .from(_userVehiclesTable)
              .update({'user_id': vehicle.userId})
              .eq('immatriculation', vehicle.registrationNumber);
        }
      } else if (vehicle.userId.isNotEmpty) {
        // Create new entry if doesn't exist
        await _supabase.from(_userVehiclesTable).insert({
          'immatriculation': vehicle.registrationNumber,
          'user_id': vehicle.userId,
        });
      }

      return Vehicle.fromJson(vehicleData);
    } catch (error) {
      if (kDebugMode) {
        print('Error updating vehicle: $error');
      }
      return null;
    }
  }

  // Delete a vehicle and its entry in user_vehicules
  Future<void> deleteVehicle(String immatriculation) async {
    try {
      // Delete from user_vehicules first to respect foreign key constraints
      await _supabase
          .from(_userVehiclesTable)
          .delete()
          .eq('immatriculation', immatriculation);

      // Then delete from voiture table
      await _supabase
          .from(_vehiclesTable)
          .delete()
          .eq('immatriculation', immatriculation);
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting vehicle: $e');
      }
      rethrow;
    }
  }

  // Count vehicles with optional filters
  Future<int> countVehicles({Map<String, dynamic>? filters}) async {
    var query = _supabase.from(_vehiclesTable).select('immatriculation');

    if (filters != null) {
      filters.forEach((key, value) {
        query = query.eq(key, value);
      });
    }

    final response = await query;
    return response.length;
  }

  // Count vehicles by type
  Future<Map<String, int>> countVehiclesByType() async {
    // Récupérer tous les véhicules car le type n'est pas stocké en BDD
    final allVehicles = await getAllVehicles();

    // Compter les types côté client
    final particulierCount =
        allVehicles.where((v) => v.type.toLowerCase() == 'particulier').length;
    final professionnelCount =
        allVehicles
            .where((v) => v.type.toLowerCase() == 'professionnel')
            .length;
    final totalCount = allVehicles.length;

    return {
      'particulier': particulierCount,
      'professionnel': professionnelCount,
      'total': totalCount,
    };
  }

  // Get distribution of vehicle brands for analytics
  Future<Map<String, int>> getVehicleBrandDistribution() async {
    final vehicles = await getAllVehicles();
    Map<String, int> distribution = {};

    for (var vehicle in vehicles) {
      if (distribution.containsKey(vehicle.brand)) {
        distribution[vehicle.brand] = distribution[vehicle.brand]! + 1;
      } else {
        distribution[vehicle.brand] = 1;
      }
    }

    return distribution;
  }

  // Get distribution of fuel types for analytics
  Future<Map<String, int>> getFuelTypeDistribution() async {
    final vehicles = await getAllVehicles();
    Map<String, int> distribution = {};

    for (var vehicle in vehicles) {
      if (distribution.containsKey(vehicle.fuelType)) {
        distribution[vehicle.fuelType] = distribution[vehicle.fuelType]! + 1;
      } else {
        distribution[vehicle.fuelType] = 1;
      }
    }

    return distribution;
  }

  // Export vehicles data to CSV format
  Future<String> exportVehiclesToCSV() async {
    final vehicles = await getAllVehicles();

    // Create CSV header
    String csv =
        'Immatriculation,Marque,Modèle,Année,Kilométrage Total,Kilométrage Quotidien,Type de Carburant,Type de Véhicule,Client\n';

    // Add data rows
    for (var vehicle in vehicles) {
      csv +=
          '${vehicle.registrationNumber},${vehicle.brand},${vehicle.model},${vehicle.year},${vehicle.totalKm},${vehicle.dailyKm},${vehicle.fuelType},${vehicle.type},${vehicle.clientName ?? ''}\n';
    }

    return csv;
  }

  Future<List<Map<String, dynamic>>> getVehiculesDuGarage(String garageId) async {
    try {
      final rdv = await _supabase
          .from('rendez_vous')
          .select('immatriculation')
          .eq('garage_id', garageId)
          .neq('statut', 'annule');

      final immats = rdv
          .map((e) => e['immatriculation'] as String?)
          .whereType<String>()
          .toSet()
          .toList();
      if (immats.isEmpty) return [];

      final voitures = await _supabase
          .from('voiture')
          .select(
            'immatriculation, marque, modele, moteur, annee, total_km, daily_km',
          )
          .inFilter('immatriculation', immats);

      final preds = await _supabase
          .from('predictions')
          .select(
            'fk_immatriculation, battery_health, brake_wear, tire_wear, oil_change, belt_risk, clutch_wear, "ShockAbsorber_Wear", next_replacement_date',
          )
          .inFilter('fk_immatriculation', immats);

      final uv = await _supabase
          .from('user_vehicles')
          .select('immatriculation, user_id')
          .inFilter('immatriculation', immats);
      final userIds = uv
          .map((e) => e['user_id'] as String?)
          .whereType<String>()
          .toSet()
          .toList();

      final clients = userIds.isEmpty
          ? <Map<String, dynamic>>[]
          : await _supabase
              .from('client')
              .select('id, nom_client, telephone')
              .inFilter('id', userIds);

      final predByImmat = {for (final p in preds) p['fk_immatriculation']: p};
      final userByImmat = {for (final u in uv) u['immatriculation']: u['user_id']};
      final clientById = {for (final c in clients) c['id']: c};

      return voitures.map((v) {
        final userId = userByImmat[v['immatriculation']];
        return {
          ...v,
          'prediction': predByImmat[v['immatriculation']],
          'client': userId != null ? clientById[userId] : null,
        };
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getVehiculesDuGarage: $e');
      }
      return [];
    }
  }
}
