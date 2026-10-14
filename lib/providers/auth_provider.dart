import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../data/sample_data.dart';
import '../models/preferences.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  AppUser? _currentUser;
  UserPreferences? _preferences;
  final List<AppUser> _users = List.from(SampleData.users);
  final Map<String, UserPreferences> _prefsByUser = {
    SampleData.defaultSeekerPrefs.userId: SampleData.defaultSeekerPrefs,
  };
  bool _ready = false;

  AppUser? get currentUser => _currentUser;
  UserPreferences? get preferences => _preferences;
  bool get isLoggedIn => _currentUser != null;
  bool get ready => _ready;
  List<AppUser> get allUsers => List.unmodifiable(_users);
  List<AppUser> get seekers =>
      _users.where((u) => u.role == UserRole.seeker).toList();
  List<AppUser> get owners =>
      _users.where((u) => u.role == UserRole.owner).toList();

  Future<void> tryRestoreSession() async {
    await _loadPasswordOverrides();
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('session_email');
    if (email != null) {
      final user = _findByEmail(email);
      if (user != null) {
        _currentUser = user;
        _preferences = _prefsByUser[user.id];
      }
    }
    _ready = true;
    notifyListeners();
  }

  AppUser? _findByEmail(String email) {
    final needle = email.trim().toLowerCase();
    for (final u in _users) {
      if (u.email.toLowerCase() == needle) return u;
    }
    return null;
  }

  Future<void> _loadPasswordOverrides() async {
    final prefs = await SharedPreferences.getInstance();
    for (var i = 0; i < _users.length; i++) {
      final key = 'pwd_${_users[i].email.toLowerCase()}';
      final saved = prefs.getString(key);
      if (saved != null && saved.isNotEmpty) {
        _users[i] = _users[i].copyWith(password: saved);
      }
    }
  }

  Future<void> _persistPassword(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pwd_${user.email.toLowerCase()}', user.password);
  }

  Future<String?> login(String email, String password) async {
    if (!_ready) await tryRestoreSession();
    final user = _users.cast<AppUser?>().firstWhere(
          (u) =>
              u!.email.toLowerCase() == email.trim().toLowerCase() &&
              u.password == password.trim(),
          orElse: () => null,
        );
    if (user == null) {
      return 'Invalid email or password. Try a demo account below.';
    }
    _currentUser = user;
    _preferences = _prefsByUser[user.id];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('session_email', user.email);
    notifyListeners();
    return null;
  }

  Future<String?> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    if (_users.any((u) => u.email.toLowerCase() == email.trim().toLowerCase())) {
      return 'An account with this email already exists';
    }
    if (role == UserRole.admin) return 'Cannot self-register as admin';

    final user = AppUser(
      id: const Uuid().v4(),
      fullName: fullName.trim(),
      email: email.trim().toLowerCase(),
      phone: phone.trim(),
      password: password.trim(),
      role: role,
      createdAt: DateTime.now(),
    );
    _users.add(user);
    await _persistPassword(user);
    _currentUser = user;
    if (role == UserRole.seeker) {
      final prefs = UserPreferences(id: const Uuid().v4(), userId: user.id);
      _prefsByUser[user.id] = prefs;
      _preferences = prefs;
    }
    final storage = await SharedPreferences.getInstance();
    await storage.setString('session_email', user.email);
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    _currentUser = null;
    _preferences = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_email');
    notifyListeners();
  }

  void updateProfile({
    String? fullName,
    String? email,
    String? phone,
    String? password,
    String? avatarUrl,
  }) {
    if (_currentUser == null) return;
    final updated = _currentUser!.copyWith(
      fullName: fullName,
      email: email,
      phone: phone,
      password: password,
      avatarUrl: avatarUrl,
    );
    final i = _users.indexWhere((u) => u.id == updated.id);
    if (i >= 0) _users[i] = updated;
    _currentUser = updated;
    if (password != null && password.isNotEmpty) {
      _persistPassword(updated);
    }
    notifyListeners();
  }

  /// Returns an error message, or null on success.
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final user = _currentUser;
    if (user == null) return 'Not signed in';
    if (currentPassword.trim() != user.password) {
      return 'Current password is incorrect';
    }
    if (newPassword.trim().length < 6) {
      return 'New password must be at least 6 characters';
    }
    if (newPassword.trim() != confirmPassword.trim()) {
      return 'New passwords do not match';
    }
    updateProfile(password: newPassword.trim());
    return null;
  }

  void savePreferences(UserPreferences prefs) {
    _prefsByUser[prefs.userId] = prefs;
    if (_currentUser?.id == prefs.userId) _preferences = prefs;
    notifyListeners();
  }

  void deleteUser(String userId) {
    if (_currentUser?.id == userId) return;
    _users.removeWhere((u) => u.id == userId);
    _prefsByUser.remove(userId);
    notifyListeners();
  }
}
