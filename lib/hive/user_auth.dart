import 'package:hive_flutter/hive_flutter.dart';

part 'user_auth.g.dart';

@HiveType(typeId: 3)
class User extends HiveObject {
  @HiveField(0)
  final String username;

  @HiveField(1)
  final String emailaddress;

  @HiveField(2)
  final String password;

  // constructor
  User({
    required this.username,
    required this.emailaddress,
    required this.password,
  });
}
