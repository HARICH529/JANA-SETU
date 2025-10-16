class Report {
  final String id;
  final String title;
  final String description;
  final String category;
  final double latitude;
  final double longitude;
  final String address;
  final String? imageUrl;
  final String status;
  final DateTime createdAt;
  final String userId;
  final String userName;
  final int upvotes;
  final List<String> upvotedBy;
  final String? blockchainTxHash;

  Report({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.imageUrl,
    required this.status,
    required this.createdAt,
    required this.userId,
    required this.userName,
    required this.upvotes,
    required this.upvotedBy,
    this.blockchainTxHash,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing report JSON: $json');
      
      // Safe parsing for upvotedBy
      List<String> upvotedByList = [];
      if (json['upvotedBy'] != null) {
        if (json['upvotedBy'] is List) {
          upvotedByList = (json['upvotedBy'] as List).map((e) => e.toString()).toList();
        }
      }
      
      return Report(
        id: json['_id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        category: json['department']?.toString() ?? 'Other',
        latitude: double.tryParse(json['location']?['coordinates']?[1]?.toString() ?? '0.0') ?? 0.0,
        longitude: double.tryParse(json['location']?['coordinates']?[0]?.toString() ?? '0.0') ?? 0.0,
        address: json['address']?.toString() ?? '',
        imageUrl: json['image_url']?.toString(),
        status: json['reportStatus']?.toString() ?? 'SUBMITTED',
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
        userId: json['userId'] is String ? json['userId'] : (json['userId']?['_id']?.toString() ?? ''),
        userName: json['userId'] is String ? 'Unknown User' : (json['userId']?['name']?.toString() ?? 'Unknown User'),
        upvotes: int.tryParse(json['upvotes']?.toString() ?? '0') ?? 0,
        upvotedBy: upvotedByList,
        blockchainTxHash: json['blockchainTxHash']?.toString(),
      );
    } catch (e) {
      print('Error parsing report JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'category': category,
      'location': {
        'type': 'Point',
        'coordinates': [longitude, latitude],
      },
      'address': address,
      'imageUrl': imageUrl,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
      'upvotes': upvotes,
      'upvotedBy': upvotedBy,
      'blockchainTxHash': blockchainTxHash,
    };
  }
}
