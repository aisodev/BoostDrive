import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:boostdrive_core/boostdrive_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


// Simple Cart Item model
class CartItem {
  final Product product;
  final int quantity;
  final DateTime? rentalStartDate;
  final DateTime? rentalEndDate;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.rentalStartDate,
    this.rentalEndDate,
  });

  double get totalPrice {
    if (product.category == 'rental' && rentalStartDate != null && rentalEndDate != null) {
      final days = rentalEndDate!.difference(rentalStartDate!).inDays;
      return product.price * (days == 0 ? 1 : days); // Minimum 1 day
    }
    return product.price * quantity;
  }
}

// Cart State Notifier
class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(Product product, {DateTime? startDate, DateTime? endDate}) {
    // Check if exists (simple check by ID)
    final existingIndex = state.indexWhere((item) => item.product.id == product.id);
    
    if (existingIndex >= 0 && product.category != 'rental') {
      // Increment quantity for non-rentals
      final existingItem = state[existingIndex];
      final newQuantity = existingItem.quantity + 1;
      
      final updatedItem = CartItem(
        product: product,
        quantity: newQuantity,
      );
      
      final newState = [...state];
      newState[existingIndex] = updatedItem;
      state = newState;
    } else {
      // Add new
      state = [
        ...state,
        CartItem(
          product: product, 
          rentalStartDate: startDate,
          rentalEndDate: endDate
        )
      ];
    }
  }

  void removeItem(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  void clearCart() {
    state = [];
  }

  double get grandTotal => state.fold(0, (sum, item) => sum + item.totalPrice);
}

// Providers
final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

// Checkout Service
final checkoutServiceProvider = Provider((ref) => CheckoutService());

class CheckoutService {
  final _supabase = Supabase.instance.client;

  Future<String> placeOrder(String userId, List<CartItem> items, double total) async {
    // 1. Create Order
    final response = await _supabase.from('orders').insert({
      'user_id': userId,
      'status': 'pending', // pending, paid, shipped, completed
      'created_at': DateTime.now().toIso8601String(),
      'total': total,
      'items': items.map((item) => {
        'productId': item.product.id,
        'title': item.product.title,
        'price': item.product.price,
        'quantity': item.quantity,
        'category': item.product.category,
        'rentalStart': item.rentalStartDate?.toIso8601String(),
        'rentalEnd': item.rentalEndDate?.toIso8601String(),
      }).toList(),
    }).select('id').single();

    return response['id'].toString();
  }
}
