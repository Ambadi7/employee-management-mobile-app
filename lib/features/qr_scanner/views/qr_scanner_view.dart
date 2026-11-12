import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../cubit/qr_scanner_cubit.dart';
import '../cubit/qr_scanner_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_helpers.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../data/models/attendance_model.dart';

class QrScannerView extends StatelessWidget {
  const QrScannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QrScannerCubit()..startScanning(),
      child: const _QrScannerBody(),
    );
  }
}

class _QrScannerBody extends StatefulWidget {
  const _QrScannerBody();

  @override
  State<_QrScannerBody> createState() => _QrScannerBodyState();
}

class _QrScannerBodyState extends State<_QrScannerBody> {
  late final MobileScannerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QrScannerCubit, QrScannerState>(
      listener: (context, state) {
        if (state is QrScannerSuccess || state is QrScannerError) {
          _controller.stop();
        }
      },
      builder: (context, state) {
        if (state is QrScannerProcessing) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(title: const Text('Processing...')),
            body: LoadingWidget(message: state.statusMessage),
          );
        }

        if (state is QrScannerSuccess) {
          return _buildSuccessScreen(context, state);
        }

        if (state is QrScannerError) {
          return _buildErrorScreen(context, state.message);
        }

        return _buildCameraScanner(context, state);
      },
    );
  }

  Widget _buildCameraScanner(BuildContext context, QrScannerState state) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(state.isTorchOn ? Icons.flash_on : Icons.flash_off),
            tooltip: 'Toggle Flashlight',
            onPressed: () {
              _controller.toggleTorch();
              context.read<QrScannerCubit>().toggleTorch();
            },
          ),
          IconButton(
            icon: const Icon(Icons.keyboard),
            tooltip: 'Manual QR Input (Demo/Emulator)',
            onPressed: () => _showManualInputDialog(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final barcode = capture.barcodes.firstOrNull;
              final raw = barcode?.rawValue;
              if (raw != null && raw.isNotEmpty) {
                context.read<QrScannerCubit>().scanQr(raw);
              }
            },
          ),
          _buildScanTargetOverlay(),
        ],
      ),
    );
  }

  Widget _buildScanTargetOverlay() {
    return Column(
      children: [
        const Spacer(flex: 2),
        Center(
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2.5),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppColors.primaryLight, width: 5),
                        left: BorderSide(color: AppColors.primaryLight, width: 5),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppColors.primaryLight, width: 5),
                        right: BorderSide(color: AppColors.primaryLight, width: 5),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.primaryLight, width: 5),
                        left: BorderSide(color: AppColors.primaryLight, width: 5),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.primaryLight, width: 5),
                        right: BorderSide(color: AppColors.primaryLight, width: 5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Align attendance QR inside frame',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Spacer(flex: 3),
      ],
    );
  }

  Widget _buildSuccessScreen(BuildContext context, QrScannerSuccess state) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  state.isCheckIn ? Icons.login : Icons.logout,
                  size: 52,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                state.isCheckIn ? 'Check-in Successful!' : 'Check-out Successful!',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              _buildAttendanceCard(state.attendance),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to Dashboard'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceCard(AttendanceModel attendance) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _rowItem('Employee', attendance.employeeName),
            const Divider(),
            _rowItem('Employee ID', attendance.employeeId),
            const Divider(),
            _rowItem('Date', attendance.date),
            if (attendance.checkInTime != null) ...[
              const Divider(),
              _rowItem(
                'Check-in Time',
                AppHelpers.formatTime(DateTime.parse(attendance.checkInTime!)),
              ),
            ],
            if (attendance.checkOutTime != null) ...[
              const Divider(),
              _rowItem(
                'Check-out Time',
                AppHelpers.formatTime(DateTime.parse(attendance.checkOutTime!)),
              ),
            ],
            if (attendance.checkInLatitude != null) ...[
              const Divider(),
              _rowItem(
                'GPS Coordinates',
                AppHelpers.formatCoordinates(
                  attendance.checkInLatitude,
                  attendance.checkInLongitude,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _rowItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, String message) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline, size: 50, color: AppColors.error),
              ),
              const SizedBox(height: 24),
              const Text(
                'Attendance Failed',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Scan Again'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        _controller.start();
                        context.read<QrScannerCubit>().startScanning();
                      },
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

  void _showManualInputDialog(BuildContext context) {
    final inputController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Manual QR Code Input'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Paste or enter the QR JSON data (useful for desktop / emulators without cameras):',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: inputController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: '{"sessionId":"...","generatedAt":"...","expiresAt":"..."}',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = inputController.text.trim();
              Navigator.pop(dialogCtx);
              if (text.isNotEmpty) {
                context.read<QrScannerCubit>().scanQr(text);
              }
            },
            child: const Text('Process QR'),
          ),
        ],
      ),
    );
  }
}
