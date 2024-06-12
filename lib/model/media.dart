import 'package:cloud_firestore/cloud_firestore.dart';

class Media {
  final String senderId;
  final String senderEmail;
  final String receiverId;
  final String mediaUrl;
  final String mediaType; // e.g., "image" or "video"
  final Timestamp timestamp;
  final String? thumbnailUrl; // Optional thumbnail URL for videos

  Media({
    required this.senderId,
    required this.senderEmail,
    required this.receiverId,
    required this.mediaUrl,
    required this.mediaType,
    required this.timestamp,
    this.thumbnailUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'receiverId': receiverId,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'timestamp': timestamp,
      'thumbnailUrl': thumbnailUrl,
    };
  }

  factory Media.fromMap(Map<String, dynamic> map) {
    return Media(
      senderId: map['senderId'],
      senderEmail: map['senderEmail'],
      receiverId: map['receiverId'],
      mediaUrl: map['mediaUrl'],
      mediaType: map['mediaType'],
      timestamp: map['timestamp'],
      thumbnailUrl: map['thumbnailUrl'],
    );
  }
}
