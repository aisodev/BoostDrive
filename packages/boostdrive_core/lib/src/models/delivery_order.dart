class DeliveryOrder {
  final String id;
  final String customerId;
  final String sellerId;
  final String? driverId;
  final String status; // 'pending', 'picking_up', 'in_transit', 'delivered'
  final Map<String, dynamic> pickupLocation;
  final Map<String, dynamic> dropoffLocation;
  final Map<String, dynamic> items;
  final String eta;
  final DateTime createdAt;

  const DeliveryOrder({
    required this.id,
    required this.customerId,
    required this.sellerId,
    this.driverId,
    this.status = 'pending',
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.items,
    this.eta = '',
    required this.createdAt,
  });

  factory DeliveryOrder.fromMap(Map<String, dynamic> data) {
    return DeliveryOrder(
      id: data['id']?.toString() ?? '',
      customerId: data['customer_id']?.toString() ?? '',
      sellerId: data['seller_id']?.toString() ?? '',
      driverId: data['driver_id']?.toString(),
      status: data['status'] ?? 'pending',
      pickupLocation: Map<String, dynamic>.from(data['pickup_location'] ?? {}),
      dropoffLocation: Map<String, dynamic>.from(data['dropoff_location'] ?? {}),
      items: Map<String, dynamic>.from(data['items'] ?? {}),
      eta: data['eta'] ?? '',
      createdAt: DateTime.tryParse(data['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customer_id': customerId,
      'seller_id': sellerId,
      'driver_id': driverId,
      'status': status,
      'pickup_location': pickupLocation,
      'dropoff_location': dropoffLocation,
      'items': items,
      'eta': eta,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
