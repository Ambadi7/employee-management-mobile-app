import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/attendance_repository.dart';
import '../../../data/repositories/auth_repository.dart';
import 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  final AttendanceRepository _attendanceRepository;
  final AuthRepository _authRepository;

  AdminCubit({
    AttendanceRepository? attendanceRepository,
    AuthRepository? authRepository,
  })  : _attendanceRepository = attendanceRepository ?? AttendanceRepository(),
        _authRepository = authRepository ?? AuthRepository(),
        super(AdminInitial());

  Future<void> loadDashboard() async {
    emit(AdminLoading());
    try {
      final currentUser = await _authRepository.getLoggedInEmployee();
      if (currentUser == null || !currentUser.isAdmin) {
        emit(AdminError('Unauthorized access. Only admin accounts can view this dashboard.'));
        return;
      }

      final employees = await _authRepository.fetchEmployees();
      final todayAttendance = await _attendanceRepository.getTodayAllAttendance();

      final presentCount =
          todayAttendance.where((a) => a.status == 'checked_in').length;
      final checkedOutCount =
          todayAttendance.where((a) => a.status == 'checked_out').length;
      final notCheckedIn = employees.length - todayAttendance.length;

      emit(AdminDashboardLoaded(
        employees: employees,
        todayAttendance: todayAttendance,
        totalEmployeesCount: employees.length,
        presentCount: presentCount,
        checkedOutCount: checkedOutCount,
        notCheckedInCount: notCheckedIn < 0 ? 0 : notCheckedIn,
      ));
    } catch (e) {
      emit(AdminError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> loadAllAttendance() async {
    emit(AdminLoading());
    try {
      final currentUser = await _authRepository.getLoggedInEmployee();
      if (currentUser == null || !currentUser.isAdmin) {
        emit(AdminError('Unauthorized access. Only admin accounts can view attendance records.'));
        return;
      }

      final records = await _attendanceRepository.getAllAttendance();
      emit(AdminAllAttendanceLoaded(records));
    } catch (e) {
      emit(AdminError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
