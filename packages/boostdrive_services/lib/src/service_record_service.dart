import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:boostdrive_core/boostdrive_core.dart';

class ServiceRecordService {
  final _supabase = Supabase.instance.client;

  Stream<List<ServiceRecord>> getVehicleServiceHistory(String vehicleId) {
    return _supabase
        .from('service_history')
        .stream(primaryKey: ['id'])
        .eq('vehicle_id', vehicleId)
        .order('completed_at', ascending: false)
        .map((data) => data.map((json) => ServiceRecord.fromMap(json)).toList());
  }

  Stream<List<ServiceRecord>> getProviderHistory(String providerId) {
    return _supabase
        .from('service_history')
        .stream(primaryKey: ['id'])
        .eq('provider_id', providerId)
        .order('completed_at', ascending: false)
        .map((data) => data.map((json) => ServiceRecord.fromMap(json)).toList());
  }

  Future<void> addServiceRecord(ServiceRecord record) async {
    await _supabase.from('service_history').insert(record.toMap());
  }
}

final serviceRecordServiceProvider = Provider<ServiceRecordService>((ref) {
  return ServiceRecordService();
});

final vehicleHistoryProvider = StreamProvider.family<List<ServiceRecord>, String>((ref, vehicleId) {
  return ref.watch(serviceRecordServiceProvider).getVehicleServiceHistory(vehicleId);
});
