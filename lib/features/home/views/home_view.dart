import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/app_helpers.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/status_badge.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => HomeCubit()..loadHome()),
        BlocProvider(create: (_) => AuthCubit()),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.pushNamedAndRemoveUntil(
                context, AppRoutes.login, (route) => false);
          }
        },
        child: const _HomeScaffold(),
      ),
    );
  }
}

class _HomeScaffold extends StatelessWidget {
  const _HomeScaffold();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Employee Dashboard'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
                onPressed: () => context.read<HomeCubit>().loadHome(),
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
                onPressed: () => _confirmLogout(context),
              ),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, HomeState state) {
    if (state is HomeLoading || state is HomeInitial) {
      return const LoadingWidget(message: 'Loading your dashboard...');
    }
    if (state is HomeError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 56, color: AppColors.error),
              const SizedBox(height: 16),
              Text(state.message, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                onPressed: () => context.read<HomeCubit>().loadHome(),
              ),
            ],
          ),
        ),
      );
    }
    if (state is HomeLoaded) {
      return RefreshIndicator(
        onRefresh: () async => context.read<HomeCubit>().loadHome(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfileCard(state),
              const SizedBox(height: 16),
              _buildAttendanceStatusCard(state),
              const SizedBox(height: 20),
              _buildQuickActions(context),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildProfileCard(HomeLoaded state) {
    final employee = state.employee;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.primary,
              child: Text(
                employee.name.isNotEmpty ? employee.name[0].toUpperCase() : 'E',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          employee.employeeId,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        employee.role.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        AppHelpers.formatDate(DateTime.now()),
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceStatusCard(HomeLoaded state) {
    final attendance = state.todayAttendance;
    final status = attendance?.status ?? 'not_checked_in';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Today's Attendance",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                StatusBadge(status: status),
              ],
            ),
            const Divider(height: 24),
            _buildTimeRow(
              icon: Icons.login,
              iconColor: AppColors.checkedIn,
              title: 'Check-in Time',
              timeString: attendance?.checkInTime,
            ),
            const SizedBox(height: 14),
            _buildTimeRow(
              icon: Icons.logout,
              iconColor: AppColors.checkedOut,
              title: 'Check-out Time',
              timeString: attendance?.checkOutTime,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String? timeString,
  }) {
    String formattedTime = '--:--';
    if (timeString != null && timeString.isNotEmpty) {
      try {
        formattedTime = AppHelpers.formatTime(DateTime.parse(timeString));
      } catch (_) {
        formattedTime = timeString;
      }
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const Spacer(),
        Text(
          formattedTime,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.qr_code_scanner, color: AppColors.primary, size: 26),
            ),
            title: const Text(
              'Scan QR Code',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: const Text('Scan dynamic QR to mark attendance with GPS'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
            onTap: () async {
              await Navigator.pushNamed(context, AppRoutes.qrScanner);
              if (context.mounted) {
                context.read<HomeCubit>().loadHome();
              }
            },
          ),
        ),
        const SizedBox(height: 10),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.history, color: AppColors.accent, size: 26),
            ),
            title: const Text(
              'Attendance History',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: const Text('View your past attendance logs & GPS details'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.attendanceHistory);
            },
          ),
        ),
      ],
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out of your session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<AuthCubit>().logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
