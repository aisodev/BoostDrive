import 'package:boostdrive_core/boostdrive_core.dart';
import 'package:boostdrive_auth/boostdrive_auth.dart';
import 'package:boostdrive_services/boostdrive_services.dart';
import 'providers.dart';

class SellerDashboard extends ConsumerStatefulWidget {
  const SellerDashboard({super.key});

  @override
  ConsumerState<SellerDashboard> createState() => _SellerDashboardState();
}

class _SellerDashboardState extends ConsumerState<SellerDashboard> with SingleTickerProviderStateMixin {
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
              _buildPerformanceSection(ref, user.id),
              const SizedBox(height: 32),
              _buildTabSection(ref, user.id),
              const SizedBox(height: 32),
              _buildServiceRequests(),
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
            CircleAvatar(
              radius: 24,
              backgroundImage: profile.profileImg.isNotEmpty ? NetworkImage(profile.profileImg) : null,
              child: profile.profileImg.isEmpty ? const Icon(Icons.person) : null,
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
                  profile.isSeller ? 'Verified Seller' : 'Individual Seller',
                  style: TextStyle(color: BoostDriveTheme.textDim, fontSize: 13),
                ),
              ],
            ),
            const Spacer(),
            _buildHeaderIcon(Icons.search),
            const SizedBox(width: 12),
            _buildHeaderIcon(Icons.notifications_none_rounded, hasNotification: true),
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

  Widget _buildPerformanceSection(WidgetRef ref, String uid) {
    return ref.watch(userProfileProvider(uid)).when(
      data: (profile) {
        if (profile == null) return const SizedBox();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Performance',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                ),
                Row(
                  children: [
                    Text('All Time', style: TextStyle(color: BoostDriveTheme.primaryBlue, fontSize: 13, fontWeight: FontWeight.bold)),
                    const Icon(Icons.keyboard_arrow_down, color: BoostDriveTheme.primaryBlue, size: 18),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildPerformanceCard('Total Earnings', '\$${profile.totalEarnings.toStringAsFixed(0)}', 'LIFETIME', true),
                  const SizedBox(width: 12),
                  _buildPerformanceCard('Loyalty Points', profile.loyaltyPoints.toString(), 'REDEEMABLE', true),
                  const SizedBox(width: 12),
                  _buildPerformanceCard('Status', profile.verificationStatus.toUpperCase(), 'VERIFIED', false),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
    );
  }

  Widget _buildPerformanceCard(String label, String value, String trend, bool isPositive) {
    return Container(
      width: 140,
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
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Row(
            children: [
              if (isPositive) const Icon(Icons.trending_up, color: Colors.green, size: 12),
              if (isPositive) const SizedBox(width: 4),
              Text(
                trend,
                style: TextStyle(color: isPositive ? Colors.green : BoostDriveTheme.textDim, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection(WidgetRef ref, String uid) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          indicatorColor: BoostDriveTheme.primaryBlue,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: BoostDriveTheme.textDim,
          labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
          tabs: const [
            Tab(text: 'INVENTORY'),
            Tab(text: 'SERVICE REQUESTS'),
            Tab(text: 'ORDERS'),
          ],
        ),
        const SizedBox(height: 24),
        _buildInventoryView(ref, uid),
      ],
    );
  }

  Widget _buildInventoryView(WidgetRef ref, String uid) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.white24, size: 20),
                    const SizedBox(width: 12),
                    Text('Search SKU, name or VIN...', style: TextStyle(color: Colors.white24, fontSize: 13)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.tune, color: Colors.white, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ref.watch(sellerProductsProvider(uid)).when(
          data: (products) {
            if (products.isEmpty) return Text('No listings in your inventory.', style: TextStyle(color: BoostDriveTheme.textDim));
            return Column(
              children: products.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildInventoryItem(
                  name: p.title,
                  sku: p.id.substring(0, 8).toUpperCase(),
                  price: '\$${p.price.toStringAsFixed(2)}',
                  stock: p.status.toUpperCase(),
                  tag: p.condition.toUpperCase(),
                  tagColor: p.status == 'active' ? Colors.green : Colors.grey,
                  imageUrl: p.imageUrl,
                ),
              )).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Text('Error loading inventory'),
        ),
      ],
    );
  }

  Widget _buildInventoryItem({
    required String name,
    required String sku,
    required String price,
    required String stock,
    required String tag,
    required Color tagColor,
    String? imageUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BoostDriveTheme.surfaceDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  image: imageUrl != null && imageUrl.isNotEmpty ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover) : null,
                ),
                child: imageUrl == null || imageUrl.isEmpty ? const Icon(Icons.image_outlined, color: Colors.white10) : null,
              ),
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: tagColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(tag, style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    const Icon(Icons.more_vert, color: Colors.white24, size: 20),
                  ],
                ),
                Text('SKU: $sku', style: TextStyle(color: BoostDriveTheme.textDim, fontSize: 11)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(price, style: const TextStyle(color: BoostDriveTheme.primaryBlue, fontSize: 15, fontWeight: FontWeight.w900)),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(stock, style: const TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceRequests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Service Requests',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('VIEW ALL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
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
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: BoostDriveTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.build, color: BoostDriveTheme.primaryBlue, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'INSTALLATION REQUEST',
                    style: TextStyle(color: BoostDriveTheme.primaryBlue, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Transmission Swap - Alex Johnson',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Linked Part: 2015 Camry Transmission (Used)',
                style: TextStyle(color: BoostDriveTheme.textDim, fontSize: 13),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BoostDriveTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Accept Task'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 52),
                        side: BorderSide(color: Colors.white.withOpacity(0.1)),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Decline'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
