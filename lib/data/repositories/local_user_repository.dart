// data/repositories/local_user_repository.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/abstractions/user_repository.dart';
import '../../core/models/user_model.dart';

class LocalUserRepository implements UserRepository {
  static const String _usersKey = 'users';

  @override
  Future<UserModel?> getUser(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey);

      if (usersJson == null) {
        return null;
      }

      final Map<String, dynamic> users =
      json.decode(usersJson) as Map<String, dynamic>;

      if (!users.containsKey(email)) {
        return null;
      }

      return UserModel.fromJson(users[email] as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> updateUser(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey);

      if (usersJson == null) {
        return false;
      }

      final Map<String, dynamic> users =
      json.decode(usersJson) as Map<String, dynamic>;

      if (!users.containsKey(user.email)) {
        return false;
      }

      users[user.email] = user.toJson();
      await prefs.setString(_usersKey, json.encode(users));

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteUser(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey);

      if (usersJson == null) {
        return false;
      }

      final Map<String, dynamic> users =
      json.decode(usersJson) as Map<String, dynamic>;

      if (!users.containsKey(email)) {
        return false;
      }

      users.remove(email);
      await prefs.setString(_usersKey, json.encode(users));

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> saveUser(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey);

      final Map<String, dynamic> users = usersJson != null
          ? json.decode(usersJson) as Map<String, dynamic>
          : {};

      users[user.email] = user.toJson();
      await prefs.setString(_usersKey, json.encode(users));

      return true;
    } catch (e) {
      return false;
    }
  }
}