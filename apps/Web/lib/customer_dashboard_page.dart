import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:boostdrive_ui/boostdrive_ui.dart';
import 'package:boostdrive_auth/boostdrive_auth.dart';
import 'package:boostdrive_services/boostdrive_services.dart';
import 'package:boostdrive_core/boostdrive_core.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomerDashboardPage extends ConsumerWidget {
  const CustomerDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const Scaffold(body: Center(child: Text('Please log in')));

    return PremiumPageLayout(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Customer Dashboard',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -1),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(ref, user.id),
            const SizedBox(height: 48),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 900;
                return Column(
                  children: [
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: _buildMainContent(ref, user.id)),
                          const SizedBox(width: 40),
                          Expanded(flex: 1, child: _buildSideContent(ref, user.id)),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _buildMainContent(ref, user.id),
                          const SizedBox(height: 40),
                          _buildSideContent(ref, user.id),
                        ],
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(WidgetRef ref, String uid) {
    return ref.watch(userProfileProvider(uid)).when(
      data: (profile) {
        if (profile == null) return const SizedBox();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, ${profile.fullName}',
              style: GoogleFonts.manrope(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage your vehicles, track orders, and view your service history.',
              style: TextStyle(color: BoostDriveTheme.textDim, fontSize: 18),
            ),
          ],
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const Text('Error loading profile'),
    );
  }

  Widget _buildMainContent(WidgetRef ref, String uid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('My Garage', Icons.directions_car),
        const SizedBox(height: 24),
        ref.watch(userVehiclesProvider(uid)).when(
          data: (vehicles) {
            if (vehicles.isEmpty) {
              return Text('No vehicles found in your garage.', style: TextStyle(color: BoostDriveTheme.textDim));
            }
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: vehicles.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 24,
                crossAxisSpacing: 24,
                childAspectRatio: 1.5,
              ),
              itemBuilder: (context, index) {
                final v = vehicles[index];
                return _buildVehicleCard('${v.year} ${v.make} ${v.model}', v.plateNumber, v.healthStatus.toUpperCase(), v.fuelLevel);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Text('Error loading garage'),
        ),
        const SizedBox(height: 48),
        _buildSectionHeader('Active Orders', Icons.local_shipping),
        const SizedBox(height: 24),
        ref.watch(activeDeliveriesProvider(uid)).when(
          data: (orders) {
            if (orders.isEmpty) {
              return Text('No active orders.', style: TextStyle(color: BoostDriveTheme.textDim));
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final o = orders[index];
                final itemsMap = Map<String, dynamic>.from(o.items);
                return _buildOrderCard(
                  itemsMap['title']?.toString() ?? 'Generic Parts Delivery',
                  '#${o.id.substring(0, 8).toUpperCase()}',
                  o.status.replaceAll('_', ' ').toUpperCase(),
                  itemsMap['description']?.toString() ?? 'Automotive Parts',
                  o.eta.isNotEmpty ? o.eta : 'Calculating ETA...',
                  o.status == 'delivered' ? 1.0 : 0.5,
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Text('Error loading orders'),
        ),
      ],
    );
  }

  Widget _buildSideContent(WidgetRef ref, String uid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Service History', Icons.history),
        const SizedBox(height: 24),
        // For simplicity, we fetch the first vehicle's history if available
        // in a real app, we'd have a more complex hierarchy
        ref.watch(userVehiclesProvider(uid)).when(
          data: (vehicles) {
            if (vehicles.isEmpty) return Text('No service records.', style: TextStyle(color: BoostDriveTheme.textDim));
            return ref.watch(vehicleHistoryProvider(vehicles.first.id)).when(
              data: (history) {
                if (history.isEmpty) return Text('No service records.', style: TextStyle(color: BoostDriveTheme.textDim));
                return Column(
                  children: history.map((item) => _buildHistoryItem(
                    item.serviceName,
                    '${item.completedAt.day}/${item.completedAt.month}/${item.completedAt.year}',
                    '\$${item.price.toStringAsFixed(2)}',
                  )).toList(),
                );
              },
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            );
          },
          loading: () => const SizedBox(),
          error: (_, __) => const SizedBox(),
        ),
        const SizedBox(height: 40),
        _buildPromoBanner(),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: BoostDriveTheme.primaryBlue, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildVehicleCard(String name, String plate, String status, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(status, style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(plate, style: TextStyle(color: BoostDriveTheme.textDim, fontSize: 14)),
          const Spacer(),
          const Divider(color: Colors.white10),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: BoostDriveTheme.primaryBlue, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildOrderCard(String title, String id, String status, String description, String eta, double progress) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: BoostDriveTheme.primaryBlue.withOpacity(0.03),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: BoostDriveTheme.primaryBlue.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(status, style: const TextStyle(color: BoostDriveTheme.primaryBlue, fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 12)),
              Text(id, style: TextStyle(color: BoostDriveTheme.textDim, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          Text(description, style: TextStyle(color: BoostDriveTheme.textDim, fontSize: 16)),
          const SizedBox(height: 32),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.05),
            valueColor: const AlwaysStoppedAnimation(BoostDriveTheme.primaryBlue),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 12),
          Text(eta, style: const TextStyle(color: BoostDriveTheme.primaryBlue, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(String title, String date, String price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(date, style: TextStyle(color: BoostDriveTheme.textDim, fontSize: 12)),
              ],
            ),
          ),
          Text(price, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [BoostDriveTheme.primaryBlue.withOpacity(0.2), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: BoostDriveTheme.primaryBlue.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('UPGRADE YOUR RIDE', style: TextStyle(color: BoostDriveTheme.primaryBlue, fontWeight: FontWeight.w900, fontSize: 12)),
          const SizedBox(height: 12),
          const Text('Get 15% off performance air filters this week.', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: () {}, child: const Text('Shop Performance')),
        ],
      ),
    );
  }
}
