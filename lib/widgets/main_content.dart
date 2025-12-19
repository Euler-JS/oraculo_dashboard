import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
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

  // Form controllers for add employee
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _positionController = TextEditingController();
  final _departmentController = TextEditingController();
  final _internalCodeController = TextEditingController();
  File? _selectedImage;
  bool _isSubmitting = false;

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

  @override
  void dispose() {
    _nameController.dispose();
    _positionController.dispose();
    _departmentController.dispose();
    _internalCodeController.dispose();
    super.dispose();
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitEmployee() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione uma imagem do rosto')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Create employee
      final employee = await _attendanceService.createEmployee(
        name: _nameController.text.trim(),
        position: _positionController.text.trim(),
        department: _departmentController.text.trim(),
        internalCode: _internalCodeController.text.trim(),
      );

      // Register face
      await _attendanceService.registerFace(employee.id, _selectedImage!);

      // Clear form
      _nameController.clear();
      _positionController.clear();
      _departmentController.clear();
      _internalCodeController.clear();
      setState(() {
        _selectedImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Funcionário adicionado com sucesso!')),
      );

      // Reload employees list
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adicionar funcionário: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.activePage) {
      case 'dashboard':
        return _buildDashboardContent();
      case 'funcionarios':
        return _buildFuncionariosContent();
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
      case 'add-funcionario':
        return _buildAddFuncionarioContent();
      default:
        return _buildAttendanceContent();
    }
  }

  Widget _buildDashboardContent() {
    return const Center(
      child: Text('Dashboard Content - Overview and Statistics'),
    );
  }

  Widget _buildFuncionariosContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
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
          Text(
            'Funcionários cadastrados',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: _employees.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final employee = _employees[index];
                return ListTile(
                  leading: CircleAvatar(child: Text(employee.name.isNotEmpty ? employee.name[0] : '?')),
                  title: Text(employee.name),
                  subtitle: Text('${employee.position} • ${employee.department}'),
                  trailing: Text(employee.internalCode),
                );
              },
            ),
          ),
        ],
      ),
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

  Widget _buildAddFuncionarioContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Adicionar Novo Funcionário',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nome é obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _positionController,
              decoration: const InputDecoration(
                labelText: 'Cargo',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Cargo é obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _departmentController,
              decoration: const InputDecoration(
                labelText: 'Departamento',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Departamento é obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _internalCodeController,
              decoration: const InputDecoration(
                labelText: 'Código Interno',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Código interno é obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Foto do Rosto (obrigatória para reconhecimento facial)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo),
                  label: const Text('Selecionar Imagem'),
                ),
                const SizedBox(width: 16),
                if (_selectedImage != null)
                  const Icon(Icons.check_circle, color: Colors.green),
              ],
            ),
            if (_selectedImage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Imagem selecionada: ${_selectedImage!.path.split('/').last}'),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitEmployee,
                child: _isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text('Adicionar Funcionário'),
              ),
            ),
          ],
        ),
      ),
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