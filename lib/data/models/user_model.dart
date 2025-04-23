// dart
class UserModel {
  final String? id;
  final String email;
  final String? fullName;
  final String? phoneNumber;
  final DateTime? createdAt;

  UserModel({
    this.id,
    required this.email,
    this.fullName,
    this.phoneNumber,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'].toString(),
      fullName: json['full_name'].toString(),
      phoneNumber: json['phone'].toString() ,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'email': email,
      if (fullName != null) 'full_name': fullName,
      if (phoneNumber != null) 'phone': phoneNumber,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}
