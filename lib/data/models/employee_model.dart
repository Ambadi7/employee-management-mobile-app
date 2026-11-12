import 'package:equatable/equatable.dart';

class EmployeeModel extends Equatable {
  final String employeeId;
  final String name;
  final String email;
  final String password;
  final String role;

  const EmployeeModel({
    required this.employeeId,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  bool get isAdmin => role.toLowerCase() == 'admin';

  Map<String, dynamic> toMap() => {
    'employeeId': employeeId,
    'name': name,
    'email': email,
    'password': password,
    'role': role,
  };

  factory EmployeeModel.fromMap(Map<String, dynamic> map) => EmployeeModel(
    employeeId: map['employeeId'] ?? '',
    name: map['name'] ?? '',
    email: map['email'] ?? '',
    password: map['password'] ?? '',
    role: map['role'] ?? 'employee',
  );

  @override
  List<Object?> get props => [employeeId, name, email, role];
}
