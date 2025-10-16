import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String fullName;
  final String mobileNumber;
  final String email;
  final String homeAddress;
  final List<String> fcmTokens;

  AppUser({
    required this.uid,
    required this.fullName,
    required this.mobileNumber,
    required this.email,
    required this.homeAddress,
    this.fcmTokens = const [],
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      fullName: data['fullName'] ?? '',
      mobileNumber: data['mobileNumber'] ?? '',
      email: data['email'] ?? '',
      homeAddress: data['homeAddress'] ?? '',
      fcmTokens: List<String>.from(data['fcmTokens'] ?? []),
    );
  }
}
