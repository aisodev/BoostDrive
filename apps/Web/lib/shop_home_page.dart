import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:boostdrive_ui/boostdrive_ui.dart';
import 'package:boostdrive_services/boostdrive_services.dart';
import 'package:boostdrive_core/boostdrive_core.dart';
import 'package:boostdrive_auth/boostdrive_auth.dart';
import 'parts_marketplace_page.dart';
import 'rental_marketplace_page.dart';
import 'all_listings_page.dart';
import 'messages_page.dart';
import 'product_detail_page.dart';
import 'add_listing_page.dart';
import 'new_arrivals_page.dart';
import 'company_pages.dart';
import 'support_pages.dart';
import 'customer_dashboard_page.dart';
import 'service_pro_dashboard_page.dart';
import 'seller_dashboard_page.dart';
import 'super_admin_dashboard_page.dart';
import 'logistics_dashboard_page.dart';
// import 'role_selection_page.dart'; // Removing local import

class ShopHomePage extends ConsumerStatefulWidget {
  const ShopHomePage({super.key});

  @override
  ConsumerState<ShopHomePage> createState() => _ShopHomePageState();
}

class _ShopHomePageState extends ConsumerState<ShopHomePage> {
  final ProductService _productService = ProductService();
  late Future<List<Product>> _featuredProductsFuture;

  @override
  void initState() {
    super.initState();
    _featuredProductsFuture = _productService.getFeaturedProducts();
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: const BoostLoginPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider).value;
    final user = authState?.session?.user;
    
