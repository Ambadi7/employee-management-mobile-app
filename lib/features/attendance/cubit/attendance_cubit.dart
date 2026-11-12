import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/attendance_repository.dart';
import '../../../data/repositories/auth_repository.dart';
import 'attendance_state.dart';

class AttendanceCubit extends Cubit<AttendanceState> {
  final AttendanceRepository _attendanceRepository;
  final AuthRepository _authRepository;

  AttendanceCubit({
    AttendanceRepository? attendanceRepository,
    AuthRepository? authRepository,
  })  : _attendanceRepository = attendanceRepository ?? AttendanceRepository(),
        _authRepository = authRepository ?? AuthRepository(),
        super(AttendanceInitial());

  Future<void> loadAttendanceHistory() async {
    emit(AttendanceLoading());
    try {
      final employee = await _authRepository.getLoggedInEmployee();
      if (employee == null) {
        emit(AttendanceError('Session expired. Please log in again.'));
        return;
      }
      final records =
          await _attendanceRepository.getEmployeeAttendance(employee.employeeId);
      emit(AttendanceHistoryLoaded(records));
    } catch (e) {
      emit(AttendanceError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> loadAttendanceDetails(int id) async {
    emit(AttendanceLoading());
    try {
      final record = await _attendanceRepository.getAttendanceById(id);
      if (record == null) {
        emit(AttendanceError('Attendance record with ID #$id was not found.'));
        return;
      }
      emit(AttendanceDetailsLoaded(record));
    } catch (e) {
      emit(AttendanceError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
