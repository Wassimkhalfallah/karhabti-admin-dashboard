import '../models/vehicle_model.dart';
import 'database_service.dart';

class VehicleService {
  final DatabaseService _databaseService = DatabaseService();
  static const String _vehiclesTable = 'vehicles';
  
  // Get all vehicles with optional filtering and pagination
  Future<List<Vehicle>> getAllVehicles({
    String? orderBy,
    bool ascending = false,
    int? limit,
    int? offset,
    Map<String, dynamic>? filters,
  }) async {
    final data = await _databaseService.getAll(
      _vehiclesTable,
      orderBy: orderBy,
      ascending: ascending,
      limit: limit,
      offset: offset,
      filters: filters,
    );
    
    return data.map((json) => Vehicle.fromJson(json)).toList();
  }
  
  // Get vehicles by type (particulier/professionnel)
  Future<List<Vehicle>> getVehiclesByType(String type, {
    String? orderBy,
    bool ascending = false,
    int? limit,
    int? offset,
  }) async {
    return getAllVehicles(
      orderBy: orderBy,
      ascending: ascending,
      limit: limit,
      offset: offset,
      filters: {'type': type},
    );
  }
  
  // Get a vehicle by ID
  Future<Vehicle?> getVehicleById(String id) async {
    final data = await _databaseService.getById(_vehiclesTable, id);
    if (data == null) return null;
    return Vehicle.fromJson(data);
  }
  
  // Get vehicles by client ID
  Future<List<Vehicle>> getVehiclesByClientId(String clientId) async {
    return getAllVehicles(filters: {'client_id': clientId});
  }
  
  // Create a new vehicle
  Future<Vehicle?> createVehicle(Vehicle vehicle) async {
    final data = await _databaseService.create(_vehiclesTable, vehicle.toJson());
    if (data == null) return null;
    return Vehicle.fromJson(data);
  }
  
  // Update a vehicle
  Future<Vehicle?> updateVehicle(Vehicle vehicle) async {
    final data = await _databaseService.update(_vehiclesTable, vehicle.id, vehicle.toJson());
    if (data == null) return null;
    return Vehicle.fromJson(data);
  }
  
  // Delete a vehicle
  Future<void> deleteVehicle(String id) async {
    await _databaseService.delete(_vehiclesTable, id);
  }
  
  // Count vehicles with optional filters
  Future<int> countVehicles({Map<String, dynamic>? filters}) async {
    return await _databaseService.count(_vehiclesTable, filters: filters);
  }
  
  // Count vehicles by type
  Future<Map<String, int>> countVehiclesByType() async {
    final particulierCount = await countVehicles(filters: {'type': 'particulier'});
    final professionnelCount = await countVehicles(filters: {'type': 'professionnel'});
    
    return {
      'particulier': particulierCount,
      'professionnel': professionnelCount,
      'total': particulierCount + professionnelCount,
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
}
