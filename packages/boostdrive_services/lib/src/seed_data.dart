import 'package:supabase_flutter/supabase_flutter.dart';

/// Run this function once to populate your Supabase with test data.
/// You can call it from a temporary button in your app.
Future<void> seedBoostDriveData() async {
  final supabase = Supabase.instance.client;

  final products = [
    // Featured Cars
    {
      'id': '00000000-0000-0000-0000-000000000001',
      'category': 'car',
      'title': '2022 Toyota Hilux v6',
      'subtitle': 'Rugged 4x4 Legend',
      'description': 'Excellent condition, low mileage Toyota Hilux. Perfect for Namibian terrain.',
      'price': 650000.0,
      'condition': 'used',
      'location': 'Windhoek',
      'image_url': 'https://images.unsplash.com/photo-1590362891991-f776e747a588?auto=format&fit=crop&w=800&q=80',
      'is_featured': true,
      'status': 'available',
      'created_at': DateTime.now().toIso8601String(),
    },
    // ... other products would go here, updating keys to snake_case
  ];

  try {
    await supabase.from('products').insert(products);
    print('Supabase seeded successfully!');
  } catch (e) {
    print('Error seeding Supabase: $e');
  }
}
