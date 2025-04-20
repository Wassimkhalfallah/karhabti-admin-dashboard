// Modèle pour les clients
class Client {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final String? address;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final List<String>? vehicleIds;
  final bool isActive;
  final String? profileImageUrl;
  
  Client({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    this.address,
    required this.createdAt,
    this.lastLogin,
    this.vehicleIds,
    required this.isActive,
    this.profileImageUrl,
  });
  
  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      address: json['address'],
      createdAt: DateTime.parse(json['created_at']),
      lastLogin: json['last_login'] != null ? DateTime.parse(json['last_login']) : null,
      vehicleIds: json['vehicle_ids'] != null ? List<String>.from(json['vehicle_ids']) : null,
      isActive: json['is_active'] ?? true,
      profileImageUrl: json['profile_image_url'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone_number': phoneNumber,
      'address': address,
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
      'vehicle_ids': vehicleIds,
      'is_active': isActive,
      'profile_image_url': profileImageUrl,
    };
  }
  
  String get fullName => '$firstName $lastName';
  
  Client copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? address,
    DateTime? createdAt,
    DateTime? lastLogin,
    List<String>? vehicleIds,
    bool? isActive,
    String? profileImageUrl,
  }) {
    return Client(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      vehicleIds: vehicleIds ?? this.vehicleIds,
      isActive: isActive ?? this.isActive,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
