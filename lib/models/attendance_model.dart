enum AttendanceStatus { present, absent, late }

class AttendanceModel {
  final String id;
  final String studentId;
  final String teacherId;
  final String studentName;
  final DateTime date;
  final AttendanceStatus status;
  final String? remarks;
  final DateTime timestamp;

  AttendanceModel({
    required this.id,
    required this.studentId,
    required this.teacherId,
    required this.studentName,
    required this.date,
    required this.status,
    this.remarks,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'teacherId': teacherId,
      'studentName': studentName,
      'date': date.millisecondsSinceEpoch,
      'status': status.toString().split('.').last,
      'remarks': remarks,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      id: map['id'] ?? '',
      studentId: map['studentId'] ?? '',
      teacherId: map['teacherId'] ?? '',
      studentName: map['studentName'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
      status: AttendanceStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => AttendanceStatus.absent,
      ),
      remarks: map['remarks'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
    );
  }

  AttendanceModel copyWith({
    String? id,
    String? studentId,
    String? teacherId,
    String? studentName,
    DateTime? date,
    AttendanceStatus? status,
    String? remarks,
    DateTime? timestamp,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      teacherId: teacherId ?? this.teacherId,
      studentName: studentName ?? this.studentName,
      date: date ?? this.date,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'AttendanceModel(id: $id, studentId: $studentId, teacherId: $teacherId, studentName: $studentName, date: $date, status: $status, remarks: $remarks, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is AttendanceModel &&
      other.id == id &&
      other.studentId == studentId &&
      other.teacherId == teacherId &&
      other.studentName == studentName &&
      other.date == date &&
      other.status == status &&
      other.remarks == remarks &&
      other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      studentId.hashCode ^
      teacherId.hashCode ^
      studentName.hashCode ^
      date.hashCode ^
      status.hashCode ^
      remarks.hashCode ^
      timestamp.hashCode;
  }
}