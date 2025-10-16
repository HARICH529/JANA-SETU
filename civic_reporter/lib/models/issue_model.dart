import 'package:cloud_firestore/cloud_firestore.dart';

class Issue {
  final String id;
  final String userId;
  final String imageUrl;
  final String? description;
  final String? voiceNoteUrl;
  final GeoPoint location;
  final String status; // e.g., "Pending", "In Progress", "Resolved"
  final Timestamp timestamp;
  final bool isAcknowledged;

  Issue({
    required this.id,
    required this.userId,
    required this.imageUrl,
    this.description,
    this.voiceNoteUrl,
    required this.location,
    required this.status,
    required this.timestamp,
    this.isAcknowledged = false,
  });

  factory Issue.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Issue(
      id: doc.id,
      userId: data['userId'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'],
      voiceNoteUrl: data['voiceNoteUrl'],
      location: data['location'] ?? const GeoPoint(0, 0),
      status: data['status'] ?? 'Pending',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      isAcknowledged: data['isAcknowledged'] ?? false,
    );
  }
}
