import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository(),
        super(const AuthInitial());

  void togglePasswordVisibility() {
    final newVisibility = !state.isPasswordVisible;
    if (state is AuthInitial) {
      emit(AuthInitial(isPasswordVisible: newVisibility));
    } else if (state is AuthUnauthenticated) {
      emit(AuthUnauthenticated(isPasswordVisible: newVisibility));
    } else if (state is AuthError) {
      emit(AuthError((state as AuthError).message, isPasswordVisible: newVisibility));
    } else if (state is AuthAuthenticated) {
      emit(AuthAuthenticated((state as AuthAuthenticated).employee, isPasswordVisible: newVisibility));
    }
  }

  Future<void> checkAuthStatus() async {
    emit(AuthLoading(isPasswordVisible: state.isPasswordVisible));
    try {
      final employee = await _authRepository.getLoggedInEmployee();
      if (employee != null) {
        emit(AuthAuthenticated(employee, isPasswordVisible: state.isPasswordVisible));
      } else {
        emit(AuthUnauthenticated(isPasswordVisible: state.isPasswordVisible));
      }
    } catch (_) {
      emit(AuthUnauthenticated(isPasswordVisible: state.isPasswordVisible));
    }
  }

  Future<void> login(String identifier, String password) async {
    if (identifier.trim().isEmpty || password.trim().isEmpty) {
      emit(AuthError('Please enter both Employee ID/Email and password.',
          isPasswordVisible: state.isPasswordVisible));
      return;
    }

    emit(AuthLoading(isPasswordVisible: state.isPasswordVisible));
    try {
      final employee = await _authRepository.login(identifier, password);
      emit(AuthAuthenticated(employee, isPasswordVisible: state.isPasswordVisible));
    } catch (e) {
      emit(AuthError(
        e.toString().replaceFirst('Exception: ', ''),
        isPasswordVisible: state.isPasswordVisible,
      ));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading(isPasswordVisible: state.isPasswordVisible));
    try {
      await _authRepository.logout();
      emit(const AuthUnauthenticated());
    } catch (_) {
      emit(const AuthError('Logout failed. Please try again.'));
    }
  }
}
