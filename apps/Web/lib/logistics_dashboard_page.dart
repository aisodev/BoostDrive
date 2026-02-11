import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:boostdrive_ui/boostdrive_ui.dart';
import 'package:boostdrive_auth/boostdrive_auth.dart';
import 'package:boostdrive_services/boostdrive_services.dart';
import 'package:boostdrive_core/boostdrive_core.dart';
import 'package:google_fonts/google_fonts.dart';

class LogisticsDashboardPage extends ConsumerStatefulWidget {
  const LogisticsDashboardPage({super.key});

  @override
  ConsumerState<LogisticsDashboardPage> createState() => _LogisticsDashboardPageState();
}

class _LogisticsDashboardPageState extends ConsumerState<LogisticsDashboardPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const Scaffold(body: Center(child: Text('Please log in')));

    return PremiumPageLayout(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'BaTLorriH Logistics Dashboard',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -1),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLogisticsHeader(ref, user.id),
            const SizedBox(height: 48),
            _buildMetricsRow(ref, user.id),
            const SizedBox(height: 48),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 1100;
                return Column(
                  children: [
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: _buildDispatchMap()),
                          const SizedBox(width: 40),
                          Expanded(flex: 3, child: _buildOrderQueue(ref, user.id)),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _buildDispatchMap(),
                          const SizedBox(height: 40),
                          _buildOrderQueue(ref, user.id),
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

  Widget _buildLogisticsHeader(WidgetRef ref, String uid) {
    return ref.watch(userProfileProvider(uid)).when(
      data: (profile) {
        if (profile == null) return const SizedBox();
        return Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fleet Lead: ${profile.fullName}',
                  style: GoogleFonts.manrope(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Head of Operations • BaTLorriH Namibia Logistics',
                  style: TextStyle(color: BoostDriveTheme.textDim, fontSize: 18),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.local_shipping),
              label: const Text('Add Vehicle to Fleet'),
              style: ElevatedButton.styleFrom(
                backgroundColor: BoostDriveTheme.primaryBlue,
                minimumSize: const Size(200, 64),
              ),
            ),
          ],
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const Text('Error loading profile'),
    );
  }

  Widget _buildMetricsRow(WidgetRef ref, String uid) {
    return ref.watch(userProfileProvider(uid)).when(
      data: (profile) {
        if (profile == null) return const SizedBox();
        return Row(
          children: [
            Expanded(child: _buildMetricCard('FLEET REVENUE', '\$${profile.totalEarnings.toStringAsFixed(2)}', 'LIFETIME', false)),
            const SizedBox(width: 24),
            Expanded(child: _buildMetricCard('LOYALTY POINTS', profile.loyaltyPoints.toString(), 'REDEEMABLE', false)),
            const SizedBox(width: 24),
            Expanded(child: _buildMetricCard('ON-TIME RATE', '97.4%', 'EXCELLENT', false)),
            const SizedBox(width: 24),
            Expanded(child: _buildMetricCard('ACTIVE DRIVERS', 'LIVE', 'CONNECTED', false)),
          ],
        );
      },
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
    );
  }

  Widget _buildMetricCard(String label, String value, String sub, bool isTrend) {
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
          Text(label, style: TextStyle(color: BoostDriveTheme.textDim, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          Text(sub, style: TextStyle(color: isTrend ? Colors.green : BoostDriveTheme.primaryBlue, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDispatchMap() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Live Fleet Dispatch',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 24),
        Container(
          height: 500,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: const Center(
            child: Icon(Icons.location_on, color: BoostDriveTheme.primaryBlue, size: 48),
          ),
        ),
        const SizedBox(height: 48),
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: BoostDriveTheme.primaryBlue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: BoostDriveTheme.primaryBlue.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('FLEET EFFICIENCY', style: TextStyle(color: BoostDriveTheme.primaryBlue, fontWeight: FontWeight.w900, fontSize: 12)),
              const SizedBox(height: 12),
              const Text('82 trucks are currently active with a 94% fulfillment rate today.', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderQueue(WidgetRef ref, String uid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Active Order Queue',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 24),
        ref.watch(activeDeliveriesProvider(uid)).when(
          data: (orders) {
            if (orders.isEmpty) {
              return Text('No active orders in the queue.', style: TextStyle(color: BoostDriveTheme.textDim));
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final o = orders[index];
                return _buildOrderCard(
                  o.status.replaceAll('_', ' ').toUpperCase(),
                  '#${o.id.substring(0, 8).toUpperCase()}',
                  o.eta.isNotEmpty ? o.eta : 'N/A',
                  o.pickupLocation['address']?.toString() ?? 'Source',
                  o.dropoffLocation['address']?.toString() ?? 'Destination',
                  'Assigned Driver',
                  o.status == 'delivered' ? Colors.green : BoostDriveTheme.primaryBlue,
                  o.id,
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Text('Error loading queue'),
        ),
      ],
    );
  }

  Widget _buildOrderCard(String status, String id, String eta, String pickup, String dropoff, String driver, Color color, String orderId) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: color.withOpacity(0.03),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 10)),
              ),
              Text(eta, style: const TextStyle(color: BoostDriveTheme.primaryBlue, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          Text('Order $id', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildRouteItem(Icons.circle_outlined, 'PICKUP', pickup),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 11),
            child: Container(width: 2, height: 20, color: Colors.white.withOpacity(0.1)),
          ),
          const SizedBox(height: 8),
          _buildRouteItem(Icons.location_on, 'DROP-OFF', dropoff),
          const SizedBox(height: 32),
          Row(
            children: [
              const CircleAvatar(radius: 16, backgroundColor: Colors.white10, child: Icon(Icons.person, size: 20, color: Colors.white)),
              const SizedBox(width: 12),
              const Text('Active Driver', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                   // Status update logic
                   ref.read(deliveryServiceProvider).updateDeliveryStatus(orderId, 'delivered');
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.05), foregroundColor: Colors.white),
                child: const Text('Mark Delivered'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRouteItem(IconData icon, String label, String val) {
    return Row(
      children: [
        Icon(icon, size: 24, color: BoostDriveTheme.textDim),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: BoostDriveTheme.textDim, fontSize: 10, fontWeight: FontWeight.w900)),
            Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ],
    );
  }
}
