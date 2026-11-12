import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/attendance_cubit.dart';
import '../cubit/attendance_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_helpers.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/attendance_model.dart';

class AttendanceDetailsView extends StatelessWidget {
  const AttendanceDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final recordId = ModalRoute.of(context)?.settings.arguments as int?;
    return BlocProvider(
      create: (_) => AttendanceCubit()..loadAttendanceDetails(recordId ?? 0),
      child: const _AttendanceDetailsScaffold(),
    );
  }
}

class _AttendanceDetailsScaffold extends StatelessWidget {
  const _AttendanceDetailsScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Attendance Details'),
      ),
      body: BlocBuilder<AttendanceCubit, AttendanceState>(
        builder: (context, state) {
          if (state is AttendanceLoading || state is AttendanceInitial) {
            return const LoadingWidget(message: 'Loading details...');
          }
          if (state is AttendanceError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
            );
          }
          if (state is AttendanceDetailsLoaded) {
            return _buildContent(context, state.record);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, AttendanceModel record) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSummaryCard(record),
          const SizedBox(height: 16),
          _buildCheckInCard(record),
          const SizedBox(height: 16),
          if (record.checkOutTime != null) _buildCheckOutCard(record),
          if (record.checkInTime != null && record.checkOutTime != null) ...[
            const SizedBox(height: 16),
            _buildDurationCard(record),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCard(AttendanceModel record) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.employeeName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${record.employeeId}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: record.status),
              ],
            ),
            const Divider(height: 24),
            _infoRow(
              Icons.calendar_today,
              'Date',
              _formatDate(record.date),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckInCard(AttendanceModel record) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.login, color: AppColors.checkedIn, size: 22),
                SizedBox(width: 8),
                Text(
                  'Check-In Record',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 20),
            if (record.checkInTime != null) ...[
              _infoRow(
                Icons.access_time,
                'Timestamp',
                AppHelpers.formatDateTime(DateTime.parse(record.checkInTime!)),
              ),
              const SizedBox(height: 10),
            ],
            _infoRow(
              Icons.location_on,
              'GPS Coordinates',
              AppHelpers.formatCoordinates(
                record.checkInLatitude,
                record.checkInLongitude,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckOutCard(AttendanceModel record) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.logout, color: AppColors.checkedOut, size: 22),
                SizedBox(width: 8),
                Text(
                  'Check-Out Record',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 20),
            if (record.checkOutTime != null) ...[
              _infoRow(
                Icons.access_time,
                'Timestamp',
                AppHelpers.formatDateTime(DateTime.parse(record.checkOutTime!)),
              ),
              const SizedBox(height: 10),
            ],
            _infoRow(
              Icons.location_on,
              'GPS Coordinates',
              AppHelpers.formatCoordinates(
                record.checkOutLatitude,
                record.checkOutLongitude,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationCard(AttendanceModel record) {
    String durationText = '--';
    try {
      final inTime = DateTime.parse(record.checkInTime!);
      final outTime = DateTime.parse(record.checkOutTime!);
      final diff = outTime.difference(inTime);
      final hours = diff.inHours;
      final minutes = diff.inMinutes.remainder(60);
      durationText = '${hours}h ${minutes}m';
    } catch (_) {}

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.timelapse, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Working Hours',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
            const Spacer(),
            Text(
              durationText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
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
