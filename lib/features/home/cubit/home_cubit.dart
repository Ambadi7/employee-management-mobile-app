import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/attendance_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final AuthRepository _authRepository;
  final AttendanceRepository _attendanceRepository;

  HomeCubit({
    AuthRepository? authRepository,
    AttendanceRepository? attendanceRepository,
  })  : _authRepository = authRepository ?? AuthRepository(),
        _attendanceRepository = attendanceRepository ?? AttendanceRepository(),
        super(HomeInitial());

  Future<void> loadHome() async {
    emit(HomeLoading());
    try {
      final employee = await _authRepository.getLoggedInEmployee();
      if (employee == null) {
        emit(HomeError('Session expired. Please login again.'));
        return;
      }
      final todayAttendance =
          await _attendanceRepository.getTodayAttendance(employee.employeeId);
      emit(HomeLoaded(employee: employee, todayAttendance: todayAttendance));
    } catch (e) {
      emit(HomeError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
