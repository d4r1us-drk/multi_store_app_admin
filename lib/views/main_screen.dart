import 'package:flutter/material.dart';
import 'package:collapsible_sidebar/collapsible_sidebar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_store_app_admin/views/nav_screens/buyers_screen.dart';
import 'package:multi_store_app_admin/views/nav_screens/dashboard_screen.dart';
import 'package:multi_store_app_admin/views/nav_screens/vendors_screen.dart';
import 'package:multi_store_app_admin/views/nav_screens/orders_screen.dart';
import 'package:multi_store_app_admin/views/nav_screens/categories_screen.dart';
import 'package:multi_store_app_admin/views/nav_screens/banner_screen.dart';
import 'package:multi_store_app_admin/views/nav_screens/products_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _selectedPage = 'Dashboard';
  List<CollapsibleItem> _sidebarItems = [];
  late Widget _bodyContent;

  final Map<String, Widget> _pages = {
    'Dashboard': const DashboardScreen(),
    'Vendors': const VendorsScreen(),
    'Buyers': const BuyersScreen(),
    'Orders': const OrdersScreen(),
    'Categories': const CategoriesScreen(),
    'Upload Banners': const BannersScreen(),
    'Products': const ProductsScreen(),
  };

  @override
  void initState() {
    super.initState();
    _bodyContent = _pages[_selectedPage]!;

    _sidebarItems = [
      CollapsibleItem(
        text: 'Dashboard',
        icon: Icons.dashboard,
        onPressed: () => _onItemSelected('Dashboard'),
        isSelected: true,
      ),
      CollapsibleItem(
        text: 'Vendors',
        icon: Icons.store,
        onPressed: () => _onItemSelected('Vendors'),
      ),
      CollapsibleItem(
        text: 'Buyers',
        icon: Icons.people,
        onPressed: () => _onItemSelected('Buyers'),
      ),
      CollapsibleItem(
        text: 'Orders',
        icon: Icons.shopping_cart,
        onPressed: () => _onItemSelected('Orders'),
      ),
      CollapsibleItem(
        text: 'Categories',
        icon: Icons.category,
        onPressed: () => _onItemSelected('Categories'),
      ),
      CollapsibleItem(
        text: 'Upload Banners',
        icon: Icons.image,
        onPressed: () => _onItemSelected('Upload Banners'),
      ),
      CollapsibleItem(
        text: 'Products',
        icon: Icons.production_quantity_limits,
        onPressed: () => _onItemSelected('Products'),
      ),
    ];
  }

  void _onItemSelected(String page) {
    setState(() {
      _selectedPage = page;
      _bodyContent = _pages[page]!;
      for (var item in _sidebarItems) {
        item.isSelected = item.text == page;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color darkerBlue = Color(0xFF005BB5);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(
              Icons.store,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              'MultiStore App',
              style: GoogleFonts.lato(
                textStyle: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: darkerBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: CollapsibleSidebar(
        items: _sidebarItems,
        title: 'Admin Panel',
        backgroundColor: darkerBlue,
        selectedTextColor: Colors.white,
        textStyle: GoogleFonts.lato(
          textStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        selectedIconColor: Colors.white,
        unselectedIconColor: Colors.white,
        body: _bodyContent,
        toggleTitle: 'Collapse',
        sidebarBoxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            spreadRadius: 1,
            offset: Offset(3, 3),
          ),
        ],
      ),
    );
  }
}
