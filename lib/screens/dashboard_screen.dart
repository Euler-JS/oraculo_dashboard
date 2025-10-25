import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/header.dart';
import '../widgets/main_content.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _activePage = 'attendance'; // Default to attendance

  void _onMenuItemSelected(String page) {
    setState(() {
      _activePage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(onMenuItemSelected: _onMenuItemSelected, activePage: _activePage),
          Expanded(
            child: Column(
              children: [
                Header(activePage: _activePage),
                Expanded(
                  child: MainContent(activePage: _activePage),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}