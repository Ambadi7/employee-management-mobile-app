import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/loading_widget.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(),
      child: const _LoginFormWrapper(),
    );
  }
}

class _LoginFormWrapper extends StatelessWidget {
  const _LoginFormWrapper();

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final identifierController = TextEditingController();
    final passwordController = TextEditingController();

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          if (state.employee.isAdmin) {
            Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
          } else {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          }
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: state is AuthLoading
                ? const LoadingWidget(message: 'Signing in...')
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 32),
                        _buildHeader(),
                        const SizedBox(height: 40),
                        _buildForm(
                          context,
                          formKey,
                          identifierController,
                          passwordController,
                          state,
                        ),
                        const SizedBox(height: 28),
                        _buildCredentialsCard(
                          identifierController,
                          passwordController,
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.qr_code_scanner, size: 48, color: Colors.white),
        ),
        const SizedBox(height: 20),
        const Text(
          'Smart Attendance',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'QR & GPS Attendance System',
          style: TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildForm(
    BuildContext context,
    GlobalKey<FormState> formKey,
    TextEditingController identifierController,
    TextEditingController passwordController,
    AuthState state,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: identifierController,
                decoration: const InputDecoration(
                  labelText: 'Employee ID or Email',
                  hintText: 'EMP001 or john@test.com',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter Employee ID or Email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                obscureText: !state.isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      state.isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      context.read<AuthCubit>().togglePasswordVisibility();
                    },
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    context.read<AuthCubit>().login(
                          identifierController.text,
                          passwordController.text,
                        );
                  }
                },
                child: const Text('Sign In', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCredentialsCard(
    TextEditingController identifierController,
    TextEditingController passwordController,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Quick Demo Accounts (Tap to fill)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
            const Divider(height: 18),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                identifierController.text = 'ADM001';
                passwordController.text = 'admin123';
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('👑 Admin:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                    Text('ADM001 / admin123', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                identifierController.text = 'EMP001';
                passwordController.text = 'employee123';
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('👤 Employee:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                    Text('EMP001 / employee123', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
