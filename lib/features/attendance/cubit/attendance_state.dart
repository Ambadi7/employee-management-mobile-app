import 'package:equatable/equatable.dart';
import '../../../data/models/attendance_model.dart';

abstract class AttendanceState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceHistoryLoaded extends AttendanceState {
  final List<AttendanceModel> records;

  AttendanceHistoryLoaded(this.records);

  @override
  List<Object?> get props => [records];
}

class AttendanceDetailsLoaded extends AttendanceState {
  final AttendanceModel record;

  AttendanceDetailsLoaded(this.record);

  @override
  List<Object?> get props => [record];
}

class AttendanceError extends AttendanceState {
  final String message;

  AttendanceError(this.message);

  @override
  List<Object?> get props => [message];
}
