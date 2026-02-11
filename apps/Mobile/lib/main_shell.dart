import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:boostdrive_ui/boostdrive_ui.dart';
import 'customer_dashboard.dart';
import 'service_pro_dashboard.dart';
import 'seller_dashboard.dart';
import 'super_admin_dashboard.dart';
import 'batlorrih_logistics_dashboard.dart';
import 'marketplace_page.dart';
import 'conversations_page.dart';
import 'providers.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeRole = ref.watch(activeRoleProvider);
    
    Widget body;
    List<BottomNavigationBarItem> navItems;
    
    if (activeRole == 'service_pro') {
      body = _buildServiceProBody();
      navItems = _buildServiceProNav();
    } else if (activeRole == 'seller') {
      body = _buildSellerBody();
      navItems = _buildSellerNav();
    } else if (activeRole == 'super_admin') {
      body = _buildSuperAdminBody();
      navItems = _buildSuperAdminNav();
    } else if (activeRole == 'logistics') {
      body = _buildLogisticsBody();
      navItems = _buildLogisticsNav();
    } else {
      body = _buildCustomerBody();
      navItems = _buildCustomerNav();
    }

    // Protection against out-of-bounds when switching roles
    if (_currentIndex >= navItems.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      body: body,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.05),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          backgroundColor: BoostDriveTheme.surfaceDark,
          selectedItemColor: BoostDriveTheme.primaryBlue,
          unselectedItemColor: BoostDriveTheme.textDim,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          items: navItems,
        ),
      ),
    );
  }

  Widget _buildCustomerBody() {
    switch (_currentIndex) {
      case 0: return const CustomerDashboard();
      case 1: return const Center(child: Text('Garage', style: TextStyle(color: Colors.white)));
      case 2: return const MarketplacePage();
      case 3: return const Center(child: Text('Service', style: TextStyle(color: Colors.white)));
      case 4: return const Center(child: Text('Profile', style: TextStyle(color: Colors.white)));
      default: return const CustomerDashboard();
    }
  }

  List<BottomNavigationBarItem> _buildCustomerNav() {
    return const [
      BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'HOME'),
      BottomNavigationBarItem(icon: Icon(Icons.directions_car_outlined), activeIcon: Icon(Icons.directions_car), label: 'GARAGE'),
      BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), activeIcon: Icon(Icons.shopping_bag), label: 'SHOP'),
      BottomNavigationBarItem(icon: Icon(Icons.build_outlined), activeIcon: Icon(Icons.build), label: 'SERVICE'),
      BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'PROFILE'),
    ];
  }

  Widget _buildServiceProBody() {
    switch (_currentIndex) {
      case 0: return const ServiceProDashboard();
      case 1: return const Center(child: Text('History', style: TextStyle(color: Colors.white)));
      case 2: return const Center(child: Text('Earnings', style: TextStyle(color: Colors.white)));
      case 3: return const Center(child: Text('Profile', style: TextStyle(color: Colors.white)));
      default: return const ServiceProDashboard();
    }
  }

  List<BottomNavigationBarItem> _buildServiceProNav() {
    return const [
      BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'HOME'),
      BottomNavigationBarItem(icon: Icon(Icons.history), activeIcon: Icon(Icons.history), label: 'HISTORY'),
      BottomNavigationBarItem(icon: Icon(Icons.payments_outlined), activeIcon: Icon(Icons.payments), label: 'EARNINGS'),
      BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'PROFILE'),
    ];
  }

  Widget _buildSellerBody() {
    switch (_currentIndex) {
      case 0: return const SellerDashboard();
      case 1: return const Center(child: Text('Inventory', style: TextStyle(color: Colors.white)));
      case 2: return const Center(child: Text('Orders', style: TextStyle(color: Colors.white)));
      case 3: return const Center(child: Text('Services', style: TextStyle(color: Colors.white)));
      case 4: return const Center(child: Text('Account', style: TextStyle(color: Colors.white)));
      default: return const SellerDashboard();
    }
  }

  List<BottomNavigationBarItem> _buildSellerNav() {
    return const [
      BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), activeIcon: Icon(Icons.grid_view_rounded), label: 'DASHBOARD'),
      BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2), label: 'INVENTORY'),
      BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), activeIcon: Icon(Icons.shopping_cart), label: 'ORDERS'),
      BottomNavigationBarItem(icon: Icon(Icons.build_circle_outlined), activeIcon: Icon(Icons.build_circle), label: 'SERVICES'),
      BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'ACCOUNT'),
    ];
  }

  Widget _buildSuperAdminBody() {
    switch (_currentIndex) {
      case 0: return const SuperAdminDashboard();
      case 1: return const Center(child: Text('Financials', style: TextStyle(color: Colors.white)));
      case 2: return const Center(child: Text('Partners', style: TextStyle(color: Colors.white)));
      case 3: return const Center(child: Text('SOS Feed', style: TextStyle(color: Colors.white)));
      case 4: return const Center(child: Text('More', style: TextStyle(color: Colors.white)));
      default: return const SuperAdminDashboard();
    }
  }

  List<BottomNavigationBarItem> _buildSuperAdminNav() {
    return const [
      BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'OVERVIEW'),
      BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), activeIcon: Icon(Icons.analytics), label: 'FINANCIALS'),
      BottomNavigationBarItem(icon: Icon(Icons.group_outlined), activeIcon: Icon(Icons.group), label: 'PARTNERS'),
      BottomNavigationBarItem(icon: Icon(Icons.sos_outlined), activeIcon: Icon(Icons.sos), label: 'SOS FEED'),
      BottomNavigationBarItem(icon: Icon(Icons.menu), activeIcon: Icon(Icons.menu), label: 'MORE'),
    ];
  }

  Widget _buildLogisticsBody() {
    switch (_currentIndex) {
      case 0: return const BaTLorriHLogisticsDashboard();
      case 1: return const Center(child: Text('Routes', style: TextStyle(color: Colors.white)));
      case 2: return const Center(child: Text('Fleet', style: TextStyle(color: Colors.white)));
      case 3: return const Center(child: Text('Finance', style: TextStyle(color: Colors.white)));
      default: return const BaTLorriHLogisticsDashboard();
    }
  }

  List<BottomNavigationBarItem> _buildLogisticsNav() {
    return const [
      BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), activeIcon: Icon(Icons.grid_view_rounded), label: 'HOME'),
      BottomNavigationBarItem(icon: Icon(Icons.route_outlined), activeIcon: Icon(Icons.route), label: 'ROUTES'),
      BottomNavigationBarItem(icon: Icon(Icons.group_outlined), activeIcon: Icon(Icons.group), label: 'FLEET'),
      BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), activeIcon: Icon(Icons.analytics), label: 'FINANCE'),
    ];
  }
}
