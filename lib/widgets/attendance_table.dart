import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/employee.dart';
import '../models/attendance.dart';

class AttendanceTable extends StatefulWidget {
  final List<Employee> employees;
  final Map<String, List<Attendance>> attendanceData;
  final DateTimeRange? dateRange;

  const AttendanceTable({
    super.key,
    required this.employees,
    required this.attendanceData,
    this.dateRange,
  });

  @override
  State<AttendanceTable> createState() => _AttendanceTableState();
}

class _AttendanceTableState extends State<AttendanceTable> {
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Registros de Presença',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Funcionário')),
                    DataColumn(label: Text('Data')),
                    DataColumn(label: Text('Entrada')),
                    DataColumn(label: Text('Saída')),
                    DataColumn(label: Text('Status')),
                  ],
                  rows: _buildTableRows(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DataRow> _buildTableRows() {
    final rows = <DataRow>[];

    for (final employee in widget.employees) {
      final employeeAttendance = widget.attendanceData[employee.id] ?? [];

      for (final attendance in employeeAttendance) {
        // Filter by date range if provided
        if (widget.dateRange != null) {
          final attendanceDate = DateTime.parse(attendance.date);
          if (attendanceDate.isBefore(widget.dateRange!.start) ||
              attendanceDate.isAfter(widget.dateRange!.end)) {
            continue;
          }
        }

        rows.add(DataRow(
          cells: [
            DataCell(Text(employee.name)),
            DataCell(Text(_dateFormat.format(DateTime.parse(attendance.date)))),
            DataCell(Text(attendance.checkIn ?? '-')),
            DataCell(Text(attendance.checkOut ?? '-')),
            DataCell(_buildStatusChip(attendance.status)),
          ],
        ));
      }
    }

    return rows;
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'Presente':
        color = Colors.green;
        break;
      case 'Atrasado':
        color = Colors.orange;
        break;
      case 'Ausente':
        color = Colors.red;
        break;
      case 'Justificado':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        status,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
    );
  }
}