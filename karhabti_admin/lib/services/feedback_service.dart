import '../models/feedback_model.dart';
import 'database_service.dart';

class FeedbackService {
  final DatabaseService _databaseService = DatabaseService();
  static const String _feedbackTable = 'feedback';
  
  // Get all feedback messages with optional filtering and pagination
  Future<List<Feedback>> getAllFeedback({
    String? orderBy,
    bool ascending = false,
    int? limit,
    int? offset,
    Map<String, dynamic>? filters,
  }) async {
    final data = await _databaseService.getAll(
      _feedbackTable,
      orderBy: orderBy ?? 'created_at',
      ascending: ascending,
      limit: limit,
      offset: offset,
      filters: filters,
    );
    
    return data.map((json) => Feedback.fromJson(json)).toList();
  }
  
  // Get unread feedback messages
  Future<List<Feedback>> getUnreadFeedback({
    String? orderBy,
    bool ascending = false,
    int? limit,
    int? offset,
  }) async {
    return getAllFeedback(
      orderBy: orderBy ?? 'created_at',
      ascending: ascending,
      limit: limit,
      offset: offset,
      filters: {'is_read': false, 'is_archived': false},
    );
  }
  
  // Get feedback by status
  Future<List<Feedback>> getFeedbackByStatus(String status, {
    String? orderBy,
    bool ascending = false,
    int? limit,
    int? offset,
  }) async {
    return getAllFeedback(
      orderBy: orderBy ?? 'created_at',
      ascending: ascending,
      limit: limit,
      offset: offset,
      filters: {'status': status},
    );
  }
  
  // Get a feedback by ID
  Future<Feedback?> getFeedbackById(String id) async {
    final data = await _databaseService.getById(_feedbackTable, id);
    if (data == null) return null;
    return Feedback.fromJson(data);
  }
  
  // Get feedback by client ID
  Future<List<Feedback>> getFeedbackByClientId(String clientId, {
    String? orderBy,
    bool ascending = false,
    int? limit,
    int? offset,
  }) async {
    return getAllFeedback(
      orderBy: orderBy ?? 'created_at',
      ascending: ascending,
      limit: limit,
      offset: offset,
      filters: {'client_id': clientId},
    );
  }
  
  // Create a new feedback
  Future<Feedback?> createFeedback(Feedback feedback) async {
    final data = await _databaseService.create(_feedbackTable, feedback.toJson());
    if (data == null) return null;
    return Feedback.fromJson(data);
  }
  
  // Update a feedback
  Future<Feedback?> updateFeedback(Feedback feedback) async {
    final data = await _databaseService.update(_feedbackTable, feedback.id, feedback.toJson());
    if (data == null) return null;
    return Feedback.fromJson(data);
  }
  
  // Mark feedback as read
  Future<Feedback?> markAsRead(String id) async {
    final feedback = await getFeedbackById(id);
    if (feedback == null) return null;
    
    final updatedFeedback = feedback.markAsRead();
    return updateFeedback(updatedFeedback);
  }
  
  // Respond to feedback
  Future<Feedback?> respondToFeedback(String id, String response) async {
    final feedback = await getFeedbackById(id);
    if (feedback == null) return null;
    
    final updatedFeedback = feedback.respond(response);
    return updateFeedback(updatedFeedback);
  }
  
  // Archive feedback
  Future<Feedback?> archiveFeedback(String id) async {
    final feedback = await getFeedbackById(id);
    if (feedback == null) return null;
    
    final updatedFeedback = feedback.archive();
    return updateFeedback(updatedFeedback);
  }
  
  // Delete a feedback
  Future<void> deleteFeedback(String id) async {
    await _databaseService.delete(_feedbackTable, id);
  }
  
  // Count feedback with optional filters
  Future<int> countFeedback({Map<String, dynamic>? filters}) async {
    return await _databaseService.count(_feedbackTable, filters: filters);
  }
  
  // Get feedback statistics
  Future<Map<String, int>> getFeedbackStats() async {
    final totalCount = await countFeedback();
    final unreadCount = await countFeedback(filters: {'is_read': false});
    final pendingCount = await countFeedback(filters: {'status': 'pending'});
    final respondedCount = await countFeedback(filters: {'status': 'responded'});
    final archivedCount = await countFeedback(filters: {'status': 'archived'});
    
    return {
      'total': totalCount,
      'unread': unreadCount,
      'pending': pendingCount,
      'responded': respondedCount,
      'archived': archivedCount,
    };
  }
}
