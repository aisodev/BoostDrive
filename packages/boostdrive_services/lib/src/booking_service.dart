import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookingService {
  final _supabase = Supabase.instance.client;

  Future<String?> createBooking({
    required String productId,
    required String customerId,
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    required double totalPrice,
  }) async {
    try {
      final response = await _supabase.from('bookings').insert({
        'product_id': productId,
        'customer_id': customerId,
        'type': type,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'total_price': totalPrice,
        'status': 'confirmed',
        'is_insurance_verified': type == 'rental' ? true : false,
        'created_at': DateTime.now().toIso8601String(),
      }).select('id').single();
      
      return response['id'].toString();
    } catch (e) {
      print('Error creating booking: $e');
      return null;
    }
  }

  Stream<List<Map<String, dynamic>>> getUserBookings(String customerId) {
    return _supabase
        .from('bookings')
        .stream(primaryKey: ['id'])
        .eq('customer_id', customerId)
        .order('start_date', ascending: false);
  }
}

final bookingServiceProvider = Provider<BookingService>((ref) {
  return BookingService();
});
