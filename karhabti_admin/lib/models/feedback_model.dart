import 'package:intl/intl.dart';

// Modu00e8le pour les messages/feedbacks des clients
class Feedback {
  final String id;
  final String clientId;
  final String? clientName; // Pour l'affichage dans l'interface d'administration
  final String subject;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final bool isArchived;
  final String? response;
  final DateTime? respondedAt;
  final String status; // 'pending', 'responded', 'archived'
  final String? vehicleId;
  final String? vehicleInfo; // Marque et modu00e8le pour l'affichage
  
  Feedback({
    required this.id,
    required this.clientId,
    this.clientName,
    required this.subject,
    required this.message,
    required this.createdAt,
    required this.isRead,
    required this.isArchived,
    this.response,
    this.respondedAt,
    required this.status,
    this.vehicleId,
    this.vehicleInfo,
  });
  
  factory Feedback.fromJson(Map<String, dynamic> json) {
    return Feedback(
      id: json['id'],
      clientId: json['client_id'],
      clientName: json['client_name'],
      subject: json['subject'],
      message: json['message'],
      createdAt: DateTime.parse(json['created_at']),
      isRead: json['is_read'] ?? false,
      isArchived: json['is_archived'] ?? false,
      response: json['response'],
      respondedAt: json['responded_at'] != null ? DateTime.parse(json['responded_at']) : null,
      status: json['status'] ?? 'pending',
      vehicleId: json['vehicle_id'],
      vehicleInfo: json['vehicle_info'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'client_name': clientName,
      'subject': subject,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'is_archived': isArchived,
      'response': response,
      'responded_at': respondedAt?.toIso8601String(),
      'status': status,
      'vehicle_id': vehicleId,
      'vehicle_info': vehicleInfo,
    };
  }
  
  // Mu00e9thode d'aide pour obtenir la date formatu00e9e
  String get formattedDate {
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(createdAt);
  }
  
  // Mu00e9thode d'aide pour obtenir la date de ru00e9ponse formatu00e9e
  String? get formattedResponseDate {
    if (respondedAt == null) return null;
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(respondedAt!);
  }
  
  // Mu00e9thode pour marquer comme lu
  Feedback markAsRead() {
    return Feedback(
      id: id,
      clientId: clientId,
      clientName: clientName,
      subject: subject,
      message: message,
      createdAt: createdAt,
      isRead: true,
      isArchived: isArchived,
      response: response,
      respondedAt: respondedAt,
      status: status,
      vehicleId: vehicleId,
      vehicleInfo: vehicleInfo,
    );
  }
  
  // Mu00e9thode pour ajouter une ru00e9ponse
  Feedback respond(String responseText) {
    return Feedback(
      id: id,
      clientId: clientId,
      clientName: clientName,
      subject: subject,
      message: message,
      createdAt: createdAt,
      isRead: true,
      isArchived: isArchived,
      response: responseText,
      respondedAt: DateTime.now(),
      status: 'responded',
      vehicleId: vehicleId,
      vehicleInfo: vehicleInfo,
    );
  }
  
  // Mu00e9thode pour archiver
  Feedback archive() {
    return Feedback(
      id: id,
      clientId: clientId,
      clientName: clientName,
      subject: subject,
      message: message,
      createdAt: createdAt,
      isRead: isRead,
      isArchived: true,
      response: response,
      respondedAt: respondedAt,
      status: 'archived',
      vehicleId: vehicleId,
      vehicleInfo: vehicleInfo,
    );
  }
}
