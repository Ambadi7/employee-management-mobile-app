import 'package:sqflite/sqflite.dart';
import '../models/attendance_model.dart';
import '../../core/services/database_service.dart';
import '../../core/services/api_service.dart';

class AttendanceRepository {
  Future<Database> get _db async => DatabaseService.database;

  String getTodayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<AttendanceModel?> getTodayAttendance(String employeeId) async {
    final db = await _db;
    final today = getTodayDateString();
    final results = await db.query(
      'attendance',
      where: 'employeeId = ? AND date = ?',
      whereArgs: [employeeId, today],
    );
    if (results.isEmpty) return null;
    return AttendanceModel.fromMap(results.first);
  }

  Future<List<AttendanceModel>> getEmployeeAttendance(String employeeId) async {
    final db = await _db;
    final results = await db.query(
      'attendance',
      where: 'employeeId = ?',
      whereArgs: [employeeId],
      orderBy: 'date DESC, id DESC',
    );
    return results.map(AttendanceModel.fromMap).toList();
  }

  Future<List<AttendanceModel>> getAllAttendance() async {
    final db = await _db;
    final results = await db.query(
      'attendance',
      orderBy: 'date DESC, id DESC',
    );
    return results.map(AttendanceModel.fromMap).toList();
  }

  Future<List<AttendanceModel>> getTodayAllAttendance() async {
    final db = await _db;
    final today = getTodayDateString();
    final results = await db.query(
      'attendance',
      where: 'date = ?',
      whereArgs: [today],
      orderBy: 'id DESC',
    );
    return results.map(AttendanceModel.fromMap).toList();
  }

  Future<AttendanceModel> checkIn({
    required String employeeId,
    required String employeeName,
    required String checkInTime,
    required double latitude,
    required double longitude,
  }) async {
    final db = await _db;
    final today = getTodayDateString();

    final existing = await getTodayAttendance(employeeId);
    if (existing != null) {
      throw Exception('Already checked in for today ($today). Duplicate check-in is not allowed.');
    }

    final record = AttendanceModel(
      employeeId: employeeId,
      employeeName: employeeName,
      date: today,
      checkInTime: checkInTime,
      checkInLatitude: latitude,
      checkInLongitude: longitude,
      status: 'checked_in',
    );

    try {
      final id = await db.insert(
        'attendance',
        record.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return record.copyWith(id: id);
    } catch (e) {
      if (e.toString().contains('UNIQUE constraint failed')) {
        throw Exception('Attendance record already exists for today.');
      }
      throw Exception('Failed to record check-in: $e');
    }
  }

  Future<AttendanceModel> checkOut({
    required String employeeId,
    required String checkOutTime,
    required double latitude,
    required double longitude,
  }) async {
    final db = await _db;
    final today = getTodayDateString();

    final existing = await getTodayAttendance(employeeId);
    if (existing == null) {
      throw Exception('No check-in record found for today. You must check in before checking out.');
    }
    if (existing.status == 'checked_out') {
      throw Exception('Already checked out for today ($today). Duplicate check-out is not allowed.');
    }

    final rowsUpdated = await db.update(
      'attendance',
      {
        'checkOutTime': checkOutTime,
        'checkOutLatitude': latitude,
        'checkOutLongitude': longitude,
        'status': 'checked_out',
      },
      where: 'employeeId = ? AND date = ?',
      whereArgs: [employeeId, today],
    );

    if (rowsUpdated == 0) {
      throw Exception('Could not update check-out status.');
    }

    return existing.copyWith(
      checkOutTime: checkOutTime,
      checkOutLatitude: latitude,
      checkOutLongitude: longitude,
      status: 'checked_out',
    );
  }

  Future<AttendanceModel?> getAttendanceById(int id) async {
    final db = await _db;
    final results = await db.query(
      'attendance',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isEmpty) return null;
    return AttendanceModel.fromMap(results.first);
  }

  Future<List<AttendanceModel>> fetchAttendanceRecords() async {
    try {
      await ApiService.get('/attendance').timeout(const Duration(milliseconds: 600));
    } catch (_) {}
    return getAllAttendance();
  }
}
