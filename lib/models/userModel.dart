import 'package:tooth_tales/models/baseModel.dart';
class UserAccounts extends BaseModel {
  String userName;
  String password;
  bool isDoctor;

  UserAccounts({
    required String id,
    required this.userName,
    required this.password,
    this.isDoctor = false,
  }) : super(id: id);

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userName': userName,
      'password': password,
      'isDoctor': isDoctor,
    };
  }

  @override
  UserAccounts fromMap(Map<String, dynamic> map, String id) {
    return UserAccounts(
      id: id,
      userName: map['userName'] as String,
      password: map['password'] as String,
      isDoctor: map['isDoctor'] as bool? ?? false,
    );
  }

  @override
  String toString() {
    return 'UserAccounts(userId: $id, userName: $userName, password: $password, isDoctor: $isDoctor)';
  }
}
