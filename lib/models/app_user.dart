import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String nom;
  final String telephone;
  final String localite;
  final String pin;
  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.nom,
    required this.telephone,
    required this.localite,
    required this.pin,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nom': nom,
      'telephone': telephone,
      'localite': localite,
      'pin': pin,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    DateTime parsedDate;
    final createdAtValue = map['createdAt'];
    if (createdAtValue is Timestamp) {
      parsedDate = createdAtValue.toDate();
    } else if (createdAtValue is String) {
      parsedDate = DateTime.parse(createdAtValue);
    } else {
      parsedDate = DateTime.now();
    }

    return AppUser(
      uid: map['uid'] as String,
      nom: map['nom'] as String,
      telephone: map['telephone'] as String,
      localite: map['localite'] as String? ?? '',
      pin: map['pin'] as String,
      createdAt: parsedDate,
    );
  }
}
