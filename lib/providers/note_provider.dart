import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:assesment_ppkd/model/note_model.dart';

class NoteProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Stream daftar catatan hewan milik pengguna spesifik dari Cloud Firestore
  Stream<List<NoteModel>> getNotesStreamForUser(String targetUserId) {
    final userId = targetUserId.isNotEmpty
        ? targetUserId
        : (_auth.currentUser?.uid ?? _auth.currentUser?.email ?? '');

    return _firestore.collection('notes').snapshots().map((snapshot) {
      final list = snapshot.docs
          .map((doc) => NoteModel.fromJson(doc.data(), docId: doc.id))
          .toList();

      if (userId.isNotEmpty) {
        final userList = list.where((n) => n.userId == userId).toList();
        userList.sort((a, b) {
          if (a.createdAt == null) return 1;
          if (b.createdAt == null) return -1;
          return b.createdAt!.compareTo(a.createdAt!);
        });
        return userList;
      }
      return [];
    });
  }

  Stream<List<NoteModel>> get notesStream =>
      getNotesStreamForUser(_auth.currentUser?.uid ?? '');

  /// Menambahkan Catatan Hewan baru ke Cloud Firestore
  Future<bool> addNote({
    required String namaHewan,
    required String details,
    String? fotoUrl,
    String? customUserId,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final userId = (customUserId != null && customUserId.isNotEmpty)
          ? customUserId
          : (_auth.currentUser?.uid ?? _auth.currentUser?.email ?? 'guest_user');
      final newDocRef = _firestore.collection('notes').doc();

      final note = NoteModel(
        id: newDocRef.id,
        userId: userId,
        namaHewan: namaHewan,
        details: details,
        fotoUrl: (fotoUrl != null && fotoUrl.isNotEmpty)
            ? fotoUrl
            : 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?q=80&w=600&auto=format&fit=crop',
        createdAt: DateTime.now(),
      );

      await newDocRef.set(note.toJson());

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menyimpan catatan: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  /// Memperbarui Catatan Hewan di Cloud Firestore
  Future<bool> updateNote({
    required String noteId,
    required String namaHewan,
    required String details,
    String? fotoUrl,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _firestore.collection('notes').doc(noteId).update({
        'namaHewan': namaHewan,
        'details': details,
        if (fotoUrl != null && fotoUrl.isNotEmpty) 'fotoUrl': fotoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal memperbarui catatan: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  /// Menghapus catatan dari Cloud Firestore
  Future<bool> deleteNote(String noteId) async {
    try {
      await _firestore.collection('notes').doc(noteId).delete();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menghapus catatan: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
