import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'product_service.dart';
import 'sos_service.dart';

final sosServiceProvider = Provider<SosService>((ref) {
  return SosService();
});



final featuredProductsProvider = FutureProvider((ref) async {
  final productService = ref.watch(productServiceProvider);
  return productService.getFeaturedProducts();
});
