// Modu00e8le pour les vu00e9hicules
class Vehicle {
  final String id;
  final String brand;
  final String model;
  final int year;
  final String color;
  final String registrationNumber;
  final String fuelType; // essence, diesel, u00e9lectrique, hybride
  final double mileage;
  final String clientId;
  final String type; // particulier ou professionnel
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String>? maintenanceHistory;
  
  Vehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.color,
    required this.registrationNumber,
    required this.fuelType,
    required this.mileage,
    required this.clientId,
    required this.type,
    this.imageUrl,
    required this.createdAt,
    this.updatedAt,
    this.maintenanceHistory,
  });
  
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      brand: json['brand'],
      model: json['model'],
      year: json['year'],
      color: json['color'],
      registrationNumber: json['registration_number'],
      fuelType: json['fuel_type'],
      mileage: json['mileage'].toDouble(),
      clientId: json['client_id'],
      type: json['type'],
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      maintenanceHistory: json['maintenance_history'] != null 
          ? List<String>.from(json['maintenance_history']) 
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'year': year,
      'color': color,
      'registration_number': registrationNumber,
      'fuel_type': fuelType,
      'mileage': mileage,
      'client_id': clientId,
      'type': type,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'maintenance_history': maintenanceHistory,
    };
  }
  
  Vehicle copyWith({
    String? id,
    String? brand,
    String? model,
    int? year,
    String? color,
    String? registrationNumber,
    String? fuelType,
    double? mileage,
    String? clientId,
    String? type,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? maintenanceHistory,
  }) {
    return Vehicle(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      color: color ?? this.color,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      fuelType: fuelType ?? this.fuelType,
      mileage: mileage ?? this.mileage,
      clientId: clientId ?? this.clientId,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      maintenanceHistory: maintenanceHistory ?? this.maintenanceHistory,
    );
  }
}
