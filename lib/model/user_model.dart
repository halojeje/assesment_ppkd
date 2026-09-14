class UserModel {
  final int? id;
  final String? uid;
  final String name;
  final String email;
  final String? phone;
  final String? profilePhoto;

  UserModel({
    this.id,
    this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.profilePhoto,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    return UserModel(
      id: json['id'] is int ? json['id'] as int : null,
      uid: docId ?? json['uid']?.toString(),
      name: (json['name'] != null && json['name'].toString().isNotEmpty)
          ? json['name'].toString()
          : (json['email'] != null ? json['email'].toString().split('@').first : 'User'),
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? json['no_hp']?.toString() ?? json['noHp']?.toString(),
      profilePhoto: json['profile_photo']?.toString() ??
          json['profilePhoto']?.toString() ??
          json['photo_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_photo': profilePhoto,
    };
  }

  UserModel copyWith({
    int? id,
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? profilePhoto,
  }) {
    return UserModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profilePhoto: profilePhoto ?? this.profilePhoto,
    );
  }
}

