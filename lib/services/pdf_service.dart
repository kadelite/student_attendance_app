import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/attendance_model.dart';
import '../models/user_model.dart';

class PdfService {
  static final PdfService _instance = PdfService._internal();
  factory PdfService() => _instance;
  PdfService._internal();

  /// Generate attendance report PDF for a student
  Future<Uint8List> generateStudentReport({
    required UserModel student,
    required List<AttendanceModel> attendanceRecords,
    required Map<String, double> statistics,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final pdf = pw.Document();

    // Sort records by date
    attendanceRecords.sort((a, b) => b.date.compareTo(a.date));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            _buildHeader('Student Attendance Report'),
            pw.SizedBox(height: 20),

            // Student Information
            _buildStudentInfo(student),
            pw.SizedBox(height: 20),

            // Report Period
            if (startDate != null && endDate != null) ...[
              _buildReportPeriod(startDate, endDate),
              pw.SizedBox(height: 20),
            ],

            // Statistics Summary
            _buildStatisticsSummary(statistics),
            pw.SizedBox(height: 20),

            // Attendance Records Table
            _buildAttendanceTable(attendanceRecords),
          ];
        },
      ),
    );

    return pdf.save();
  }

  /// Generate comprehensive school report PDF
  Future<Uint8List> generateSchoolReport({
    required List<UserModel> students,
    required List<AttendanceModel> attendanceRecords,
    required Map<String, double> overallStatistics,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            _buildHeader('School Attendance Report'),
            pw.SizedBox(height: 20),

            // Report Period
            if (startDate != null && endDate != null) ...[
              _buildReportPeriod(startDate, endDate),
              pw.SizedBox(height: 20),
            ],

            // Overall Statistics
            _buildOverallStatistics(overallStatistics, students.length),
            pw.SizedBox(height: 20),

            // Students Summary
            _buildStudentsSummary(students, attendanceRecords),
          ];
        },
      ),
    );

    return pdf.save();
  }

  /// Generate teacher's class report PDF
  Future<Uint8List> generateTeacherReport({
    required UserModel teacher,
    required List<UserModel> students,
    required List<AttendanceModel> attendanceRecords,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            _buildHeader('Class Attendance Report'),
            pw.SizedBox(height: 20),

            // Teacher Information
            _buildTeacherInfo(teacher),
            pw.SizedBox(height: 20),

            // Report Period
            if (startDate != null && endDate != null) ...[
              _buildReportPeriod(startDate, endDate),
              pw.SizedBox(height: 20),
            ],

            // Class Statistics
            _buildClassStatistics(students, attendanceRecords),
            pw.SizedBox(height: 20),

            // Individual Student Performance
            _buildStudentPerformance(students, attendanceRecords),
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(String title) {
    return pw.Header(
      level: 0,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'Generated on ${DateFormat('MMMM dd, yyyy').format(DateTime.now())}',
                style: const pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),
          pw.Container(
            width: 60,
            height: 60,
            decoration: pw.BoxDecoration(
              color: PdfColors.blue,
              shape: pw.BoxShape.circle,
            ),
            child: pw.Center(
              child: pw.Text(
                'SA',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildStudentInfo(UserModel student) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Student Information',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text('Name: ${student.name}'),
              ),
              pw.Expanded(
                child: pw.Text('Email: ${student.email}'),
              ),
            ],
          ),
          if (student.teacherId != null)
            pw.Text('Teacher ID: ${student.teacherId}'),
        ],
      ),
    );
  }

  pw.Widget _buildTeacherInfo(UserModel teacher) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Teacher Information',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text('Name: ${teacher.name}'),
              ),
              pw.Expanded(
                child: pw.Text('Email: ${teacher.email}'),
              ),
            ],
          ),
          pw.Text('Teacher ID: ${teacher.id.substring(0, 8)}'),
        ],
      ),
    );
  }

  pw.Widget _buildReportPeriod(DateTime startDate, DateTime endDate) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(
            'Report Period: ${DateFormat('MMM dd, yyyy').format(startDate)} - ${DateFormat('MMM dd, yyyy').format(endDate)}',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildStatisticsSummary(Map<String, double> statistics) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Attendance Summary',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildStatItem(
                  'Attendance Rate',
                  '${statistics['attendancePercentage']?.toStringAsFixed(1) ?? '0'}%',
                  PdfColors.green,
                ),
              ),
              pw.Expanded(
                child: _buildStatItem(
                  'Total Days',
                  '${statistics['totalDays']?.toInt() ?? 0}',
                  PdfColors.blue,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildStatItem(
                  'Present',
                  '${statistics['presentDays']?.toInt() ?? 0}',
                  PdfColors.green,
                ),
              ),
              pw.Expanded(
                child: _buildStatItem(
                  'Late',
                  '${statistics['lateDays']?.toInt() ?? 0}',
                  PdfColors.orange,
                ),
              ),
              pw.Expanded(
                child: _buildStatItem(
                  'Absent',
                  '${statistics['absentDays']?.toInt() ?? 0}',
                  PdfColors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildStatItem(String label, String value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  pw.Widget _buildAttendanceTable(List<AttendanceModel> records) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Attendance Records',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          children: [
            // Header
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey100),
              children: [
                _buildTableCell('Date', isHeader: true),
                _buildTableCell('Status', isHeader: true),
                _buildTableCell('Remarks', isHeader: true),
              ],
            ),
            // Data rows
            ...records.map((record) => pw.TableRow(
              children: [
                _buildTableCell(DateFormat('MMM dd, yyyy').format(record.date)),
                _buildTableCell(
                  record.status.name.toUpperCase(),
                  color: _getStatusColor(record.status),
                ),
                _buildTableCell(record.remarks ?? '-'),
              ],
            )).toList(),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildOverallStatistics(Map<String, double> statistics, int totalStudents) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'School Statistics',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildStatItem(
                  'Total Students',
                  totalStudents.toString(),
                  PdfColors.blue,
                ),
              ),
              pw.Expanded(
                child: _buildStatItem(
                  'Attendance Rate',
                  '${statistics['attendancePercentage']?.toStringAsFixed(1) ?? '0'}%',
                  PdfColors.green,
                ),
              ),
              pw.Expanded(
                child: _buildStatItem(
                  'Total Records',
                  '${statistics['totalDays']?.toInt() ?? 0}',
                  PdfColors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildStudentsSummary(List<UserModel> students, List<AttendanceModel> records) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Students Summary',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          children: [
            // Header
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey100),
              children: [
                _buildTableCell('Student Name', isHeader: true),
                _buildTableCell('Email', isHeader: true),
                _buildTableCell('Records', isHeader: true),
                _buildTableCell('Attendance Rate', isHeader: true),
              ],
            ),
            // Data rows
            ...students.map((student) {
              final studentRecords = records.where((r) => r.studentId == student.id).toList();
              final presentCount = studentRecords.where((r) => r.status == AttendanceStatus.present).length;
              final totalCount = studentRecords.length;
              final rate = totalCount > 0 ? (presentCount / totalCount) * 100 : 0.0;
              
              return pw.TableRow(
                children: [
                  _buildTableCell(student.name),
                  _buildTableCell(student.email),
                  _buildTableCell(totalCount.toString()),
                  _buildTableCell('${rate.toStringAsFixed(1)}%'),
                ],
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildClassStatistics(List<UserModel> students, List<AttendanceModel> records) {
    final presentCount = records.where((r) => r.status == AttendanceStatus.present).length;
    final lateCount = records.where((r) => r.status == AttendanceStatus.late).length;
    final absentCount = records.where((r) => r.status == AttendanceStatus.absent).length;
    final totalRecords = records.length;
    final rate = totalRecords > 0 ? ((presentCount + lateCount) / totalRecords) * 100 : 0.0;
    
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Class Statistics',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildStatItem('Total Students', students.length.toString(), PdfColors.blue),
              ),
              pw.Expanded(
                child: _buildStatItem('Attendance Rate', '${rate.toStringAsFixed(1)}%', PdfColors.green),
              ),
              pw.Expanded(
                child: _buildStatItem('Present', presentCount.toString(), PdfColors.green),
              ),
              pw.Expanded(
                child: _buildStatItem('Late', lateCount.toString(), PdfColors.orange),
              ),
              pw.Expanded(
                child: _buildStatItem('Absent', absentCount.toString(), PdfColors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildStudentPerformance(List<UserModel> students, List<AttendanceModel> records) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Individual Student Performance',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          children: [
            // Header
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey100),
              children: [
                _buildTableCell('Student', isHeader: true),
                _buildTableCell('Present', isHeader: true),
                _buildTableCell('Late', isHeader: true),
                _buildTableCell('Absent', isHeader: true),
                _buildTableCell('Rate', isHeader: true),
              ],
            ),
            // Data rows
            ...students.map((student) {
              final studentRecords = records.where((r) => r.studentId == student.id).toList();
              final present = studentRecords.where((r) => r.status == AttendanceStatus.present).length;
              final late = studentRecords.where((r) => r.status == AttendanceStatus.late).length;
              final absent = studentRecords.where((r) => r.status == AttendanceStatus.absent).length;
              final total = studentRecords.length;
              final rate = total > 0 ? ((present + late) / total) * 100 : 0.0;
              
              return pw.TableRow(
                children: [
                  _buildTableCell(student.name),
                  _buildTableCell(present.toString()),
                  _buildTableCell(late.toString()),
                  _buildTableCell(absent.toString()),
                  _buildTableCell('${rate.toStringAsFixed(1)}%'),
                ],
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false, PdfColor? color}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color,
        ),
      ),
    );
  }

  PdfColor _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return PdfColors.green;
      case AttendanceStatus.late:
        return PdfColors.orange;
      case AttendanceStatus.absent:
        return PdfColors.red;
    }
  }
}