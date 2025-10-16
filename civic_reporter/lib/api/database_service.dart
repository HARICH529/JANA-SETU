import 'package:jana_setu/models/issue_model.dart';
import 'package:jana_setu/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  // Collection references
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference issueCollection =
      FirebaseFirestore.instance.collection('issues');

  // Update/Create user data
  Future<void> updateUserData({
    required String fullName,
    required String mobileNumber,
    required String email,
    required String homeAddress,
  }) async {
    return await userCollection.doc(uid).set({
      'fullName': fullName,
      'mobileNumber': mobileNumber,
      'email': email,
      'homeAddress': homeAddress,
    });
  }

  // Save FCM token
  Future<void> saveUserToken(String token) async {
    return await userCollection.doc(uid).update({
      // Using FieldValue to avoid duplicates
      'fcmTokens': FieldValue.arrayUnion([token])
    });
  }

  // Get user document reference
  DocumentReference get userDocument {
    return userCollection.doc(uid);
  }

  // Get user doc stream
  Stream<AppUser> get userData {
    return userCollection.doc(uid).snapshots().map(AppUser.fromFirestore);
  }

  // Submit a new issue
  Future<void> submitIssue({
    required String imageUrl,
    String? description,
    String? voiceNoteUrl,
    required GeoPoint location,
  }) async {
    await issueCollection.add({
      'userId': uid,
      'imageUrl': imageUrl,
      'description': description,
      'voiceNoteUrl': voiceNoteUrl,
      'location': location,
      'status': 'Pending',
      'timestamp': Timestamp.now(),
      'isAcknowledged': false,
    });
  }

  // Get user's issues stream
  Stream<List<Issue>> get issues {
    return issueCollection
        .where('userId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Issue.fromFirestore(doc)).toList());
  }

  // Get all issues stream for map view
  Stream<List<Issue>> get allIssues {
    return issueCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Issue.fromFirestore(doc)).toList());
  }

  // Acknowledge a resolved issue
  Future<void> acknowledgeResolution(String issueId) async {
    return await issueCollection.doc(issueId).update({'isAcknowledged': true});
  }
}
