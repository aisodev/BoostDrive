import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:boostdrive_ui/boostdrive_ui.dart';
import 'package:boostdrive_auth/boostdrive_auth.dart';
import 'package:boostdrive_services/boostdrive_services.dart';
import 'package:boostdrive_core/boostdrive_core.dart';
import 'package:google_fonts/google_fonts.dart';

class SellerDashboardPage extends ConsumerStatefulWidget {
  const SellerDashboardPage({super.key});

  @override
  ConsumerState<SellerDashboardPage> createState() => _SellerDashboardPageState();
}

class _SellerDashboardPageState extends ConsumerState<SellerDashboardPage> with SingleTickerProviderStateMixin {
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
          'Seller Dashboard',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -1),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSellerHeader(ref, user.id),
            const SizedBox(height: 48),
            _buildPerformanceGrid(ref, user.id),
            const SizedBox(height: 48),
            _buildInventoryHeader(),
            const SizedBox(height: 24),
            _buildInventoryTable(ref, user.id),
          ],
        ),
      ),
    );
  }

  Widget _buildSellerHeader(WidgetRef ref, String uid) {
    return ref.watch(userProfileProvider(uid)).when(
      data: (profile) {
        if (profile == null) return const SizedBox();
        return Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Store Manager: ${profile.fullName}',
                  style: GoogleFonts.manrope(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Metro Salvage & Parts • Top Rated Performance',
                  style: TextStyle(color: BoostDriveTheme.textDim, fontSize: 18),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Add New Listing'),
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

  Widget _buildPerformanceGrid(WidgetRef ref, String uid) {
    return ref.watch(userProfileProvider(uid)).when(
      data: (profile) {
        if (profile == null) return const SizedBox();
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          mainAxisSpacing: 24,
          crossAxisSpacing: 24,
          childAspectRatio: 1.8,
          children: [
            _buildPerformanceCard('TOTAL SALES', '\$${profile.totalEarnings.toStringAsFixed(2)}', 'LIFETIME', true),
            _buildPerformanceCard('LOYALTY POINTS', profile.loyaltyPoints.toString(), 'REDEEMABLE', true),
            _buildPerformanceCard('VERIFICATION', profile.verificationStatus.toUpperCase(), 'STATUS', true),
            _buildPerformanceCard('STORE VIEWS', 'LIVE', 'N/A', true),
          ],
        );
      },
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
    );
  }

  Widget _buildPerformanceCard(String label, String value, String trend, bool positive) {
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
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          Text(trend, style: TextStyle(color: positive ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInventoryHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.inventory, color: BoostDriveTheme.primaryBlue, size: 24),
            const SizedBox(width: 12),
            const Text('Inventory Management', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        SizedBox(
          width: 300,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search inventory...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryTable(WidgetRef ref, String uid) {
    return ref.watch(sellerProductsProvider(uid)).when(
      data: (products) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              _buildTableHeader(),
              if (products.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(48.0),
                  child: Center(child: Text('No products listed yet.', style: TextStyle(color: BoostDriveTheme.textDim))),
                )
              else
                ...products.map((p) => _buildInventoryRow(
                  p.title,
                  p.id.substring(0, 8).toUpperCase(),
                  '\$${p.price.toStringAsFixed(2)}',
                  p.isFeatured ? 'Featured' : 'Standard',
                  p.condition.toUpperCase(),
                  p.condition == 'new' ? Colors.green : Colors.orange,
                )),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Error loading inventory')),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('ITEM NAME', style: _headerStyle())),
          Expanded(flex: 1, child: Text('SKU', style: _headerStyle())),
          Expanded(flex: 1, child: Text('PRICE', style: _headerStyle())),
          Expanded(flex: 1, child: Text('STOCK', style: _headerStyle())),
          Expanded(flex: 1, child: Text('STATUS', style: _headerStyle())),
          const SizedBox(width: 48), // Space for actions
        ],
      ),
    );
  }

  Widget _buildInventoryRow(String name, String sku, String price, String stock, String tag, Color tagColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.image_outlined, color: Colors.white24, size: 20),
                ),
                const SizedBox(width: 16),
                Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(flex: 1, child: Text(sku, style: TextStyle(color: BoostDriveTheme.textDim))),
          Expanded(flex: 1, child: Text(price, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          Expanded(flex: 1, child: Text(stock, style: TextStyle(color: stock == '0' ? Colors.red : Colors.green, fontWeight: FontWeight.bold))),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: tagColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: Text(tag, style: TextStyle(color: tagColor, fontSize: 10, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
            ),
          ),
          const Icon(Icons.more_vert, color: Colors.white24),
        ],
      ),
    );
  }

  TextStyle _headerStyle() => TextStyle(color: BoostDriveTheme.textDim, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1);
}
