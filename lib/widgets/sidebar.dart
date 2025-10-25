import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final Function(String) onMenuItemSelected;
  final String activePage;

  const Sidebar({
    super.key,
    required this.onMenuItemSelected,
    required this.activePage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: const Color(0xFFF5F5F5),
      child: Column(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Scholarly',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          // Main Menu
          Expanded(
            child: ListView(
              children: [
                _buildMenuItem('dashboard', 'Dashboard', Icons.grid_view, activePage == 'dashboard'),
                _buildMenuItem('students', 'Students', Icons.people, activePage == 'students'),
                _buildMenuItem('attendance', 'Attendance', Icons.check_circle, activePage == 'attendance'),
                _buildMenuItem('report', 'Report', Icons.bar_chart, activePage == 'report', badge: '+'),
                _buildMenuItem('announcements', 'Announcements', Icons.notifications, activePage == 'announcements', badge: '+'),
              ],
            ),
          ),
          // Quick Actions
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Text(
                  'Quick Add New Students',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Icon(Icons.group, size: 48, color: Colors.grey),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => onMenuItemSelected('add-student'),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Student'),
                ),
              ],
            ),
          ),
          // Links
          _buildLink('help', 'Help Center', Icons.help),
          _buildLink('settings', 'Settings', Icons.settings),
          _buildLink('sign-out', 'Sign Out', Icons.logout),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String page, String label, IconData icon, bool isActive, {String? badge}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: badge != null ? Text(badge, style: const TextStyle(color: Colors.red)) : null,
      selected: isActive,
      onTap: () => onMenuItemSelected(page),
    );
  }

  Widget _buildLink(String page, String label, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () => onMenuItemSelected(page),
    );
  }
}