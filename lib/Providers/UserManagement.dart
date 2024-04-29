import 'package:flutter/cupertino.dart';
import '../Models/UserManagement.dart';
class UserManagementProvider extends ChangeNotifier {
  UserManagement? _userManagement;

  UserManagement? get userManagement => _userManagement;

  // ... your provider logic for updating userManagement ...

  void updateUserManagement(UserManagement newUserManagement) {
    _userManagement = newUserManagement;
    notifyListeners();
  }
}