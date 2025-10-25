class Employee {
  final String id;
  final String name;
  final String position;
  final String department;
  final String internalCode;
  final String? qrCode;

  const Employee({
    required this.id,
    required this.name,
    required this.position,
    required this.department,
    required this.internalCode,
    this.qrCode,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      position: json['position'] ?? '',
      department: json['department'] ?? '',
      internalCode: json['internal_code'] ?? '',
      qrCode: json['qr_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'position': position,
      'department': department,
      'internal_code': internalCode,
      'qr_code': qrCode,
    };
  }
}