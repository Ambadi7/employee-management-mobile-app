import 'package:equatable/equatable.dart';

class AttendanceModel extends Equatable {
  final int? id;
  final String employeeId;
  final String employeeName;
  final String date;
  final String? checkInTime;
  final String? checkOutTime;
  final double? checkInLatitude;
  final double? checkInLongitude;
  final double? checkOutLatitude;
  final double? checkOutLongitude;
  final String status;

  const AttendanceModel({
    this.id,
    required this.employeeId,
    required this.employeeName,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    this.checkInLatitude,
    this.checkInLongitude,
    this.checkOutLatitude,
    this.checkOutLongitude,
    this.status = 'not_checked_in',
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'employeeId': employeeId,
    'employeeName': employeeName,
    'date': date,
    'checkInTime': checkInTime,
    'checkOutTime': checkOutTime,
    'checkInLatitude': checkInLatitude,
    'checkInLongitude': checkInLongitude,
    'checkOutLatitude': checkOutLatitude,
    'checkOutLongitude': checkOutLongitude,
    'status': status,
  };

  factory AttendanceModel.fromMap(Map<String, dynamic> map) => AttendanceModel(
    id: map['id'] as int?,
    employeeId: map['employeeId']?.toString() ?? '',
    employeeName: map['employeeName']?.toString() ?? '',
    date: map['date']?.toString() ?? '',
    checkInTime: map['checkInTime']?.toString(),
    checkOutTime: map['checkOutTime']?.toString(),
    checkInLatitude: (map['checkInLatitude'] as num?)?.toDouble(),
    checkInLongitude: (map['checkInLongitude'] as num?)?.toDouble(),
    checkOutLatitude: (map['checkOutLatitude'] as num?)?.toDouble(),
    checkOutLongitude: (map['checkOutLongitude'] as num?)?.toDouble(),
    status: map['status']?.toString() ?? 'not_checked_in',
  );

  AttendanceModel copyWith({
    int? id,
    String? employeeId,
    String? employeeName,
    String? date,
    String? checkInTime,
    String? checkOutTime,
    double? checkInLatitude,
    double? checkInLongitude,
    double? checkOutLatitude,
    double? checkOutLongitude,
    String? status,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      date: date ?? this.date,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      checkInLatitude: checkInLatitude ?? this.checkInLatitude,
      checkInLongitude: checkInLongitude ?? this.checkInLongitude,
      checkOutLatitude: checkOutLatitude ?? this.checkOutLatitude,
      checkOutLongitude: checkOutLongitude ?? this.checkOutLongitude,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
    id,
    employeeId,
    employeeName,
    date,
    checkInTime,
    checkOutTime,
    checkInLatitude,
    checkInLongitude,
    checkOutLatitude,
    checkOutLongitude,
    status,
  ];
}
