class Vehicle {
  final String id;
  final String ownerId;
  final String make;
  final String model;
  final int year;
  final String plateNumber;
  final String healthStatus;
  final String fuelLevel;
  final String type; // 'personal', 'logistics'
  final DateTime createdAt;

  const Vehicle({
    required this.id,
    required this.ownerId,
    required this.make,
    required this.model,
    required this.year,
    required this.plateNumber,
    this.healthStatus = 'Healthy',
    this.fuelLevel = '100%',
    this.type = 'personal',
    required this.createdAt,
  });

  factory Vehicle.fromMap(Map<String, dynamic> data) {
    return Vehicle(
      id: data['id']?.toString() ?? '',
      ownerId: data['owner_id']?.toString() ?? '',
      make: data['make'] ?? '',
      model: data['model'] ?? '',
      year: data['year'] ?? DateTime.now().year,
      plateNumber: data['plate_number'] ?? '',
      healthStatus: data['health_status'] ?? 'Healthy',
      fuelLevel: data['fuel_level'] ?? '100%',
      type: data['type'] ?? 'personal',
      createdAt: DateTime.tryParse(data['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'owner_id': ownerId,
      'make': make,
      'model': model,
      'year': year,
      'plate_number': plateNumber,
      'health_status': healthStatus,
      'fuel_level': fuelLevel,
      'type': type,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
