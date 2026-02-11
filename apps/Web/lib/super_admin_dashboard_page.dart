import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:boostdrive_ui/boostdrive_ui.dart';
import 'package:boostdrive_auth/boostdrive_auth.dart';
import 'package:boostdrive_services/boostdrive_services.dart';
import 'package:boostdrive_core/boostdrive_core.dart';
import 'package:google_fonts/google_fonts.dart';

class SuperAdminDashboardPage extends ConsumerWidget {
  const SuperAdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const Scaffold(body: Center(child: Text('Please log in')));

    return PremiumPageLayout(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Super Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -1),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAdminHeader(ref, user.id),
            const SizedBox(height: 48),
            _buildKPIGrid(ref),
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
                          Expanded(flex: 3, child: _buildSystemHealthMap()),
                          const SizedBox(width: 40),
                          Expanded(flex: 2, child: _buildManagementPanel(ref)),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _buildSystemHealthMap(),
                          const SizedBox(height: 40),
                          _buildManagementPanel(ref),
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

  Widget _buildAdminHeader(WidgetRef ref, String uid) {
    return ref.watch(userProfileProvider(uid)).when(
      data: (profile) {
        if (profile == null) return const SizedBox();
        return Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Systems Oversight: ${profile.fullName}',
                  style: GoogleFonts.manrope(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'BOOSTDRIVE GLOBAL COMMAND • PLATFORM HEALTH: OPERATIONAL',
                  style: TextStyle(color: BoostDriveTheme.textDim, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ],
            ),
            const Spacer(),
            _buildSystemStatusBadge(),
          ],
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const Text('Error loading profile'),
    );
  }

  Widget _buildSystemStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          const Text('SYSTEMS NORMAL', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w900, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildKPIGrid(WidgetRef ref) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 24,
      crossAxisSpacing: 24,
      childAspectRatio: 2,
      children: [
        _buildKPICard('MONTHLY REVENUE', 'LIVE', 'N/A', Colors.green),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: ref.watch(sosServiceProvider).getGlobalActiveRequests(),
          builder: (context, snapshot) => _buildKPICard('ACTIVE SOS ALERTS', (snapshot.data?.length ?? 0).toString(), '+3%', Colors.redAccent),
        ),
        StreamBuilder<double>(
          stream: ref.watch(deliveryServiceProvider).getGlobalVolume(),
          builder: (context, snapshot) => _buildKPICard('MARKETPLACE VOL', '\$${(snapshot.data ?? 0).toStringAsFixed(0)}', 'TOTAL', BoostDriveTheme.primaryBlue),
        ),
        StreamBuilder<int>(
          stream: ref.watch(userServiceProvider).getUserCount(),
          builder: (context, snapshot) => _buildKPICard('USER BASE', (snapshot.data ?? 0).toString(), '+5%', Colors.purpleAccent),
        ),
      ],
    );
  }

  Widget _buildKPICard(String label, String value, String trend, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(color: BoostDriveTheme.textDim, fontSize: 10, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              Text(trend, style: TextStyle(color: trend.startsWith('+') ? Colors.green : Colors.red, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSystemHealthMap() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Active Service Clusters: Namibia Central',
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
            child: Icon(Icons.public, color: BoostDriveTheme.primaryBlue, size: 80),
          ),
        ),
      ],
    );
  }

  Widget _buildManagementPanel(WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pending Verifications',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 24),
        StreamBuilder<List<UserProfile>>(
          stream: ref.watch(userServiceProvider).getPendingVerifications(),
          builder: (context, snapshot) {
            final pending = snapshot.data ?? [];
            if (pending.isEmpty) return Text('No pending verifications.', style: TextStyle(color: BoostDriveTheme.textDim));
            return Column(
              children: pending.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildVerificationCard(p.fullName, '${p.role.toUpperCase()} • ${p.email}'),
              )).toList(),
            );
          },
        ),
        const SizedBox(height: 48),
        const Text(
          'System Alerts',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 24),
        _buildAlertItem('Database performance degradation in Cluster B', 'URGENT', Colors.orange),
        const SizedBox(height: 12),
        _buildAlertItem('Unusual sign-up spike detected in Northern Region', 'INFO', BoostDriveTheme.primaryBlue),
      ],
    );
  }

  Widget _buildVerificationCard(String name, String sub) {
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
          Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          Text(sub, style: TextStyle(color: BoostDriveTheme.textDim, fontSize: 14)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(onPressed: () {}, child: const Text('Approve')),
              ),
              const SizedBox(width: 12),
              OutlinedButton(onPressed: () {}, child: const Text('Review Docs')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(String msg, String tag, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
            child: Text(tag, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(msg, style: const TextStyle(color: Colors.white, fontSize: 14))),
        ],
      ),
    );
  }
}
