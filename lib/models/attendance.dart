class Attendance {
  final String id;
  final String employeeId;
  final String date;
  final String? checkIn;
  final String? checkOut;
  final int? lateMinutes;
  final String status;
  final String authMethod;

  const Attendance({
    required this.id,
    required this.employeeId,
    required this.date,
    this.checkIn,
    this.checkOut,
    this.lateMinutes,
    required this.status,
    required this.authMethod,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id']?.toString() ?? '',
      employeeId: json['employee_id']?.toString() ?? '',
      date: json['date'] ?? '',
      checkIn: json['check_in'],
      checkOut: json['check_out'],
      lateMinutes: json['late_minutes'],
      status: json['status'] ?? 'Ausente',
      authMethod: json['auth_method'] ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'date': date,
      'check_in': checkIn,
      'check_out': checkOut,
      'late_minutes': lateMinutes,
      'status': status,
      'auth_method': authMethod,
    };
  }
}