    if (user != null) {
      final profileAsync = ref.watch(userProfileProvider(user.id));
      profileAsync.whenData((profile) {
        if (profile != null) {
          // Check if user has no role set and isn't marked as buyer/seller
          // Note: profile.role defaults to 'customer' in the model if missing in data
          if (!profile.isBuyer && !profile.isSeller) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RoleSelectionPage()),
              );
            });
          }
        }
      });
    }

    return PremiumPageLayout(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            const Text(
              'BoostDrive',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -1),
            ),
            if (user != null) ...[
              const SizedBox(width: 24),
              ref.watch(userProfileProvider(user.id)).when(
                data: (profile) {
                  if (profile == null) {
                    return const SizedBox();
                  }
                  
                  final hour = DateTime.now().hour;
                  String greeting;
                  if (hour < 12) {
                    greeting = 'Good Morning';
                  } else if (hour < 17) {
                    greeting = 'Good Afternoon';
                  } else {
                    greeting = 'Good Evening';
                  }
                  
                  return Text(
                    '$greeting, ${profile.fullName.split(' ').first}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PartsMarketplacePage())),
            child: const Text('PARTS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
          TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MessagesPage())),
            child: const Text('MESSAGES', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
          TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RentalMarketplacePage())),
            child: const Text('RENTALS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
          if (user != null)
            TextButton(
              onPressed: () {
                final profile = ref.read(userProfileProvider(user.id)).value;
                if (profile != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => _getDashboardForRole(profile.role)),
                  );
                }
              },
              child: const Text('DASHBOARD', style: TextStyle(fontWeight: FontWeight.bold, color: BoostDriveTheme.primaryBlue, letterSpacing: 1)),
            ),
          const SizedBox(width: 24),
          if (user != null)
             ref.watch(userProfileProvider(user.id)).whenData((profile) {
               if (profile == null) return const SizedBox();
               return Container(
                 margin: const EdgeInsets.only(right: 16),
                 child: Chip(
                   label: Text(profile.role.toUpperCase()),
                   backgroundColor: BoostDriveTheme.primaryBlue.withOpacity(0.1),
                   labelStyle: const TextStyle(
                     color: BoostDriveTheme.primaryBlue,
                     fontWeight: FontWeight.w900,
                     fontSize: 10,
                     letterSpacing: 0.5,
                   ),
                   side: BorderSide(color: BoostDriveTheme.primaryBlue.withOpacity(0.2), width: 1),
                 ),
               );
             }).value ?? const SizedBox(),
          ElevatedButton(
            onPressed: () {
              if (user == null) {
                _showLoginDialog();
              } else {
                ref.read(authServiceProvider).signOut();
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(100, 44),
              backgroundColor: user == null ? BoostDriveTheme.primaryBlue : Colors.white10,
            ),
            child: Text(user == null ? 'Login' : 'Log Out'),
          ),
          const SizedBox(width: 40),
        ],
      ),
      footer: AppFooter(
        onLinkTap: (section, title) {
          if (title == 'Contact') {
            _showContactDialog(context);
            return;
          }
          
          Widget? page;
          switch (title) {
            case 'Buy Parts':
              page = const PartsMarketplacePage();
              break;
            case 'Rent a Car':
              page = const RentalMarketplacePage();
              break;
            case 'Sell Your Vehicle':
              // Logic to handle auth before navigation is already in _ShopHomePageState
              if (ref.read(currentUserProvider) == null) {
                _showLoginDialog();
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AddListingPage()));
              }
              return;
            case 'New Arrivals':
              page = const NewArrivalsPage();
              break;
            case 'About Us':
              page = const AboutPage();
              break;
            case 'Careers':
              page = const CareersPage();
              break;
            case 'Partner Program':
              page = const PartnerProgramPage();
              break;
            case 'Safety Center':
              page = const SafetyCenterPage();
              break;
            case 'Terms of Service':
              page = const TermsPage();
              break;
            case 'Privacy Policy':
              page = const PrivacyPolicyPage();
              break;
            case 'FAQ':
              page = const FaqPage();
              break;
          }

          if (page != null) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => page!));
          }
        },
      ),
      child: Column(
        children: [
          HeroSection(
            title: 'Your Complete Automotive Ecosystem',
            subtitle: 'The premier destination to buy, sell, and rent vehicles in Namibia. Drive your dreams forward with BoostDrive.',
            // backgroundImage removed to prevent overlap with PremiumPageLayout global background
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PartsMarketplacePage())),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 64),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: const Text('Shop Spare Parts'),
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(200, 64),
                  side: const BorderSide(color: Colors.white24, width: 2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('+ Add New Listing', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                onPressed: () async {
                  if (user == null) {
                    _showLoginDialog();
                  } else {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddListingPage()),
                    );
                    
                    if (result == true) {
                      // Refresh the featured products
                      setState(() {
                        _featuredProductsFuture = _productService.getFeaturedProducts();
                      });
                    }
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 80),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'All Listings',
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Hand-picked vehicles and parts from verified sellers.',
                          style: TextStyle(color: BoostDriveTheme.textDim, fontSize: 16),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AllListingsPage()),
                      ),
                      icon: const Text('View All', style: TextStyle(fontWeight: FontWeight.bold)),
                      label: const Icon(Icons.arrow_forward, size: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                _buildGrid(),
              ],
            ),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: FutureBuilder<List<Product>>(
        future: _featuredProductsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Padding(padding: EdgeInsets.all(40.0), child: CircularProgressIndicator()));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading products: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products found.'));
          }
          final products = snapshot.data!;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              mainAxisExtent: 450,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
            ),
            itemCount: products.length > 4 ? 4 : products.length,
            itemBuilder: (context, index) => BoostProductCard(
              product: products[index],
              onTap: () async {
                final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailPage(product: products[index])));
                if (result == true) {
                  setState(() {
                    _featuredProductsFuture = _productService.getFeaturedProducts();
                  });
                }
              },
            ),
          );
        },
      ),
    );
  }


  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: BoostDriveTheme.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Contact Us', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ContactItem(icon: Icons.phone, title: 'Phone', content: '+264 61 123 4567'),
            const SizedBox(height: 16),
            _ContactItem(icon: Icons.email, title: 'Email', content: 'support@boostdrive.na'),
            const SizedBox(height: 16),
            _ContactItem(icon: Icons.location_on, title: 'Address', content: '123 Independence Ave, Windhoek'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: BoostDriveTheme.primaryBlue)),
          ),
        ],
      ),
    );
  }
  Widget _getDashboardForRole(String role) {
    switch (role.toLowerCase()) {
      case 'super_admin':
      case 'super admin':
        return const SuperAdminDashboardPage();
      case 'service_pro':
      case 'service pro':
      case 'mechanic & towing':
        return const ServiceProDashboardPage();
      case 'seller':
      case 'parts & salvage seller':
        return const SellerDashboardPage();
      case 'logistics':
      case 'batlorrih logistics':
        return const LogisticsDashboardPage();
      case 'customer':
      default:
        return const CustomerDashboardPage();
    }
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _ContactItem({required this.icon, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: BoostDriveTheme.primaryBlue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: BoostDriveTheme.primaryBlue, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: BoostDriveTheme.textDim, fontSize: 12)),
            Text(content, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}

// _WebLoginWrapper and its state class have been removed in favor of BoostLoginPage
