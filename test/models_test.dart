import 'package:flutter_test/flutter_test.dart';
import 'package:emp_management/data/models/employee_model.dart';
import 'package:emp_management/data/models/attendance_model.dart';

void main() {
  group('Models Unit Tests', () {
    test('EmployeeModel role checks and serialization', () {
      const admin = EmployeeModel(
        employeeId: 'ADM001',
        name: 'Admin User',
        email: 'admin@test.com',
        password: 'admin123',
        role: 'admin',
      );
      expect(admin.isAdmin, isTrue);

      const emp = EmployeeModel(
        employeeId: 'EMP001',
        name: 'John Employee',
        email: 'john@test.com',
        password: 'employee123',
        role: 'employee',
      );
      expect(emp.isAdmin, isFalse);

      final map = emp.toMap();
      final fromMap = EmployeeModel.fromMap(map);
      expect(fromMap.employeeId, equals('EMP001'));
      expect(fromMap.name, equals('John Employee'));
    });

    test('AttendanceModel serialization and copyWith', () {
      const attendance = AttendanceModel(
        id: 1,
        employeeId: 'EMP001',
        employeeName: 'John Employee',
        date: '2026-11-12',
        checkInTime: '2026-11-12T09:00:00Z',
        checkInLatitude: 37.422,
        checkInLongitude: -122.084,
        status: 'checked_in',
      );

      expect(attendance.status, equals('checked_in'));

      final updated = attendance.copyWith(
        checkOutTime: '2026-11-12T17:00:00Z',
        status: 'checked_out',
      );

      expect(updated.status, equals('checked_out'));
      expect(updated.checkOutTime, equals('2026-11-12T17:00:00Z'));
      expect(updated.checkInTime, equals('2026-11-12T09:00:00Z'));
    });
  });
}
