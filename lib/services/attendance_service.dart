import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/attendance_model.dart';
import '../models/user_model.dart';

class AttendanceService {
  static final AttendanceService _instance = AttendanceService._internal();
  factory AttendanceService() => _instance;
  AttendanceService._internal();

  static const String _attendanceKey = 'attendance_records';
  static const String _studentsKey = 'students_list';

  /// Mark student attendance
  Future<bool> markAttendance({
    required String studentId,
    required String teacherId,
    required String studentName,
    required AttendanceStatus status,
    String? remarks,
  }) async {
    try {
      final attendance = AttendanceModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        studentId: studentId,
        teacherId: teacherId,
        studentName: studentName,
        date: DateTime.now(),
        status: status,
        remarks: remarks,
        timestamp: DateTime.now(),
      );

      List<AttendanceModel> records = await getAttendanceRecords();
      
      // Remove existing attendance for same student and date
      records.removeWhere((record) => 
        record.studentId == studentId && 
        isSameDate(record.date, DateTime.now()));
      
      // Add new record
      records.add(attendance);
      
      // Save to storage
      await _saveAttendanceRecords(records);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get all attendance records
  Future<List<AttendanceModel>> getAttendanceRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? recordsData = prefs.getString(_attendanceKey);
      
      if (recordsData != null) {
        List<dynamic> recordsList = json.decode(recordsData);
        return recordsList.map((record) => AttendanceModel.fromMap(record)).toList();
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get attendance records for a specific student
  Future<List<AttendanceModel>> getStudentAttendance(String studentId) async {
    List<AttendanceModel> allRecords = await getAttendanceRecords();
    return allRecords.where((record) => record.studentId == studentId).toList();
  }

  /// Get attendance records for a specific teacher
  Future<List<AttendanceModel>> getTeacherAttendance(String teacherId) async {
    List<AttendanceModel> allRecords = await getAttendanceRecords();
    return allRecords.where((record) => record.teacherId == teacherId).toList();
  }

  /// Get attendance records for a specific date
  Future<List<AttendanceModel>> getAttendanceByDate(DateTime date) async {
    List<AttendanceModel> allRecords = await getAttendanceRecords();
    return allRecords.where((record) => isSameDate(record.date, date)).toList();
  }

  /// Get attendance records for a date range
  Future<List<AttendanceModel>> getAttendanceByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    List<AttendanceModel> allRecords = await getAttendanceRecords();
    return allRecords.where((record) {
      return record.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
             record.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// Register a student under a teacher
  Future<bool> registerStudent({
    required String studentId,
    required String studentName,
    required String teacherId,
    required String studentEmail,
  }) async {
    try {
      List<UserModel> students = await getRegisteredStudents();
      
      // Check if student already exists
      bool exists = students.any((student) => student.id == studentId);
      if (exists) return false;
      
      // Add new student
      final student = UserModel(
        id: studentId,
        email: studentEmail,
        name: studentName,
        userType: UserType.student,
        teacherId: teacherId,
        createdAt: DateTime.now(),
      );
      
      students.add(student);
      await _saveStudentsList(students);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get all registered students
  Future<List<UserModel>> getRegisteredStudents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? studentsData = prefs.getString(_studentsKey);
      
      if (studentsData != null) {
        List<dynamic> studentsList = json.decode(studentsData);
        return studentsList.map((student) => UserModel.fromMap(student)).toList();
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get students for a specific teacher
  Future<List<UserModel>> getTeacherStudents(String teacherId) async {
    List<UserModel> allStudents = await getRegisteredStudents();
    return allStudents.where((student) => student.teacherId == teacherId).toList();
  }

  /// Calculate attendance statistics
  Future<Map<String, double>> getAttendanceStats({
    String? studentId,
    String? teacherId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    List<AttendanceModel> records = await getAttendanceRecords();
    
    // Filter by parameters
    if (studentId != null) {
      records = records.where((record) => record.studentId == studentId).toList();
    }
    if (teacherId != null) {
      records = records.where((record) => record.teacherId == teacherId).toList();
    }
    if (startDate != null && endDate != null) {
      records = records.where((record) {
        return record.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
               record.date.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
    }
    
    if (records.isEmpty) {
      return {
        'totalDays': 0,
        'presentDays': 0,
        'absentDays': 0,
        'lateDays': 0,
        'attendancePercentage': 0,
      };
    }
    
    int totalDays = records.length;
    int presentDays = records.where((r) => r.status == AttendanceStatus.present).length;
    int absentDays = records.where((r) => r.status == AttendanceStatus.absent).length;
    int lateDays = records.where((r) => r.status == AttendanceStatus.late).length;
    
    double attendancePercentage = totalDays > 0 
      ? ((presentDays + lateDays) / totalDays) * 100 
      : 0;
    
    return {
      'totalDays': totalDays.toDouble(),
      'presentDays': presentDays.toDouble(),
      'absentDays': absentDays.toDouble(),
      'lateDays': lateDays.toDouble(),
      'attendancePercentage': attendancePercentage,
    };
  }

  /// Check if two dates are the same (ignoring time)
  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  /// Clear all attendance records (for testing/reset)
  Future<void> clearAllRecords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_attendanceKey);
    await prefs.remove(_studentsKey);
  }

  /// Save attendance records to storage
  Future<void> _saveAttendanceRecords(List<AttendanceModel> records) async {
    final prefs = await SharedPreferences.getInstance();
    String recordsData = json.encode(records.map((record) => record.toMap()).toList());
    await prefs.setString(_attendanceKey, recordsData);
  }

  /// Save students list to storage
  Future<void> _saveStudentsList(List<UserModel> students) async {
    final prefs = await SharedPreferences.getInstance();
    String studentsData = json.encode(students.map((student) => student.toMap()).toList());
    await prefs.setString(_studentsKey, studentsData);
  }
}