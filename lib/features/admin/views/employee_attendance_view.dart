import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/app_helpers.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/attendance_model.dart';

class EmployeeAttendanceView extends StatelessWidget {
  const EmployeeAttendanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminCubit()..loadAllAttendance(),
      child: const _EmployeeAttendanceScaffold(),
    );
  }
}

class _EmployeeAttendanceScaffold extends StatelessWidget {
  const _EmployeeAttendanceScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('All Attendance Records'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => context.read<AdminCubit>().loadAllAttendance(),
          ),
        ],
      ),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading || state is AdminInitial) {
            return const LoadingWidget(message: 'Loading attendance logs...');
          }
          if (state is AdminError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 54, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      onPressed: () => context.read<AdminCubit>().loadAllAttendance(),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state is AdminAllAttendanceLoaded) {
            final records = state.records;
            if (records.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder_open, size: 64, color: AppColors.textSecondary),
                    SizedBox(height: 16),
                    Text(
                      'No attendance records found.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => context.read<AdminCubit>().loadAllAttendance(),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: records.length,
                itemBuilder: (context, index) {
                  return _AdminRecordCard(record: records[index]);
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _AdminRecordCard extends StatelessWidget {
  final AttendanceModel record;

  const _AdminRecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          if (record.id != null) {
            Navigator.pushNamed(
              context,
              AppRoutes.attendanceDetails,
              arguments: record.id,
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.12),
                    radius: 20,
                    child: Text(
                      record.employeeName.isNotEmpty
                          ? record.employeeName[0].toUpperCase()
                          : 'E',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.employeeName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'ID: ${record.employeeId} • ${_formatDate(record.date)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(status: record.status),
                ],
              ),
              const Divider(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.login, size: 14, color: AppColors.checkedIn),
                            SizedBox(width: 4),
                            Text(
                              'Check-in',
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          record.checkInTime != null
                              ? AppHelpers.formatTime(DateTime.parse(record.checkInTime!))
                              : '--:--',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          record.checkInLatitude != null
                              ? AppHelpers.formatCoordinates(
                                  record.checkInLatitude, record.checkInLongitude)
                              : 'No GPS',
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.logout, size: 14, color: AppColors.checkedOut),
                            SizedBox(width: 4),
                            Text(
                              'Check-out',
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          record.checkOutTime != null
                              ? AppHelpers.formatTime(DateTime.parse(record.checkOutTime!))
                              : '--:--',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          record.checkOutLatitude != null
                              ? AppHelpers.formatCoordinates(
                                  record.checkOutLatitude, record.checkOutLongitude)
                              : 'No GPS',
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String date) {
    try {
      return AppHelpers.formatDate(DateTime.parse(date));
    } catch (_) {
      return date;
    }
  }
}
