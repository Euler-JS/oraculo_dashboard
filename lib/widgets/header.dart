import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final String activePage;

  const Header({
    super.key,
    required this.activePage,
  });

  String _getPageTitle() {
    switch (activePage) {
      case 'dashboard':
        return 'Dashboard';
      case 'students':
        return 'Students';
      case 'attendance':
        return 'Attendance';
      case 'report':
        return 'Report';
      case 'announcements':
        return 'Announcements';
      case 'help':
        return 'Help Center';
      case 'settings':
        return 'Settings';
      default:
        return 'Scholarly';
    }
  }

  String _getPageSubtitle() {
    switch (activePage) {
      case 'dashboard':
        return 'Overview of your school management';
      case 'students':
        return 'Manage student information';
      case 'attendance':
        return 'Manage attendance records';
      case 'report':
        return 'View reports and analytics';
      case 'announcements':
        return 'Manage school announcements';
      case 'help':
        return 'Get help and support';
      case 'settings':
        return 'Configure your preferences';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Page Title
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getPageTitle(),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  _getPageSubtitle(),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          // Search Box
          Expanded(
            flex: 1,
            child: SizedBox(
              width: 200,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search here...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Icons
          IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.refresh)),
          Stack(
            children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '0',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
          // User Profile
          PopupMenuButton<String>(
            onSelected: (value) {},
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'profile', child: Text('Profile')),
              const PopupMenuItem(value: 'settings', child: Text('Settings')),
              const PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 16,
                  child: Icon(Icons.person, size: 16),
                ),
                const SizedBox(width: 8),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mithun Ray', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    Text('Student', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
                const Icon(Icons.arrow_drop_down, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}