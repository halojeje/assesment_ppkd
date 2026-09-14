import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String? id;
  final String userId;
  final String namaHewan;
  final String details;
  final String? fotoUrl;
  final DateTime? createdAt;

  NoteModel({
    this.id,
    required this.userId,
    required this.namaHewan,
    required this.details,
    this.fotoUrl,
    this.createdAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    DateTime? created;
    if (json['createdAt'] is Timestamp) {
      created = (json['createdAt'] as Timestamp).toDate();
    } else if (json['createdAt'] is String) {
      created = DateTime.tryParse(json['createdAt']);
    }

    return NoteModel(
      id: docId ?? json['id']?.toString(),
      userId: json['userId'] ?? json['user_id'] ?? '',
      namaHewan: json['namaHewan'] ?? json['nama_hewan'] ?? '',
      details: json['details'] ?? json['details_informasi'] ?? '',
      fotoUrl: json['fotoUrl'] ?? json['foto_url'],
      createdAt: created,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'namaHewan': namaHewan,
      'details': details,
      'fotoUrl': fotoUrl,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}
