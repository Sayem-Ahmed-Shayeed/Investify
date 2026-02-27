/// User model for registration data
class UserModel {
  final String? uid;
  final String name;
  final String email;
  final int age;
  final String? nidCardImagePath;
  final DateTime? createdAt;
  final bool isInvestor;
  final String? phoneNumber;

  UserModel({
    this.uid,
    required this.name,
    required this.email,
    required this.age,
    this.nidCardImagePath,
    this.createdAt,
    this.isInvestor = false,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'age': age,
      'nidCardImagePath': nidCardImagePath,
      'createdAt': createdAt?.toIso8601String(),
      'isInvestor': isInvestor,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String?,
      name: json['name'] as String,
      email: json['email'] as String,
      age: json['age'] as int,
      nidCardImagePath: json['nidCardImagePath'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      isInvestor: json['isInvestor'] as bool? ?? false,
      phoneNumber: json['phoneNumber'] as String?,
    );
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    int? age,
    String? nidCardImagePath,
    DateTime? createdAt,
    bool? isInvestor,
    String? phoneNumber,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      nidCardImagePath: nidCardImagePath ?? this.nidCardImagePath,
      createdAt: createdAt ?? this.createdAt,
      isInvestor: isInvestor ?? this.isInvestor,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}
