import 'package:equatable/equatable.dart';
import '../../../data/models/attendance_model.dart';
import '../../../data/models/employee_model.dart';

abstract class AdminState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminDashboardLoaded extends AdminState {
  final List<EmployeeModel> employees;
  final List<AttendanceModel> todayAttendance;
  final int totalEmployeesCount;
  final int presentCount;
  final int checkedOutCount;
  final int notCheckedInCount;

  AdminDashboardLoaded({
    required this.employees,
    required this.todayAttendance,
    required this.totalEmployeesCount,
    required this.presentCount,
    required this.checkedOutCount,
    required this.notCheckedInCount,
  });

  @override
  List<Object?> get props => [
        employees,
        todayAttendance,
        totalEmployeesCount,
        presentCount,
        checkedOutCount,
        notCheckedInCount,
      ];
}

class AdminAllAttendanceLoaded extends AdminState {
  final List<AttendanceModel> records;

  AdminAllAttendanceLoaded(this.records);

  @override
  List<Object?> get props => [records];
}

class AdminError extends AdminState {
  final String message;

  AdminError(this.message);

  @override
  List<Object?> get props => [message];
}
