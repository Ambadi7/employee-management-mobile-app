import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../utils/app_helpers.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  Color get _color {
    switch (status) {
      case 'checked_in': return AppColors.checkedIn;
      case 'checked_out': return AppColors.checkedOut;
      default: return AppColors.notCheckedIn;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.5)),
      ),
      child: Text(
        AppHelpers.getAttendanceStatusLabel(status),
        style: TextStyle(color: _color, fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }
}
