import 'dart:convert';
import 'package:equatable/equatable.dart';

class QrSessionModel extends Equatable {
  final String sessionId;
  final DateTime generatedAt;
  final DateTime expiresAt;

  const QrSessionModel({
    required this.sessionId,
    required this.generatedAt,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().toUtc().isAfter(expiresAt.toUtc());

  Duration get remainingTime {
    final now = DateTime.now().toUtc();
    final remaining = expiresAt.toUtc().difference(now);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  String toJsonString() => jsonEncode({
    'sessionId': sessionId,
    'generatedAt': generatedAt.toUtc().toIso8601String(),
    'expiresAt': expiresAt.toUtc().toIso8601String(),
  });

  factory QrSessionModel.fromJsonString(String jsonStr) {
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    return QrSessionModel(
      sessionId: map['sessionId']?.toString() ?? '',
      generatedAt: DateTime.parse(map['generatedAt'] as String),
      expiresAt: DateTime.parse(map['expiresAt'] as String),
    );
  }

  @override
  List<Object?> get props => [sessionId, generatedAt, expiresAt];
}
