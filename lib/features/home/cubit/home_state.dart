import 'package:equatable/equatable.dart';
import '../../../data/models/employee_model.dart';
import '../../../data/models/attendance_model.dart';

abstract class HomeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final EmployeeModel employee;
  final AttendanceModel? todayAttendance;

  HomeLoaded({required this.employee, this.todayAttendance});

  @override
  List<Object?> get props => [employee, todayAttendance];
}

class HomeError extends HomeState {
  final String message;

  HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
