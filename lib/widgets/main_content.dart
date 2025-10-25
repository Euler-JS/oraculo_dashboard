import 'package:flutter/material.dart';

class MainContent extends StatelessWidget {
  final String activePage;

  const MainContent({
    super.key,
    required this.activePage,
  });

  @override
  Widget build(BuildContext context) {
    switch (activePage) {
      case 'dashboard':
        return _buildDashboardContent();
      case 'students':
        return _buildStudentsContent();
      case 'attendance':
        return _buildAttendanceContent();
      case 'report':
        return _buildReportContent();
      case 'announcements':
        return _buildAnnouncementsContent();
      case 'help':
        return _buildHelpContent();
      case 'settings':
        return _buildSettingsContent();
      case 'add-student':
        return _buildAddStudentContent();
      default:
        return _buildAttendanceContent();
    }
  }

  Widget _buildDashboardContent() {
    return const Center(
      child: Text('Dashboard Content - Overview and Statistics'),
    );
  }

  Widget _buildStudentsContent() {
    return const Center(
      child: Text('Students Management - List and manage students'),
    );
  }

  Widget _buildAttendanceContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Range Selector and Month Selector
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.calendar_today),
                label: const Text('21 Sep - 29 Sep 2024'),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: 'September',
                items: [
                  'January', 'February', 'March', 'April', 'May', 'June',
                  'July', 'August', 'September', 'October', 'November', 'December'
                ].map((month) => DropdownMenuItem(value: month, child: Text(month))).toList(),
                onChanged: (value) {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Attendance Stats
          Row(
            children: [
              _buildStat('Holiday', 0, Colors.grey.shade300, Icons.calendar_today),
              const SizedBox(width: 16),
              _buildStat('On time 82%', 82, const Color(0xFF2196F3), Icons.check),
              const SizedBox(width: 16),
              _buildStat('Late 10%', 10, const Color(0xFFFFC107), Icons.access_time),
              const SizedBox(width: 16),
              _buildStat('Absent 8%', 8, const Color(0xFFF44336), Icons.close),
            ],
          ),
          const SizedBox(height: 16),
          // Attendance Table
          Expanded(
            child: SingleChildScrollView(
              child: DataTable(
                columns: [
                  const DataColumn(label: Text('Select')),
                  const DataColumn(label: Text('Student Profile')),
                  const DataColumn(label: Text('23\nMon')),
                  const DataColumn(label: Text('24\nTue')),
                  const DataColumn(label: Text('25\nWed')),
                  const DataColumn(label: Text('26\nThu')),
                  const DataColumn(label: Text('27\nFri')),
                  const DataColumn(label: Text('28\nSat')),
                  const DataColumn(label: Text('29\nSun')),
                ],
                rows: _buildRows(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent() {
    return const Center(
      child: Text('Reports and Analytics'),
    );
  }

  Widget _buildAnnouncementsContent() {
    return const Center(
      child: Text('Announcements Management'),
    );
  }

  Widget _buildHelpContent() {
    return const Center(
      child: Text('Help Center - FAQs and Support'),
    );
  }

  Widget _buildSettingsContent() {
    return const Center(
      child: Text('Settings and Preferences'),
    );
  }

  Widget _buildAddStudentContent() {
    return const Center(
      child: Text('Add New Student Form'),
    );
  }

  Widget _buildStat(String label, int percentage, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  List<DataRow> _buildRows() {
    // Sample data from schema
    final students = [
      {'name': 'Maria Adams', 'avatar': 'maria-adams-avatar.jpg'},
      {'name': 'Robin Logan', 'avatar': 'robin-logan-avatar.jpg'},
      {'name': 'Cruz French', 'avatar': 'cruz-french-avatar.jpg'},
      {'name': 'Maria Adams', 'avatar': 'maria-adams-avatar.jpg'},
    ];

    final attendanceData = [
      ['on-time', 'on-time', 'holiday', 'on-time', 'on-time', 'on-time', 'on-time'],
      ['on-time', 'absent', 'on-time', 'on-time', 'on-time', 'on-time', 'on-time'],
      ['on-time', 'on-time', 'on-time', 'on-time', 'on-time', 'on-time', 'on-time'],
      ['on-time', 'on-time', 'late', 'on-time', 'on-time', 'on-time', 'on-time'],
    ];

    return List.generate(students.length, (index) {
      final student = students[index];
      final attendance = attendanceData[index];
      return DataRow(
        cells: [
          DataCell(Checkbox(value: false, onChanged: (value) {})),
          DataCell(Row(
            children: [
              const CircleAvatar(child: Icon(Icons.person)),
              const SizedBox(width: 8),
              Text(student['name']!),
            ],
          )),
          ...attendance.map((status) => DataCell(_buildAttendanceCell(status))),
        ],
      );
    });
  }

  Widget _buildAttendanceCell(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'on-time':
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        label = 'On time';
        break;
      case 'late':
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFE65100);
        label = 'Late';
        break;
      case 'absent':
        bgColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFC62828);
        label = 'Absent';
        break;
      case 'holiday':
        bgColor = const Color(0xFFF5F5F5);
        textColor = const Color(0xFF666666);
        label = 'Holiday';
        break;
      default:
        bgColor = Colors.white;
        textColor = Colors.black;
        label = '';
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(color: textColor, fontSize: 10),
        textAlign: TextAlign.center,
      ),
    );
  }
}