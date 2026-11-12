import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/attendance_cubit.dart';
import '../cubit/attendance_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/app_helpers.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/attendance_model.dart';

class AttendanceHistoryView extends StatelessWidget {
  const AttendanceHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AttendanceCubit()..loadAttendanceHistory(),
      child: const _AttendanceHistoryScaffold(),
    );
  }
}

class _AttendanceHistoryScaffold extends StatelessWidget {
  const _AttendanceHistoryScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Attendance History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () =>
                context.read<AttendanceCubit>().loadAttendanceHistory(),
          ),
        ],
      ),
      body: BlocBuilder<AttendanceCubit, AttendanceState>(
        builder: (context, state) {
          if (state is AttendanceLoading || state is AttendanceInitial) {
            return const LoadingWidget(message: 'Loading attendance logs...');
          }
          if (state is AttendanceError) {
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
                      onPressed: () =>
                          context.read<AttendanceCubit>().loadAttendanceHistory(),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state is AttendanceHistoryLoaded) {
            final records = state.records;
            if (records.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_note, size: 64, color: AppColors.textSecondary),
                    SizedBox(height: 16),
                    Text(
                      'No attendance records found yet.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Scan an attendance QR code to create your first record.',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<AttendanceCubit>().loadAttendanceHistory(),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: records.length,
                itemBuilder: (context, index) {
                  return _AttendanceCardItem(record: records[index]);
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

class _AttendanceCardItem extends StatelessWidget {
  final AttendanceModel record;

  const _AttendanceCardItem({required this.record});

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(record.date),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  StatusBadge(status: record.status),
                ],
              ),
              const Divider(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _timeLocationColumn(
                      icon: Icons.login,
                      iconColor: AppColors.checkedIn,
                      label: 'Check-in',
                      time: record.checkInTime,
                      lat: record.checkInLatitude,
                      lng: record.checkInLongitude,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _timeLocationColumn(
                      icon: Icons.logout,
                      iconColor: AppColors.checkedOut,
                      label: 'Check-out',
                      time: record.checkOutTime,
                      lat: record.checkOutLatitude,
                      lng: record.checkOutLongitude,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timeLocationColumn({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String? time,
    required double? lat,
    required double? lng,
  }) {
    String formattedTime = '--:--';
    if (time != null && time.isNotEmpty) {
      try {
        formattedTime = AppHelpers.formatTime(DateTime.parse(time));
      } catch (_) {
        formattedTime = time;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: iconColor),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          formattedTime,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 2),
        Text(
          lat != null ? AppHelpers.formatCoordinates(lat, lng) : 'No GPS',
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
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
