import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:boostdrive_core/boostdrive_core.dart';

class VehicleService {
  final _supabase = Supabase.instance.client;

  Stream<List<Vehicle>> getUserVehicles(String ownerId) {
    return _supabase
        .from('vehicles')
        .stream(primaryKey: ['id'])
        .eq('owner_id', ownerId)
        .map((data) => data.map((json) => Vehicle.fromMap(json)).toList());
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    await _supabase.from('vehicles').insert(vehicle.toMap());
  }

  Future<void> updateVehicleHealth(String vehicleId, String status, String fuel) async {
    await _supabase.from('vehicles').update({
      'health_status': status,
      'fuel_level': fuel,
    }).eq('id', vehicleId);
  }
}

final vehicleServiceProvider = Provider<VehicleService>((ref) {
  return VehicleService();
});

final userVehiclesProvider = StreamProvider.family<List<Vehicle>, String>((ref, userId) {
  return ref.watch(vehicleServiceProvider).getUserVehicles(userId);
});
