import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/destination.dart';
import '../../providers/review_provider.dart';
import '../../services/destination_service.dart';
import '../home/home_screen.dart';
import '../destinations/destinations_list_screen.dart';
import '../profile/profile_screen.dart';
import '../planner/trip_planner_screen.dart';
import '../reviews/review_form_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  
  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;
  final DestinationService _destinationService = DestinationService();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _screens = [
    const HomeScreen(showAppBar: true),
    const DestinationsListScreen(),
    const TripPlannerScreen(),
    const ProfileScreen(),
  ];

  Future<void> _openCreatePost() async {
    try {
      final destinations = await _destinationService.getDestinations();
      if (!mounted) {
        return;
      }

      if (destinations.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No destinations available yet.')),
        );
        return;
      }

      final created = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => ReviewFormScreen(
            destinations: List<Destination>.from(destinations),
          ),
        ),
      );

      if (created == true && mounted) {
        await context.read<ReviewProvider>().loadTopReviews();
        setState(() {
          _currentIndex = 0;
        });
      }
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        mini: true,
        onPressed: _openCreatePost,
        tooltip: 'Create Post',
        elevation: 2,
        backgroundColor: primary,
        child: const Icon(Icons.add, size: 22, color: Colors.white),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        elevation: 10,
        shadowColor: Colors.black12,
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 66,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home,
                  label: 'Home',
                  isActive: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _buildNavItem(
                  icon: Icons.explore,
                  label: 'Explore',
                  isActive: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                const SizedBox(width: 44),
                _buildNavItem(
                  icon: Icons.auto_graph,
                  label: 'Planner',
                  isActive: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                _buildNavItem(
                  icon: Icons.person,
                  label: 'Profile',
                  isActive: _currentIndex == 3,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final primary = Theme.of(context).primaryColor;
    final color = isActive ? primary : Colors.grey[600];

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
