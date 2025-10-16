enum UserType { student, teacher, admin }

class UserModel {
  final String id;
  final String email;
  final String name;
  final UserType userType;
  final String? teacherId; // For students to link to teacher
  final String? schoolId; // For organization
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.userType,
    this.teacherId,
    this.schoolId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'userType': userType.toString().split('.').last,
      'teacherId': teacherId,
      'schoolId': schoolId,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      userType: UserType.values.firstWhere(
        (e) => e.toString().split('.').last == map['userType'],
        orElse: () => UserType.student,
      ),
      teacherId: map['teacherId'],
      schoolId: map['schoolId'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    UserType? userType,
    String? teacherId,
    String? schoolId,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      userType: userType ?? this.userType,
      teacherId: teacherId ?? this.teacherId,
      schoolId: schoolId ?? this.schoolId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, name: $name, userType: $userType, teacherId: $teacherId, schoolId: $schoolId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is UserModel &&
      other.id == id &&
      other.email == email &&
      other.name == name &&
      other.userType == userType &&
      other.teacherId == teacherId &&
      other.schoolId == schoolId &&
      other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      email.hashCode ^
      name.hashCode ^
      userType.hashCode ^
      teacherId.hashCode ^
      schoolId.hashCode ^
      createdAt.hashCode;
  }
}