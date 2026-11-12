import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/app_helpers.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/status_badge.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import '../../../data/models/attendance_model.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AdminCubit()..loadDashboard()),
        BlocProvider(create: (_) => AuthCubit()),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.pushNamedAndRemoveUntil(
                context, AppRoutes.login, (route) => false);
          }
        },
        child: const _AdminDashboardScaffold(),
      ),
    );
  }
}

class _AdminDashboardScaffold extends StatelessWidget {
  const _AdminDashboardScaffold();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Admin Dashboard'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
                onPressed: () => context.read<AdminCubit>().loadDashboard(),
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
                onPressed: () => _confirmLogout(context),
              ),
            ],
          ),
          body: _buildBody(context, state),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              await Navigator.pushNamed(context, AppRoutes.qrGenerator);
              if (context.mounted) {
                context.read<AdminCubit>().loadDashboard();
              }
            },
            icon: const Icon(Icons.qr_code),
            label: const Text('Generate QR'),
            backgroundColor: AppColors.primary,
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, AdminState state) {
    if (state is AdminLoading || state is AdminInitial) {
      return const LoadingWidget(message: 'Loading management dashboard...');
    }
    if (state is AdminError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 54, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                onPressed: () => context.read<AdminCubit>().loadDashboard(),
              ),
            ],
          ),
        ),
      );
    }
    if (state is AdminDashboardLoaded) {
      return RefreshIndicator(
        onRefresh: () async => context.read<AdminCubit>().loadDashboard(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatsGrid(state),
              const SizedBox(height: 20),
              _buildQuickActions(context),
              const SizedBox(height: 20),
              _buildTodayAttendanceList(context, state),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildStatsGrid(AdminDashboardLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Today's Overview",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              AppHelpers.formatDate(DateTime.now()),
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _statCard(
                title: 'Total Staff',
                count: '${state.totalEmployeesCount}',
                icon: Icons.groups,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _statCard(
                title: 'Present',
                count: '${state.presentCount}',
                icon: Icons.check_circle_outline,
                color: AppColors.checkedIn,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _statCard(
                title: 'Checked Out',
                count: '${state.checkedOutCount}',
                icon: Icons.exit_to_app,
                color: AppColors.checkedOut,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _statCard(
                title: 'Not Checked In',
                count: '${state.notCheckedInCount}',
                icon: Icons.highlight_off,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                await Navigator.pushNamed(context, AppRoutes.qrGenerator);
                if (context.mounted) {
                  context.read<AdminCubit>().loadDashboard();
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.qr_code, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Generate QR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('2-min session', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.employeeAttendance);
              },
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.history, color: AppColors.accent, size: 22),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('All Records', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('Full audit history', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTodayAttendanceList(BuildContext context, AdminDashboardLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Today's Attendance Logs",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '${state.todayAttendance.length} records',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (state.todayAttendance.isEmpty)
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.inbox_outlined, size: 48, color: AppColors.textSecondary),
                    SizedBox(height: 12),
                    Text(
                      'No employee attendance records for today yet.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...state.todayAttendance.map((attendance) {
            return _buildAttendanceListItem(context, attendance);
          }),
      ],
    );
  }

  Widget _buildAttendanceListItem(BuildContext context, AttendanceModel attendance) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.12),
          child: Text(
            attendance.employeeName.isNotEmpty ? attendance.employeeName[0].toUpperCase() : 'E',
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
        ),
        title: Text(
          attendance.employeeName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text('ID: ${attendance.employeeId}', style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 2),
            Row(
              children: [
                if (attendance.checkInTime != null) ...[
                  const Icon(Icons.login, size: 12, color: AppColors.checkedIn),
                  const SizedBox(width: 4),
                  Text(
                    AppHelpers.formatTime(DateTime.parse(attendance.checkInTime!)),
                    style: const TextStyle(fontSize: 11, color: AppColors.checkedIn, fontWeight: FontWeight.w600),
                  ),
                ],
                if (attendance.checkOutTime != null) ...[
                  const SizedBox(width: 10),
                  const Icon(Icons.logout, size: 12, color: AppColors.checkedOut),
                  const SizedBox(width: 4),
                  Text(
                    AppHelpers.formatTime(DateTime.parse(attendance.checkOutTime!)),
                    style: const TextStyle(fontSize: 11, color: AppColors.checkedOut, fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: StatusBadge(status: attendance.status),
        onTap: () {
          if (attendance.id != null) {
            Navigator.pushNamed(
              context,
              AppRoutes.attendanceDetails,
              arguments: attendance.id,
            );
          }
        },
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out of the Admin portal?'),
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
