import 'package:equatable/equatable.dart';
import '../../../data/models/employee_model.dart';

abstract class AuthState extends Equatable {
  final bool isPasswordVisible;

  const AuthState({this.isPasswordVisible = false});

  @override
  List<Object?> get props => [isPasswordVisible];
}

class AuthInitial extends AuthState {
  const AuthInitial({super.isPasswordVisible});
}

class AuthLoading extends AuthState {
  const AuthLoading({super.isPasswordVisible});
}

class AuthAuthenticated extends AuthState {
  final EmployeeModel employee;

  const AuthAuthenticated(this.employee, {super.isPasswordVisible});

  @override
  List<Object?> get props => [employee, isPasswordVisible];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated({super.isPasswordVisible});
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message, {super.isPasswordVisible});

  @override
  List<Object?> get props => [message, isPasswordVisible];
}
