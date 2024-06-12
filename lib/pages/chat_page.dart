import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterchat/chat/chat_service.dart';
import 'package:flutterchat/chat/media_service.dart';
import 'package:flutterchat/components/chat_bubble.dart';
import 'package:flutterchat/components/text_field.dart';
import 'package:image_picker/image_picker.dart';

class ChatPage extends StatefulWidget {
  final String recieverUserEmail;
  final String recieverUserId;
  const ChatPage(
      {super.key,
      required this.recieverUserEmail,
      required this.recieverUserId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage() async {
    //only send message if there is something to send
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.recieverUserId, _messageController.text);
      //clear the text controller after sending the message
      _messageController.clear();
    }
  }

  void sendMedia(bool isImage) async {
    XFile? pickedFile = await pickMedia(isImage: isImage);
    if (pickedFile != null) {
      try {
        String mediaUrl = await uploadMedia(pickedFile, isImage);
        String mediaType = isImage ? 'image' : 'video';
        await sendMediaMessage(
            widget.recieverUserId, mediaUrl, mediaType, null);
      } catch (e) {
        print("Error sending media: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.recieverUserEmail,
        ),
      ),
      body: Column(
        children: [
          //messages
          Expanded(
            child: _buildMessageList(),
          ),

          //user input
          _buildMessageInput(),

          const SizedBox(
            height: 1,
          )
        ],
      ),
    );
  }

  //build message list
  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(
          widget.recieverUserId, _firebaseAuth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No messages yet'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            return _buildMessageItem(snapshot.data!.docs[index]);
          },
        );
      },
    );
  }

  //build message item
  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    //align messages to right if sender is current user otherwise left
    var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    Color color = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? Colors.lightBlue
        : Colors.grey;

    return Container(
      alignment: alignment,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: (data['senderId'] == _firebaseAuth.currentUser!.uid)
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(data['senderEmail']),
          const SizedBox(
            height: 5,
          ),
          if (data.containsKey('mediaUrl') && data['mediaUrl'] != null) ...[
            data['mediaType'] == 'image'
                ? Container(
                    constraints: const BoxConstraints(
                      maxWidth: 200, // Adjust the max width as needed
                    ),
                    child: Image.network(data['mediaUrl']),
                  )
                : data['mediaType'] == 'video'
                    ? Container(
                        constraints: const BoxConstraints(
                          maxWidth: 200, // Adjust the max width as needed
                        ),
                        child: VideoWidget(url: data['mediaUrl']),
                      )
                    : Container(), // Handle other media types if needed
          ] else if (data.containsKey('message') &&
              data['message'] != null) ...[
            ChatBubble(
              message: data['message'],
              backgroundColor: color,
            ),
          ] else ...[
            const Text('Unsupported message type or empty message'),
          ]
        ],
      ),
    );
  }

  //build message input
  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Expanded(
            child: MyTextField(
              controller: _messageController,
              obscureText: false,
              hintText: 'Send Message',
            ),
          ),
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: () => sendMedia(true),
          ),
          IconButton(
            icon: const Icon(Icons.video_library),
            onPressed: () => sendMedia(false),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: sendMessage,
          ),
        ],
      ),
    );
  }
}

class VideoWidget extends StatelessWidget {
  final String url;

  const VideoWidget({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 200, // Adjust the max width as needed
      ),
      child: Text("Video URL: $url"), // Replace with actual video player widget
    );
  }
}
