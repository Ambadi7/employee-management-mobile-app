import 'package:shared_preferences/shared_preferences.dart';
import '../models/employee_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/api_service.dart';

class AuthRepository {
  static final List<EmployeeModel> _dummyEmployees = [
    const EmployeeModel(
      employeeId: AppConstants.adminId,
      name: AppConstants.adminName,
      email: AppConstants.adminEmail,
      password: AppConstants.adminPassword,
      role: 'admin',
    ),
    const EmployeeModel(
      employeeId: AppConstants.empId,
      name: AppConstants.empName,
      email: AppConstants.empEmail,
      password: AppConstants.empPassword,
      role: 'employee',
    ),
  ];

  Future<EmployeeModel> login(String identifier, String password) async {
    // Attempt mock Dio API call if needed, falling back cleanly without crashing
    try {
      // Mock Dio endpoint call (demonstrates Dio integration per requirement #12)
      await ApiService.post('/auth/login', data: {
        'identifier': identifier,
        'password': password,
      }).timeout(const Duration(milliseconds: 600));
    } catch (_) {
      // Expected since real backend is not provided; fallback to local dummy store
    }

    await Future.delayed(const Duration(milliseconds: 300));
    try {
      final trimmedId = identifier.trim().toLowerCase();
      final employee = _dummyEmployees.firstWhere(
        (e) =>
            (e.employeeId.toLowerCase() == trimmedId || e.email.toLowerCase() == trimmedId) &&
            e.password == password.trim(),
      );
      await saveSession(employee);
      return employee;
    } catch (_) {
      throw Exception('Invalid credentials. Please verify your ID/Email and password.');
    }
  }

  Future<void> saveSession(EmployeeModel employee) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyIsLoggedIn, true);
    await prefs.setString(AppConstants.keyEmployeeId, employee.employeeId);
    await prefs.setString(AppConstants.keyEmployeeName, employee.name);
    await prefs.setString(AppConstants.keyEmployeeEmail, employee.email);
    await prefs.setString(AppConstants.keyEmployeeRole, employee.role);
  }

  Future<EmployeeModel?> getLoggedInEmployee() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
    if (!isLoggedIn) return null;
    return EmployeeModel(
      employeeId: prefs.getString(AppConstants.keyEmployeeId) ?? '',
      name: prefs.getString(AppConstants.keyEmployeeName) ?? '',
      email: prefs.getString(AppConstants.keyEmployeeEmail) ?? '',
      password: '',
      role: prefs.getString(AppConstants.keyEmployeeRole) ?? 'employee',
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  List<EmployeeModel> getAllEmployees() {
    return _dummyEmployees.map((e) => EmployeeModel(
      employeeId: e.employeeId,
      name: e.name,
      email: e.email,
      password: '',
      role: e.role,
    )).toList();
  }

  Future<List<EmployeeModel>> fetchEmployees() async {
    try {
      await ApiService.get('/employees').timeout(const Duration(milliseconds: 600));
    } catch (_) {}
    return getAllEmployees();
  }
}
