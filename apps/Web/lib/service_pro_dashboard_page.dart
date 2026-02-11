import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:boostdrive_ui/boostdrive_ui.dart';
import 'package:boostdrive_auth/boostdrive_auth.dart';
import 'package:boostdrive_services/boostdrive_services.dart';
import 'package:boostdrive_core/boostdrive_core.dart';
import 'package:google_fonts/google_fonts.dart';

class ServiceProDashboardPage extends ConsumerStatefulWidget {
  const ServiceProDashboardPage({super.key});

  @override
  ConsumerState<ServiceProDashboardPage> createState() => _ServiceProDashboardPageState();
}

class _ServiceProDashboardPageState extends ConsumerState<ServiceProDashboardPage> {

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const Scaffold(body: Center(child: Text('Please log in')));

    return PremiumPageLayout(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Service Pro Dashboard',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -1),
        ),
        actions: [
          ref.watch(currentUserProvider) != null 
            ? _buildStatusToggle(ref, ref.watch(currentUserProvider)!.id)
            : const SizedBox(),
          const SizedBox(width: 16),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProHeader(ref, user.id),
            const SizedBox(height: 48),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 1000;
                return Column(
                  children: [
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: _buildMainContent()),
                          const SizedBox(width: 40),
                          Expanded(flex: 1, child: _buildSideContent()),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _buildMainContent(),
                          const SizedBox(height: 40),
                          _buildSideContent(),
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

  Widget _buildStatusToggle(WidgetRef ref, String uid) {
    return ref.watch(userProfileProvider(uid)).when(
      data: (profile) {
        if (profile == null) return const SizedBox();
        final isOnline = profile.isOnline;
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _toggleItem(ref, profile, 'ONLINE', isOnline, Colors.green),
              _toggleItem(ref, profile, 'OFFLINE', !isOnline, Colors.white24),
            ],
          ),
        );
      },
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
    );
  }

  Widget _toggleItem(WidgetRef ref, UserProfile profile, String label, bool active, Color color) {
    return GestureDetector(
      onTap: () {
        ref.read(userServiceProvider).updateProfile(
          profile.copyWith(isOnline: label == 'ONLINE'),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? BoostDriveTheme.surfaceDark : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: active ? color : Colors.transparent, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : Colors.white24,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProHeader(WidgetRef ref, String uid) {
    return ref.watch(userProfileProvider(uid)).when(
      data: (profile) {
        if (profile == null) return const SizedBox();
        return Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BoostDrive Pro: ${profile.fullName}',
                  style: GoogleFonts.manrope(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Expert Mechanic • Primary Service Provider',
                  style: TextStyle(color: BoostDriveTheme.textDim, fontSize: 18),
                ),
              ],
            ),
            const Spacer(),
            _buildStatBox('TOTAL EARNINGS', '\$${profile.totalEarnings.toStringAsFixed(2)}', 'LIFETIME'),
            const SizedBox(width: 24),
            _buildStatBox('LOYALTY POINTS', profile.loyaltyPoints.toString(), 'REDEEMABLE'),
          ],
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const Text('Error loading profile'),
    );
  }

  Widget _buildStatBox(String label, String value, String sub) {
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
          Text(label, style: TextStyle(color: BoostDriveTheme.textDim, fontSize: 10, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          Text(sub, style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Live Requests', Icons.radar),
        const SizedBox(height: 24),
        StreamBuilder<List<Map<String, dynamic>>>(
                stream: ref.watch(sosServiceProvider).getGlobalActiveRequests(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final requests = snapshot.data ?? [];
                  if (requests.isEmpty) {
                    return Text('No active SOS requests at the moment.', style: TextStyle(color: BoostDriveTheme.textDim));
                  }
                  return Column(
                    children: requests.map((Map<String, dynamic> req) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildRequestCard(
                        'SOS - ${req['type']?.toString().toUpperCase() ?? 'EMERGENCY'}',
                        req['user_note']?.toString() ?? 'No notes provided',
                        'Customer ID: ${req['user_id']?.toString().substring(0, 8)}',
                        'Active Request',
                        req['type'] == 'emergency' ? Colors.redAccent : BoostDriveTheme.primaryBlue,
                        req['id']?.toString() ?? '',
                      ),
                    )).toList(),
                  );
                },
              ),
        const SizedBox(height: 48),
        _buildSectionHeader('Ongoing Jobs', Icons.assignment_ind),
        const SizedBox(height: 24),
        _buildOngoingJobCard(
          'Transmission Inspection',
          'Ford F-150 • #BTL-9021',
          'In Progress - Diagnostic Phase',
          0.4,
        ),
      ],
    );
  }

  Widget _buildSideContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Service Map', Icons.map),
        const SizedBox(height: 24),
        Container(
          height: 300,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: const Center(child: Icon(Icons.location_on, color: BoostDriveTheme.primaryBlue, size: 48)),
        ),
        const SizedBox(height: 40),
        _buildSectionHeader('Parts Link™', Icons.shopping_cart),
        const SizedBox(height: 24),
        _buildPartsLinkPromo(),
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

  Widget _buildRequestCard(String tag, String title, String user, String dist, Color color, String requestId) {
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
                child: Text(tag, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 10)),
              ),
              Text(dist, style: TextStyle(color: BoostDriveTheme.textDim, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 24),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          Text(user, style: TextStyle(color: BoostDriveTheme.textDim, fontSize: 16)),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // In a real app, this would assign the mechanic to the request
                    ref.read(sosServiceProvider).cancelRequest(requestId); // Dummy "acceptance" (just hides it for now)
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BoostDriveTheme.primaryBlue,
                    minimumSize: const Size(0, 64),
                  ),
                  child: const Text('Accept Request'),
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(minimumSize: const Size(120, 64)),
                child: const Text('Decline'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOngoingJobCard(String title, String car, String status, double progress) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          Text(car, style: TextStyle(color: BoostDriveTheme.textDim, fontSize: 16)),
          const SizedBox(height: 24),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.05),
            valueColor: const AlwaysStoppedAnimation(BoostDriveTheme.primaryBlue),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 16),
          Text(status, style: const TextStyle(color: BoostDriveTheme.primaryBlue, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPartsLinkPromo() {
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
          const Text('NEED PARTS?', style: TextStyle(color: BoostDriveTheme.primaryBlue, fontWeight: FontWeight.w900, fontSize: 12)),
          const SizedBox(height: 12),
          const Text('Instantly link parts from our marketplace directly to your service ticket.', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: () {}, child: const Text('Generate Parts Link')),
        ],
      ),
    );
  }
}
