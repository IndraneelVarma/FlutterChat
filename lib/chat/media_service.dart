// ignore: file_names
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterchat/model/media.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<XFile?> pickMedia({required bool isImage}) async {
  final ImagePicker picker = ImagePicker();
  if (isImage) {
    return await picker.pickImage(source: ImageSource.gallery);
  } else {
    return await picker.pickVideo(source: ImageSource.gallery);
  }
}

Future<String> uploadMedia(XFile file, bool isImage) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw Exception("User not authenticated");
  }
  String fileExtension = isImage ? 'images' : 'videos';
  Reference storageReference = FirebaseStorage.instance
      .ref()
      .child('$fileExtension/${DateTime.now().millisecondsSinceEpoch}');
  UploadTask uploadTask = storageReference.putFile(File(file.path));
  TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
  return await taskSnapshot.ref.getDownloadURL();
}

Future<void> sendMediaMessage(String receiverId, String mediaUrl,
    String mediaType, String? thumbnailUrl) async {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final String currentUserEmail =
      FirebaseAuth.instance.currentUser!.email.toString();
  final Timestamp timestamp = Timestamp.now();

  Media newMedia = Media(
    senderId: currentUserId,
    senderEmail: currentUserEmail,
    receiverId: receiverId,
    mediaUrl: mediaUrl,
    mediaType: mediaType,
    timestamp: timestamp,
    thumbnailUrl: thumbnailUrl,
  );

  List<String> ids = [currentUserId, receiverId];
  ids.sort();
  String chatroomId = ids.join("_");

  await FirebaseFirestore.instance
      .collection('chat_rooms')
      .doc(chatroomId)
      .collection('messages')
      .add(newMedia.toMap());
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  await fireStore.collection('chat_rooms').doc(chatroomId).set({
    'lastMessageTimestamp': timestamp,
    'lastMessageSenderId': currentUserId,
    'lastMessageSenderEmail': currentUserEmail
  }, SetOptions(merge: true));
}
