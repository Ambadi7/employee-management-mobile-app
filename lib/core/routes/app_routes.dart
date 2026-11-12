import 'package:flutter/material.dart';
import '../../features/auth/views/login_view.dart';
import '../../features/home/views/home_view.dart';
import '../../features/attendance/views/attendance_history_view.dart';
import '../../features/attendance/views/attendance_details_view.dart';
import '../../features/qr_scanner/views/qr_scanner_view.dart';
import '../../features/admin/views/admin_dashboard_view.dart';
import '../../features/admin/views/employee_attendance_view.dart';
import '../../features/qr_generator/views/qr_generator_view.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String attendanceHistory = '/attendance-history';
  static const String attendanceDetails = '/attendance-details';
  static const String qrScanner = '/qr-scanner';
  static const String adminDashboard = '/admin-dashboard';
  static const String employeeAttendance = '/employee-attendance';
  static const String qrGenerator = '/qr-generator';

  static Map<String, WidgetBuilder> get routes => {
    login: (_) => const LoginView(),
    home: (_) => const HomeView(),
    attendanceHistory: (_) => const AttendanceHistoryView(),
    attendanceDetails: (_) => const AttendanceDetailsView(),
    qrScanner: (_) => const QrScannerView(),
    adminDashboard: (_) => const AdminDashboardView(),
    employeeAttendance: (_) => const EmployeeAttendanceView(),
    qrGenerator: (_) => const QrGeneratorView(),
  };
}
