import 'package:boostdrive_core/boostdrive_core.dart';
import 'package:boostdrive_auth/boostdrive_auth.dart';
import 'package:boostdrive_services/boostdrive_services.dart';
import 'providers.dart';

class ServiceProDashboard extends ConsumerStatefulWidget {
  const ServiceProDashboard({super.key});

  @override
  ConsumerState<ServiceProDashboard> createState() => _ServiceProDashboardState();
}

class _ServiceProDashboardState extends ConsumerState<ServiceProDashboard> {

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
              const SizedBox(height: 24),
              _buildStatusToggle(ref, user.id),
              const SizedBox(height: 24),
              _buildMapView(),
              const SizedBox(height: 24),
              _buildStatsRow(ref, user.id),
              const SizedBox(height: 32),
              _buildLiveRequests(ref),
              const SizedBox(height: 32),
              _buildInProgressJobs(),
              const SizedBox(height: 32),
              _buildPartsLinkTool(),
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
              child: const Icon(Icons.build, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName,
                  style: GoogleFonts.manrope(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'PRO ID: @${profile.uid.substring(0, 8).toUpperCase()}',
                  style: TextStyle(color: BoostDriveTheme.textDim, fontSize: 12),
                ),
              ],
            ),
            const Spacer(),
            _buildHeaderIcon(Icons.notifications_none_rounded, hasNotification: true),
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

  Widget _buildStatusToggle(WidgetRef ref, String uid) {
    return ref.watch(userProfileProvider(uid)).when(
      data: (profile) {
        if (profile == null) return const SizedBox();
        final isOnline = profile.isOnline;
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: BoostDriveTheme.surfaceDark.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    ref.read(userServiceProvider).updateProfile(profile.copyWith(isOnline: true));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isOnline ? BoostDriveTheme.surfaceDark : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: isOnline ? Border.all(color: Colors.white.withOpacity(0.1)) : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        const Text('Go Online', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    ref.read(userServiceProvider).updateProfile(profile.copyWith(isOnline: false));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !isOnline ? BoostDriveTheme.surfaceDark : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: !isOnline ? Border.all(color: Colors.white.withOpacity(0.1)) : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        const Text('Go Offline', style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
    );
  }

  Widget _buildMapView() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: BoostDriveTheme.surfaceDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Stack(
        children: [
          // Mock Map
          Center(child: Icon(Icons.map_outlined, size: 60, color: Colors.white10)),
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: BoostDriveTheme.backgroundDark.withOpacity(0.8),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.redAccent, size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    '7 ACTIVE ALERTS NEARBY',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: Container(
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                color: BoostDriveTheme.primaryBlue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(color: BoostDriveTheme.primaryBlue.withOpacity(0.5), blurRadius: 10, spreadRadius: 5),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(WidgetRef ref, String uid) {
    return ref.watch(userProfileProvider(uid)).when(
      data: (profile) {
        if (profile == null) return const SizedBox();
        return Row(
          children: [
            Expanded(child: _buildStatCard('Total Earnings', '\$${profile.totalEarnings.toStringAsFixed(2)}', 'LIFETIME', true)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Loyalty Points', profile.loyaltyPoints.toString(), 'REDEEMABLE', false)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Status', profile.verificationStatus.toUpperCase(), 'VERIFIED', false)),
          ],
        );
      },
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
    );
  }

  Widget _buildStatCard(String label, String value, String subtext, bool isPositive) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BoostDriveTheme.surfaceDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: BoostDriveTheme.textDim, fontSize: 11)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          Row(
            children: [
              if (isPositive) const Icon(Icons.trending_up, color: Colors.green, size: 12),
              if (isPositive) const SizedBox(width: 4),
              Text(
                subtext,
                style: TextStyle(
                  color: isPositive ? Colors.green : (subtext.startsWith('TOP') ? Colors.amber : BoostDriveTheme.textDim),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiveRequests(WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'Live Requests',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('New', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.w900)),
                ),
              ],
            ),
            TextButton(
              onPressed: () {},
              child: const Text('View All', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: ref.watch(sosServiceProvider).getGlobalActiveRequests(),
          builder: (context, snapshot) {
            final requests = snapshot.data ?? [];
            if (requests.isEmpty) return Text('No active SOS requests.', style: TextStyle(color: BoostDriveTheme.textDim));
            return Column(
              children: requests.map((req) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildRequestCard(
                  tag: 'SOS - ${req['type']?.toString().toUpperCase() ?? 'EMERGENCY'}',
                  distance: 'Active Request',
                  title: req['user_note'] ?? 'No notes provided',
                  user: 'User ID: ${req['user_id']?.toString().substring(0, 8)}',
                  tagColor: req['type'] == 'emergency' ? Colors.redAccent : Colors.blueAccent,
                  requestId: req['id'],
                ),
              )).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRequestCard({
    required String tag,
    required String distance,
    required String title,
    required String user,
    required Color tagColor,
    required String requestId,
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: tagColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(tag, style: TextStyle(color: tagColor, fontSize: 10, fontWeight: FontWeight.w900)),
              ),
              Text(distance, style: TextStyle(color: BoostDriveTheme.textDim, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.directions_car_filled_outlined, color: Colors.white10),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(user, style: TextStyle(color: BoostDriveTheme.textDim, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.info_outline, size: 18),
                  label: const Text('Details'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 52),
                    side: BorderSide(color: Colors.white.withOpacity(0.1)),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(sosServiceProvider).cancelRequest(requestId);
                  },
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Accept'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 52),
                    backgroundColor: BoostDriveTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInProgressJobs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'In Progress Jobs',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 16),
        Container(
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
                  Row(
                    children: [
                      const Icon(Icons.local_shipping, color: BoostDriveTheme.primaryBlue, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'EN ROUTE',
                        style: TextStyle(color: BoostDriveTheme.primaryBlue, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                  Text('ETA: 6 MIN', style: TextStyle(color: BoostDriveTheme.textDim, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Transmission Check',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Marcus Wright • Ford F-150',
                style: TextStyle(color: BoostDriveTheme.textDim, fontSize: 14),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildHeaderIcon(Icons.phone_outlined),
                  const SizedBox(width: 12),
                  _buildHeaderIcon(Icons.navigation_outlined),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPartsLinkTool() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [BoostDriveTheme.primaryBlue, Colors.blue.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: BoostDriveTheme.primaryBlue.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Parts Link™ Tool',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.shopping_cart, color: Colors.white, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Send required parts list to your customer via .shop marketplace.',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: BoostDriveTheme.primaryBlue,
              minimumSize: const Size(double.infinity, 56),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('Generate New Link'),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
