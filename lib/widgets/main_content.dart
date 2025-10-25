import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/attendance_service.dart';
import '../models/employee.dart';
import '../models/attendance.dart';
import 'attendance_table.dart';

class MainContent extends StatefulWidget {
  final String activePage;

  const MainContent({
    super.key,
    required this.activePage,
  });

  @override
  State<MainContent> createState() => _MainContentState();
}

class _MainContentState extends State<MainContent> {
  final AttendanceService _attendanceService = AttendanceService();

  List<Employee> _employees = [];
  Map<String, List<Attendance>> _attendanceData = {};
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 7)),
    end: DateTime.now(),
  );
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(MainContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activePage != widget.activePage) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    if (widget.activePage != 'attendance') return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load employees and attendance data in parallel
      final employeesFuture = _attendanceService.getEmployees();
      final attendanceFuture = _attendanceService.getAttendanceData(
        startDate: _dateRange.start,
        endDate: _dateRange.end,
      );

      final results = await Future.wait([employeesFuture, attendanceFuture]);

      setState(() {
        _employees = results[0] as List<Employee>;
        _attendanceData = results[1] as Map<String, List<Attendance>>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar dados: $e';
        _isLoading = false;
      });
    }
  }

  void _updateDateRange(DateTimeRange newRange) {
    setState(() {
      _dateRange = newRange;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.activePage) {
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
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Range Selector
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                    initialDateRange: _dateRange,
                  );
                  if (picked != null) {
                    _updateDateRange(picked);
                  }
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  '${DateFormat('dd MMM').format(_dateRange.start)} - ${DateFormat('dd MMM yyyy').format(_dateRange.end)}',
                ),
              ),
              const SizedBox(width: 16),
              // Month selector (optional - could be removed or enhanced)
              DropdownButton<String>(
                value: DateFormat('MMMM').format(_dateRange.start),
                items: [
                  'January', 'February', 'March', 'April', 'May', 'June',
                  'July', 'August', 'September', 'October', 'November', 'December'
                ].map((month) => DropdownMenuItem(value: month, child: Text(month))).toList(),
                onChanged: (value) {
                  // Could implement month navigation here
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Attendance Stats (calculated from real data)
          Row(
            children: _buildAttendanceStats(),
          ),
          const SizedBox(height: 16),

          // Attendance Table with real data
          Expanded(
            child: AttendanceTable(
              employees: _employees,
              attendanceData: _attendanceData,
              dateRange: _dateRange,
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

  List<Widget> _buildAttendanceStats() {
    if (_employees.isEmpty) {
      return [_buildStat('Sem dados', 0, Colors.grey, Icons.info)];
    }

    int totalRecords = 0;
    int onTimeCount = 0;
    int lateCount = 0;
    int absentCount = 0;
    int justifiedCount = 0;

    // Calculate stats from real data
    for (final employee in _employees) {
      final employeeAttendance = _attendanceData[employee.id] ?? [];
      for (final attendance in employeeAttendance) {
        totalRecords++;
        switch (attendance.status) {
          case 'Presente':
            onTimeCount++;
            break;
          case 'Atrasado':
            lateCount++;
            break;
          case 'Ausente':
            absentCount++;
            break;
          case 'Justificado':
            justifiedCount++;
            break;
        }
      }
    }

    if (totalRecords == 0) {
      return [_buildStat('Sem registros', 0, Colors.grey, Icons.info)];
    }

    final onTimePercent = ((onTimeCount / totalRecords) * 100).round();
    final latePercent = ((lateCount / totalRecords) * 100).round();
    final absentPercent = ((absentCount / totalRecords) * 100).round();
    final justifiedPercent = ((justifiedCount / totalRecords) * 100).round();

    return [
      _buildStat('Presente ${onTimePercent}%', onTimePercent, const Color(0xFF4CAF50), Icons.check),
      const SizedBox(width: 16),
      _buildStat('Atrasado ${latePercent}%', latePercent, const Color(0xFFFFC107), Icons.access_time),
      const SizedBox(width: 16),
      _buildStat('Ausente ${absentPercent}%', absentPercent, const Color(0xFFF44336), Icons.close),
      const SizedBox(width: 16),
      _buildStat('Justificado ${justifiedPercent}%', justifiedPercent, const Color(0xFF2196F3), Icons.info),
    ];
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
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}