import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../cubit/qr_generator_cubit.dart';
import '../cubit/qr_generator_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/loading_widget.dart';

class QrGeneratorView extends StatelessWidget {
  const QrGeneratorView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QrGeneratorCubit()..generateQr(),
      child: const _QrGeneratorScaffold(),
    );
  }
}

class _QrGeneratorScaffold extends StatelessWidget {
  const _QrGeneratorScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Attendance QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Generate New QR',
            onPressed: () => context.read<QrGeneratorCubit>().generateQr(),
          ),
        ],
      ),
      body: BlocBuilder<QrGeneratorCubit, QrGeneratorState>(
        builder: (context, state) {
          if (state is QrGeneratorLoading) {
            return const LoadingWidget(message: 'Generating new QR Code...');
          }
          if (state is QrGeneratorActive) {
            return _buildActiveView(context, state);
          }
          if (state is QrGeneratorExpired) {
            return _buildExpiredView(context, state.sessionId);
          }
          return _buildInitialView(context);
        },
      ),
    );
  }

  Widget _buildInitialView(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.qr_code),
        label: const Text('Generate QR Code'),
        onPressed: () => context.read<QrGeneratorCubit>().generateQr(),
      ),
    );
  }

  Widget _buildActiveView(BuildContext context, QrGeneratorActive state) {
    final remaining = state.remainingTime;
    const totalSeconds = 120;
    final remainingSeconds = remaining.inSeconds;
    final progress = (remainingSeconds / totalSeconds).clamp(0.0, 1.0);
    final isWarning = remainingSeconds <= 30;

    final minutesStr = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secondsStr = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, size: 14, color: AppColors.success),
                            SizedBox(width: 4),
                            Text(
                              'ACTIVE SESSION',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Scan for Attendance',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Point employee device camera at this QR code',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isWarning ? AppColors.warning : AppColors.primary,
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: QrImageView(
                      data: state.session.toJsonString(),
                      version: QrVersions.auto,
                      size: 210,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Countdown timer
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isWarning
                          ? AppColors.error.withOpacity(0.08)
                          : AppColors.primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 20,
                              color: isWarning ? AppColors.error : AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Expires in: $minutesStr:$secondsStr',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isWarning ? AppColors.error : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isWarning ? AppColors.error : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Session ID: ${state.session.sessionId}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Generate New QR Code'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () => context.read<QrGeneratorCubit>().generateQr(),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiredView(BuildContext context, String sessionId) {
    return Center(
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
              child: const Icon(Icons.timer_off, size: 44, color: AppColors.error),
            ),
            const SizedBox(height: 20),
            const Text(
              'QR Code Expired',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'This attendance QR code session has expired.\nPlease generate a new QR code to continue.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Text(
              'Expired Session: $sessionId',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Generate New QR Code'),
              onPressed: () => context.read<QrGeneratorCubit>().generateQr(),
            ),
          ],
        ),
      ),
    );
  }
}
