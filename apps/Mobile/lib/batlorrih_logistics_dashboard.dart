import 'package:boostdrive_core/boostdrive_core.dart';
import 'package:boostdrive_auth/boostdrive_auth.dart';
import 'package:boostdrive_services/boostdrive_services.dart';
import 'providers.dart';

class BaTLorriHLogisticsDashboard extends ConsumerStatefulWidget {
  const BaTLorriHLogisticsDashboard({super.key});

  @override
  ConsumerState<BaTLorriHLogisticsDashboard> createState() => _BaTLorriHLogisticsDashboardState();
}

class _BaTLorriHLogisticsDashboardState extends ConsumerState<BaTLorriHLogisticsDashboard> with SingleTickerProviderStateMixin {
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
      showBackground: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildHeader(ref, user.id),
              const SizedBox(height: 32),
              _buildMetricsRow(ref, user.id),
              const SizedBox(height: 32),
              _buildLiveDispatchMap(),
              const SizedBox(height: 32),
              _buildTabs(),
              const SizedBox(height: 24),
              _buildOrderList(ref, user.id),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(WidgetRef ref, String uid) {
    return ref.watch(userProfileProvider(uid)).when(
      data: (profile) {
        if (profile == null) return const SizedBox();
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: BoostDriveTheme.primaryBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.local_shipping, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName,
                  style: GoogleFonts.manrope(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Logistics Manager',
                  style: TextStyle(color: BoostDriveTheme.textDim, fontSize: 13),
                ),
              ],
            ),
            const Spacer(),
            _buildHeaderIcon(Icons.notifications_outlined, hasNotification: true),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 20,
              backgroundColor: BoostDriveTheme.surfaceDark,
              backgroundImage: profile.profileImg.isNotEmpty ? NetworkImage(profile.profileImg) : null,
              child: profile.profileImg.isEmpty ? const Icon(Icons.person, color: Colors.white38) : null,
            ),
          ],
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const Text('Error loading header'),
    );
  }

  Widget _buildHeaderIcon(IconData icon, {bool hasNotification = false}) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        if (hasNotification)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              height: 10,
              width: 10,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: BoostDriveTheme.backgroundDark, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMetricsRow(WidgetRef ref, String uid) {
    return ref.watch(userProfileProvider(uid)).when(
      data: (profile) {
        if (profile == null) return const SizedBox();
        return Row(
          children: [
            Expanded(child: _buildMetricCard('FLEET REVENUE', '\$${profile.totalEarnings.toStringAsFixed(0)}', '+12.4%', true)),
            const SizedBox(width: 16),
            Expanded(child: _buildMetricCard('COMPLETED', profile.loyaltyPoints.toString(), '98% Success', false, isSuccess: true)),
          ],
        );
      },
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
    );
  }

  Widget _buildMetricCard(String label, String value, String subtext, bool isTrend, {bool isSuccess = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BoostDriveTheme.surfaceDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: BoostDriveTheme.textDim,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (isTrend) const Icon(Icons.trending_up, color: Colors.green, size: 14),
              if (isSuccess) const Icon(Icons.check_circle, color: Colors.green, size: 14),
              const SizedBox(width: 6),
              Text(
                subtext,
                style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiveDispatchMap() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.map_outlined, color: BoostDriveTheme.primaryBlue, size: 18),
                const SizedBox(width: 8),
                const Text('Live Dispatch Map', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            TextButton(
              onPressed: () {},
              child: Row(
                children: const [
                  Text('FULLSCREEN', style: TextStyle(color: BoostDriveTheme.primaryBlue, fontSize: 10, fontWeight: FontWeight.bold)),
                  SizedBox(width: 4),
                  Icon(Icons.open_in_full, color: BoostDriveTheme.primaryBlue, size: 12),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            image: const DecorationImage(
              image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBmoIr6BNhyne0XHfn3L2EvhS-V9bsoFgFlGNJMtKLZKjMGTfR_McAS2dcIAl3M3dtfm40uzT2zyyj-H4QD3G2WSNQgcWoFgEcGMzQ-01ad_Quuky5HzJP5bnqbeuhWHVOPwzvgZ8ctG8i779MeULOmRxgGxEbSXs2kzFQA_p2bOnC3fGSka5eI8hBpkZGE1ShSpNasZftXZa21yReRcqOEyKgeHPLx-_JNj-gN_NA8cbhIXTXnQiDox5RT2giEQjYNUg3347VVXO4'), // Placeholder map for Chicago as per mockup
              fit: BoxFit.cover,
            ),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: BoostDriveTheme.backgroundDark.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      const Text('18 DRIVERS LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              // Mock location markers
              const Center(child: Icon(Icons.local_shipping, color: BoostDriveTheme.primaryBlue, size: 30)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return TabBar(
      controller: _tabController,
      indicatorColor: BoostDriveTheme.primaryBlue,
      indicatorWeight: 3,
      indicatorSize: TabBarIndicatorSize.label,
      labelColor: BoostDriveTheme.primaryBlue,
      unselectedLabelColor: BoostDriveTheme.textDim,
      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
      tabs: const [
        Tab(text: 'Active Queue'),
        Tab(text: 'Pickups'),
        Tab(text: 'Completed'),
      ],
    );
  }

  Widget _buildOrderList(WidgetRef ref, String uid) {
    return ref.watch(activeDeliveriesProvider(uid)).when(
      data: (orders) {
        if (orders.isEmpty) return Text('No active orders in queue.', style: TextStyle(color: BoostDriveTheme.textDim));
        return Column(
          children: orders.map((o) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildOrderCard(
              status: o.status.toUpperCase().replaceAll('_', ' '),
              statusColor: o.status == 'delivered' ? Colors.green : (o.status == 'in_transit' ? Colors.orange : BoostDriveTheme.primaryBlue),
              orderId: '#${o.id.substring(0, 8).toUpperCase()}',
              eta: o.eta.isNotEmpty ? o.eta : 'N/A',
              pickup: o.pickupLocation['address'] ?? 'Unknown Pickup',
              dropoff: o.dropoffLocation['address'] ?? 'Unknown Drop-off',
              driver: 'Assigned Driver', // Placeholder until driver profile fetching is implemented
              actionText: o.status == 'pending' ? 'Assign' : 'Manage',
              isAwaiting: o.status == 'pending',
            ),
          )).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('Error loading orders'),
    );
  }

  Widget _buildOrderCard({
    required String status,
    required Color statusColor,
    required String orderId,
    required String eta,
    String etaLabel = 'ETA',
    required String pickup,
    required String dropoff,
    required String driver,
    required String actionText,
    bool isAwaiting = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BoostDriveTheme.surfaceDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(status, style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(etaLabel, style: TextStyle(color: BoostDriveTheme.textDim, fontSize: 10, fontWeight: FontWeight.bold)),
                  Text(eta, style: const TextStyle(color: BoostDriveTheme.primaryBlue, fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Order $orderId', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildLocationItem(Icons.radio_button_checked, Colors.blue, 'PICKUP', pickup),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Container(width: 1, height: 20, color: Colors.white10),
          ),
          _buildLocationItem(Icons.location_on, Colors.white24, 'DROP-OFF', dropoff),
          const SizedBox(height: 24),
          Row(
            children: [
              if (!isAwaiting)
                Container(
                  height: 40,
                  width: 40,
                  decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_downward, color: Colors.white, size: 20),
                ),
              if (!isAwaiting) const SizedBox(width: 12),
              if (!isAwaiting)
                Text(driver, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              if (isAwaiting)
                const Text('Finding nearest optimized route...', style: TextStyle(color: Colors.white24, fontSize: 12, fontStyle: FontStyle.italic)),
              const Spacer(),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: !isAwaiting ? Colors.white.withOpacity(0.05) : BoostDriveTheme.primaryBlue,
                  foregroundColor: !isAwaiting ? BoostDriveTheme.primaryBlue : Colors.white,
                  minimumSize: const Size(100, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(actionText, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationItem(IconData icon, Color iconColor, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 16),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: BoostDriveTheme.textDim, fontSize: 9, fontWeight: FontWeight.bold)),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}
