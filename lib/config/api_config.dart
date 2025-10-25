class ApiConfig {
  // Base URL da API
  static const String baseUrl = 'http://localhost:3000';

  // Timeout para conexões
  static const Duration connectionTimeout = Duration(seconds: 10);

  // Endpoints da API
  static const String employees = '/api/employees';
  static const String attendance = '/api/attendance';
  static const String attendanceRegister = '/api/attendance/register';
  static const String workSchedule = '/api/work-schedule';
  static const String departments = '/api/departments';

  // Endpoints de autenticação (se existirem)
  static const String login = '/api/auth/login';
  static const String logout = '/api/auth/logout';
}