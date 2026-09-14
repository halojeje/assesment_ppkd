import 'package:assesment_ppkd/core/db_helper.dart';
import 'package:assesment_ppkd/core/pref_helper.dart';
import 'package:assesment_ppkd/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PrefHelper _prefHelper = PrefHelper();
  final DBHelper _dbHelper = DBHelper.instance;

  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _user;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get user => _user;

  /// Memuat sesi pengguna saat aplikasi dibuka
  Future<void> loadUserSession() async {
    final currentFirebaseUser = _firebaseAuth.currentUser;
    final savedUser = await _prefHelper.getUserSession();
    final cleanEmail = (currentFirebaseUser?.email ?? savedUser.email).trim();
    final uid = currentFirebaseUser?.uid ?? savedUser.uid;

    if (cleanEmail.isNotEmpty) {
      try {
        if (uid != null && uid.isNotEmpty) {
          final doc = await _firestore.collection('users').doc(uid).get();
          if (doc.exists && doc.data() != null) {
            _user = UserModel.fromJson(doc.data()!, docId: uid);
            await _prefHelper.saveUserSession(_user!);
            notifyListeners();
            return;
          }
        }
        final querySnap = await _firestore
            .collection('users')
            .where('email', isEqualTo: cleanEmail)
            .get();
        if (querySnap.docs.isNotEmpty) {
          final firstDoc = querySnap.docs.first;
          _user = UserModel.fromJson(firstDoc.data(), docId: firstDoc.id);
          await _prefHelper.saveUserSession(_user!);
          notifyListeners();
          return;
        }
      } catch (e) {
        debugPrint('Load session note: $e');
      }
    }

    if (currentFirebaseUser != null) {
      final displayName = (currentFirebaseUser.displayName != null &&
              currentFirebaseUser.displayName!.isNotEmpty)
          ? currentFirebaseUser.displayName!
          : (savedUser.name.isNotEmpty
              ? savedUser.name
              : (cleanEmail.split('@').first));
      _user = UserModel(
        uid: currentFirebaseUser.uid,
        name: displayName,
        email: cleanEmail,
        phone: savedUser.phone ?? '',
        profilePhoto: savedUser.profilePhoto ?? '',
      );
    } else {
      _user = savedUser;
    }
    notifyListeners();
  }

  /// Process Login dengan Firebase Auth & Firestore
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final cleanEmail = email.trim();
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        _errorMessage = 'Login gagal. User tidak ditemukan.';
        _setLoading(false);
        return false;
      }

      final uid = firebaseUser.uid;

      try {
        final doc = await _firestore.collection('users').doc(uid).get();
        if (doc.exists && doc.data() != null) {
          _user = UserModel.fromJson(doc.data()!, docId: uid);
        } else {
          final querySnap = await _firestore
              .collection('users')
              .where('email', isEqualTo: cleanEmail)
              .get();
          if (querySnap.docs.isNotEmpty) {
            final firstDoc = querySnap.docs.first;
            _user = UserModel.fromJson(firstDoc.data(), docId: firstDoc.id);
          } else {
            final displayName = (firebaseUser.displayName != null &&
                    firebaseUser.displayName!.isNotEmpty)
                ? firebaseUser.displayName!
                : cleanEmail.split('@').first;
            _user = UserModel(
              uid: uid,
              name: displayName,
              email: cleanEmail,
            );
            try {
              await _firestore.collection('users').doc(uid).set({
                'uid': uid,
                'name': displayName,
                'email': cleanEmail,
                'phone': '',
                'profile_photo': '',
                'createdAt': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));
            } catch (_) {}
          }
        }
      } catch (_) {
        final displayName = (firebaseUser.displayName != null &&
                firebaseUser.displayName!.isNotEmpty)
            ? firebaseUser.displayName!
            : cleanEmail.split('@').first;
        _user = UserModel(
          uid: uid,
          name: displayName,
          email: cleanEmail,
        );
      }

      await _prefHelper.saveAuthToken(_user!.uid ?? uid);
      await _prefHelper.saveUserSession(_user!);
      try {
        await _dbHelper.insertOrUpdateUser(_user!);
      } catch (_) {}

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getReadableAuthErrorMessage(e);
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Gagal login: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  /// Process Register dengan Firebase Auth & Firestore
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? jenisKelamin,
    String? profilePhoto,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final cleanEmail = email.trim();
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        final uid = firebaseUser.uid;
        try {
          await firebaseUser.updateDisplayName(name);
        } catch (_) {}

        final userDataMap = {
          'uid': uid,
          'name': name,
          'email': cleanEmail,
          'phone': phone ?? '',
          'jenis_kelamin': jenisKelamin ?? 'Laki-laki',
          'profile_photo': profilePhoto ?? '',
        };

        try {
          await _firestore.collection('users').doc(uid).set({
            ...userDataMap,
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } catch (e) {
          debugPrint('Firestore write note: $e');
        }

        _user = UserModel(
          uid: uid,
          name: name,
          email: cleanEmail,
          phone: phone ?? '',
          profilePhoto: profilePhoto ?? '',
        );

        await _prefHelper.saveAuthToken(uid);
        await _prefHelper.saveUserSession(_user!);
        try {
          await _dbHelper.insertOrUpdateUser(_user!);
        } catch (_) {}

        _setLoading(false);
        return true;
      } else {
        _errorMessage = 'Gagal mendaftar pengguna.';
        _setLoading(false);
        return false;
      }
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getReadableAuthErrorMessage(e);
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Gagal mendaftar: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  /// Update User Profile di Firestore & Session
  Future<bool> updateUserProfile({
    required String name,
    required String email,
    String? phone,
    String? profilePhoto,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final cleanEmail = email.trim();
      final firebaseUser = _firebaseAuth.currentUser;
      final uid = firebaseUser?.uid ??
          _user?.uid ??
          'user_${cleanEmail.hashCode.abs()}';

      final updatedMap = {
        'uid': uid,
        'name': name,
        'email': cleanEmail,
        'phone': phone ?? '',
        'profile_photo': profilePhoto ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      };

      try {
        await _firestore
            .collection('users')
            .doc(uid)
            .set(updatedMap, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Firestore doc set note: $e');
      }

      try {
        final querySnap = await _firestore
            .collection('users')
            .where('email', isEqualTo: cleanEmail)
            .get();
        for (var doc in querySnap.docs) {
          await doc.reference.set(updatedMap, SetOptions(merge: true));
        }
      } catch (e) {
        debugPrint('Firestore email query update note: $e');
      }

      if (_user != null) {
        _user = _user!.copyWith(
          uid: uid,
          name: name,
          email: cleanEmail,
          phone: phone,
          profilePhoto: profilePhoto ?? _user!.profilePhoto,
        );
      } else {
        _user = UserModel(
          uid: uid,
          name: name,
          email: cleanEmail,
          phone: phone ?? '',
          profilePhoto: profilePhoto ?? '',
        );
      }

      await _prefHelper.saveUserSession(_user!);
      try {
        await _dbHelper.insertOrUpdateUser(_user!);
      } catch (_) {}

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  /// Proses Logout
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      debugPrint('Firebase signOut note: $e');
    }
    try {
      await _prefHelper.clearSession();
    } catch (e) {
      debugPrint('PrefHelper clearSession note: $e');
    }
    try {
      await _dbHelper.clearAllData();
    } catch (e) {
      debugPrint('DBHelper clearAllData note: $e');
    }
    _user = null;
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _getReadableAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Email tidak terdaftar. Silakan mendaftar terlebih dahulu.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Password yang Anda masukkan salah atau email belum terdaftar.';
      case 'email-already-in-use':
        return 'Email sudah terdaftar. Silakan gunakan email lain atau login.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'weak-password':
        return 'Password terlalu lemah (minimal 6 karakter).';
      case 'operation-not-allowed':
        return 'Login dengan Email/Password belum diaktifkan di Firebase Console.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan login gagal. Silakan coba beberapa saat lagi.';
      default:
        return e.message ?? 'Terjadi kesalahan autentikasi (${e.code}).';
    }
  }
}
