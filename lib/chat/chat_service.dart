import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterchat/model/message.dart';

class ChatService extends ChangeNotifier {
  //get an instance of auth and firestore
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  //send messages
  Future<void> sendMessage(String recieverId, String message) async {
    //get current user info
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    //create a new message
    Message newMessage = Message(
        senderId: currentUserId,
        senderEmail: currentUserEmail,
        recieverId: recieverId,
        message: message,
        timestamp: timestamp);

    //construct chatroom id from current user and reciever id (sorted to ensure uniqueness)
    List<String> ids = [currentUserId, recieverId];
    ids.sort(); //ensures that chatroom id is same always for any 2 people
    String chatroomId =
        ids.join("_"); //combines ids into single string to use as chatroom id

    //add new message to database
    await _fireStore
        .collection('chat_rooms')
        .doc(chatroomId)
        .collection('messages')
        .add(newMessage.toMap());

    await _fireStore.collection('chat_rooms').doc(chatroomId).set({
      'lastMessageTimestamp': timestamp,
      'lastMessageSenderId': currentUserId,
      'lastMessageSenderEmail': currentUserEmail
    }, SetOptions(merge: true));
  }

  //get messages
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    //construct chatroom id from user and otheruser ids (sort to ensure its same as chatroomid on senders side)
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatroomId = ids.join("_");
    return _fireStore
        .collection('chat_rooms')
        .doc(chatroomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Stream<QuerySnapshot> getChatRooms() {
    return _fireStore
        .collection('chat_rooms')
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots();
  }
}
