class ServiceRecord {
  final String id;
  final String vehicleId;
  final String providerId;
  final String serviceName;
  final double price;
  final DateTime completedAt;

  const ServiceRecord({
    required this.id,
    required this.vehicleId,
    required this.providerId,
    required this.serviceName,
    required this.price,
    required this.completedAt,
  });

  factory ServiceRecord.fromMap(Map<String, dynamic> data) {
    return ServiceRecord(
      id: data['id']?.toString() ?? '',
      vehicleId: data['vehicle_id']?.toString() ?? '',
      providerId: data['provider_id']?.toString() ?? '',
      serviceName: data['service_name'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      completedAt: DateTime.tryParse(data['completed_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vehicle_id': vehicleId,
      'provider_id': providerId,
      'service_name': serviceName,
      'price': price,
      'completed_at': completedAt.toIso8601String(),
    };
  }
}
