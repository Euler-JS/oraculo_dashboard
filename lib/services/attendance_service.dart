import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../config/api_config.dart';
import '../models/employee.dart';
import '../models/attendance.dart';

class AttendanceService {
  Future<List<Employee>> getEmployees() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.employees}'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Employee.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load employees: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      // Fallback to mock data if API is not available
      print('API not available, using mock data: $e');
      return _getMockEmployees();
    }
  }

  Future<Map<String, List<Attendance>>> getAttendanceData({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String().split('T')[0];
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.attendance}')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final attendances = data.map((json) => Attendance.fromJson(json)).toList();

        // Group by employee ID
        final Map<String, List<Attendance>> groupedData = {};
        for (final attendance in attendances) {
          if (!groupedData.containsKey(attendance.employeeId)) {
            groupedData[attendance.employeeId] = [];
          }
          groupedData[attendance.employeeId]!.add(attendance);
        }

        return groupedData;
      } else {
        throw Exception('Failed to load attendance data: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      // Fallback to mock data if API is not available
      print('API not available, using mock data: $e');
      return _getMockAttendanceData();
    }
  }

  Future<List<Attendance>> getAttendanceForDate(DateTime date) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.attendance}?date=$dateStr'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Attendance.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load attendance: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      // Fallback to mock data if API is not available
      print('API not available, using mock data: $e');
      return _getMockAttendanceForDate(date);
    }
  }

  Future<Map<String, List<Attendance>>> getAttendanceForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final startStr = DateFormat('yyyy-MM-dd').format(startDate);
      final endStr = DateFormat('yyyy-MM-dd').format(endDate);
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.attendance}?start_date=$startStr&end_date=$endStr'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final Map<String, List<Attendance>> result = {};

        // Group attendance by employee ID
        for (final attendanceJson in data) {
          final attendance = Attendance.fromJson(attendanceJson);
          final employeeId = attendance.employeeId;
          if (!result.containsKey(employeeId)) {
            result[employeeId] = [];
          }
          result[employeeId]!.add(attendance);
        }

        return result;
      } else {
        throw Exception('Failed to load attendance range: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      // Fallback to mock data if API is not available
      print('API not available, using mock data: $e');
      return _getMockAttendanceForDateRange(startDate, endDate);
    }
  }

  Future<Attendance> registerAttendance(String employeeCode) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.attendanceRegister}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'employee_code': employeeCode,
          'auth_method': 'qr',
        }),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('attendance')) {
          return Attendance.fromJson(data['attendance']);
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to register attendance');
      }
    } catch (e) {
      print('Failed to register attendance: $e');
      throw Exception('Failed to register attendance: $e');
    }
  }

  // Mock data fallbacks for when API is not available
  List<Employee> _getMockEmployees() {
    return [
      const Employee(
        id: '92568761-42ed-4c9f-bcab-d1376cc36e81',
        name: 'João Muchunja',
        position: 'Programador',
        department: 'Informatica',
        internalCode: 'AEM753',
      ),
      const Employee(
        id: '14adfa5e-5e5b-469f-af7e-f5c3843f4fe4',
        name: 'José Jorge Nguiraze',
        position: 'Programador',
        department: 'Informatica',
        internalCode: 'AEM114',
      ),
      const Employee(
        id: 'mock-3',
        name: 'Maria Silva',
        position: 'Administração',
        department: 'Administracao',
        internalCode: 'AEM999',
      ),
    ];
  }

  Map<String, List<Attendance>> _getMockAttendanceData() {
    final now = DateTime.now();
    return {
      '92568761-42ed-4c9f-bcab-d1376cc36e81': [
        Attendance(
          id: 'mock-1',
          employeeId: '92568761-42ed-4c9f-bcab-d1376cc36e81',
          date: DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 1))),
          checkIn: '08:05',
          checkOut: '17:30',
          lateMinutes: 5,
          status: 'Presente',
          authMethod: 'qr',
        ),
        Attendance(
          id: 'mock-2',
          employeeId: '92568761-42ed-4c9f-bcab-d1376cc36e81',
          date: DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 2))),
          checkIn: '08:15',
          checkOut: '17:30',
          lateMinutes: 15,
          status: 'Atrasado',
          authMethod: 'code',
        ),
      ],
      '14adfa5e-5e5b-469f-af7e-f5c3843f4fe4': [
        Attendance(
          id: 'mock-3',
          employeeId: '14adfa5e-5e5b-469f-af7e-f5c3843f4fe4',
          date: DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 1))),
          checkIn: '07:55',
          checkOut: '17:15',
          status: 'Presente',
          authMethod: 'code',
        ),
      ],
      'mock-3': [
        Attendance(
          id: 'mock-4',
          employeeId: 'mock-3',
          date: DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 1))),
          checkIn: null,
          checkOut: null,
          status: 'Ausente',
          authMethod: 'qr',
        ),
      ],
    };
  }

  List<Attendance> _getMockAttendanceForDate(DateTime date) {
    final String dateStr = DateFormat('yyyy-MM-dd').format(date);
    return [
      Attendance(
        id: 'mock-101',
        employeeId: '92568761-42ed-4c9f-bcab-d1376cc36e81',
        date: dateStr,
        checkIn: '08:05',
        checkOut: '17:30',
        lateMinutes: 5,
        status: 'Presente',
        authMethod: 'qr',
      ),
      Attendance(
        id: 'mock-102',
        employeeId: '14adfa5e-5e5b-469f-af7e-f5c3843f4fe4',
        date: dateStr,
        checkIn: '07:55',
        checkOut: '17:15',
        status: 'Presente',
        authMethod: 'code',
      ),
    ];
  }

  Map<String, List<Attendance>> _getMockAttendanceForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    final Map<String, List<Attendance>> result = {};

    // For each employee
    final employees = _getMockEmployees();
    for (final employee in employees) {
      final List<Attendance> records = [];

      // For each date in the range
      for (DateTime date = startDate;
           date.isBefore(endDate.add(const Duration(days: 1)));
           date = date.add(const Duration(days: 1))) {

        final String dateStr = DateFormat('yyyy-MM-dd').format(date);

        // Skip weekends
        if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
          continue;
        }

        // Generate mock attendance
        final int hash = employee.id.hashCode + date.day;
        String status;
        String? checkIn;
        String? checkOut;
        int? lateMinutes;

        if (hash % 10 == 0) {
          status = 'Ausente';
        } else if (hash % 7 == 0) {
          status = 'Justificado';
        } else if (hash % 5 == 0) {
          status = 'Atrasado';
          checkIn = '08:15';
          checkOut = '17:30';
          lateMinutes = 15;
        } else {
          status = 'Presente';
          checkIn = '08:00';
          checkOut = '17:30';
        }

        records.add(
          Attendance(
            id: 'mock-${employee.id}-$dateStr',
            employeeId: employee.id,
            date: dateStr,
            checkIn: checkIn,
            checkOut: checkOut,
            lateMinutes: lateMinutes,
            status: status,
            authMethod: hash % 2 == 0 ? 'qr' : 'code',
          ),
        );
      }

      result[employee.id] = records;
    }

    return result;
  }
}