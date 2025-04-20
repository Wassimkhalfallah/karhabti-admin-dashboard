import '../models/client_model.dart';
import 'database_service.dart';

class ClientService {
  final DatabaseService _databaseService = DatabaseService();
  static const String _clientsTable = 'clients';
  
  // Get all clients with optional filtering and pagination
  Future<List<Client>> getAllClients({
    String? orderBy,
    bool ascending = false,
    int? limit,
    int? offset,
    Map<String, dynamic>? filters,
  }) async {
    final data = await _databaseService.getAll(
      _clientsTable,
      orderBy: orderBy,
      ascending: ascending,
      limit: limit,
      offset: offset,
      filters: filters,
    );
    
    return data.map((json) => Client.fromJson(json)).toList();
  }
  
  // Get active clients
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
      filters: {'is_active': true},
    );
  }
  
  // Get a client by ID
  Future<Client?> getClientById(String id) async {
    final data = await _databaseService.getById(_clientsTable, id);
    if (data == null) return null;
    return Client.fromJson(data);
  }
  
  // Create a new client
  Future<Client?> createClient(Client client) async {
    final data = await _databaseService.create(_clientsTable, client.toJson());
    if (data == null) return null;
    return Client.fromJson(data);
  }
  
  // Update a client
  Future<Client?> updateClient(Client client) async {
    final data = await _databaseService.update(_clientsTable, client.id, client.toJson());
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
  
  // Get recently active clients (login in last X days)
  Future<List<Client>> getRecentlyActiveClients(int days, {int limit = 10}) async {
    final now = DateTime.now();
    final dateCutoff = now.subtract(Duration(days: days));
    
    final clients = await getAllClients(orderBy: 'last_login', ascending: false, limit: limit);
    
    return clients.where((client) {
      return client.lastLogin != null && client.lastLogin!.isAfter(dateCutoff);
    }).toList();
  }
  
  // Get new clients (registered in last X days)
  Future<List<Client>> getNewClients(int days, {int limit = 10}) async {
    final now = DateTime.now();
    final dateCutoff = now.subtract(Duration(days: days));
    
    final clients = await getAllClients(orderBy: 'created_at', ascending: false, limit: limit);
    
    return clients.where((client) {
      return client.createdAt.isAfter(dateCutoff);
    }).toList();
  }
  
  // Get client activity statistics
  Future<Map<String, dynamic>> getClientActivityStats() async {
    final totalClients = await countClients();
    final activeClients = await countClients(filters: {'is_active': true});
    final newClientsLast30Days = (await getNewClients(30)).length;
    final recentlyActiveClients = (await getRecentlyActiveClients(7)).length;
    
    return {
      'total': totalClients,
      'active': activeClients,
      'new_30_days': newClientsLast30Days,
      'active_7_days': recentlyActiveClients,
    };
  }
}
