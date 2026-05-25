import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class AppState extends ChangeNotifier {
  // ── Cached User ────────────────────────
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isDoctor => _currentUser?.role == 'doctor';
  bool get isPatient => _currentUser?.role == 'patient';

  static const _kUserKey = 'cached_user';

  // ── Charger le user depuis SharedPreferences ──
  Future<void> loadUserFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_kUserKey);
    if (json != null) {
      try {
        final map = jsonDecode(json) as Map<String, dynamic>;
        _currentUser = UserModel.fromMap(map, map['id'] ?? '');
        notifyListeners();
      } catch (e, stackTrace) {     log("❌ خطأ أثناء جلب أو تحويل بيانات المستخدم: $e");     log(stackTrace.toString());   }
    }
  }

  // ── Sauvegarder le user dans SharedPreferences ──
  Future<void> _saveUserToCache(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final map = {
      ...user.toMap(),
      'id': user.id,
    };
    await prefs.setString(_kUserKey, jsonEncode(map));
  }

  // ── Charger user depuis Firestore et mettre en cache ──
  Future<UserModel?> loadUserFromFirestore(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        final user = UserModel.fromMap(doc.data()!, doc.id);
        _currentUser = user;
        await _saveUserToCache(user);
        notifyListeners();
        return user;
      }
    } catch (e, stackTrace) {     log("❌ خطأ أثناء جلب أو تحويل بيانات المستخدم: $e");     log(stackTrace.toString());   }
    return null;
  }

  // ── Static: juste lire le rôle (utilisé dans AuthGate) ──
  static Future<String?> getUserRole(String uid) async {
    // 1. Essayer SharedPreferences d'abord
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_kUserKey);
      if (json != null) {
        final map = jsonDecode(json) as Map<String, dynamic>;
        if (map['id'] == uid) {
          return map['role'] as String?;
        }
      }
    } catch (e, stackTrace) {     log("❌ خطأ أثناء جلب أو تحويل بيانات المستخدم: $e");     log(stackTrace.toString());   }

    // 2. Sinon, lire depuis Firestore
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        final role = doc.data()?['role'] as String?;
        return role;
      }
    } catch (e, stackTrace) {     log("❌ خطأ أثناء جلب أو تحويل بيانات المستخدم: $e");     log(stackTrace.toString());   }
    return null;
  }

  // ── Déconnexion ──
  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUserKey);
    notifyListeners();
  }

  // ── Mettre à jour le profil en cache après modification ──
  Future<void> refreshUserFromFirestore(String uid) async {
    await loadUserFromFirestore(uid);
  }
}
