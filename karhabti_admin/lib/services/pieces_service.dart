import '../models/piece_model.dart';
import 'database_service.dart';

class PiecesService {
  final DatabaseService _databaseService = DatabaseService();
  
  // Table names for different piece types
  static const String _pneusTable = 'pneus';
  static const String _vidangeTable = 'vidange';
  static const String _amortisseursTable = 'amortisseurs';
  static const String _batterieTable = 'batterie';
  static const String _embrayageTable = 'embrayage';
  static const String _freinsTable = 'freins';
  static const String _courroieTable = 'courroie';
  
  // Get all pieces of a specific type
  Future<List<Piece>> getAllPieces(String pieceType, {
    String? orderBy,
    bool ascending = false,
    int? limit,
    int? offset,
    Map<String, dynamic>? filters,
  }) async {
    final table = _getTableForType(pieceType);
    final data = await _databaseService.getAll(
      table,
      orderBy: orderBy,
      ascending: ascending,
      limit: limit,
      offset: offset,
      filters: filters,
    );
    
    return data.map((json) => Piece.fromJson(json, pieceType)).toList();
  }
  
  // Get a piece by ID
  Future<Piece?> getPieceById(String pieceType, String id) async {
    final table = _getTableForType(pieceType);
    final data = await _databaseService.getById(table, id);
    
    if (data == null) return null;
    return Piece.fromJson(data, pieceType);
  }
  
  // Create a new piece
  Future<Piece?> createPiece(Piece piece) async {
    final pieceType = _getPieceType(piece);
    final table = _getTableForType(pieceType);
    
    final data = await _databaseService.create(table, piece.toJson());
    if (data == null) return null;
    
    return Piece.fromJson(data, pieceType);
  }
  
  // Update a piece
  Future<Piece?> updatePiece(Piece piece) async {
    final pieceType = _getPieceType(piece);
    final table = _getTableForType(pieceType);
    
    final data = await _databaseService.update(table, piece.id, piece.toJson());
    if (data == null) return null;
    
    return Piece.fromJson(data, pieceType);
  }
  
  // Delete a piece
  Future<void> deletePiece(String pieceType, String id) async {
    final table = _getTableForType(pieceType);
    await _databaseService.delete(table, id);
  }
  
  // Count pieces with optional filters
  Future<int> countPieces(String pieceType, {Map<String, dynamic>? filters}) async {
    final table = _getTableForType(pieceType);
    return await _databaseService.count(table, filters: filters);
  }
  
  // Helper method to get table name from piece type
  String _getTableForType(String pieceType) {
    switch (pieceType) {
      case 'pneu':
        return _pneusTable;
      case 'vidange':
        return _vidangeTable;
      case 'amortisseur':
        return _amortisseursTable;
      case 'batterie':
        return _batterieTable;
      case 'embrayage':
        return _embrayageTable;
      case 'frein':
        return _freinsTable;
      case 'courroie':
        return _courroieTable;
      default:
        throw Exception('Type de pièce inconnu: $pieceType');
    }
  }
  
  // Helper method to get piece type from piece instance
  String _getPieceType(Piece piece) {
    if (piece is Pneu) return 'pneu';
    if (piece is Vidange) return 'vidange';
    if (piece is Amortisseur) return 'amortisseur';
    if (piece is Batterie) return 'batterie';
    if (piece is Embrayage) return 'embrayage';
    if (piece is Frein) return 'frein';
    if (piece is Courroie) return 'courroie';
    
    throw Exception('Type de pièce inconnu');
  }
  
  // Get all piece types for dropdown lists
  List<String> getAllPieceTypes() {
    return [
      'pneu',
      'vidange',
      'amortisseur',
      'batterie',
      'embrayage',
      'frein',
      'courroie',
    ];
  }
}
