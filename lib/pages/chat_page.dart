import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_messenger/components/chat_bubble.dart';
import 'package:flutter_chat_messenger/components/textfield.dart';
import 'package:flutter_chat_messenger/services/chat/chat_service.dart';
import 'package:intl/intl.dart';


class ChatPage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;
  final String fullName;
  const ChatPage(
      {super.key,
      required this.receiverUserEmail,
      required this.receiverUserID,
      required this.fullName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.receiverUserID, _messageController.text);

      // clear the controller after sending the message
      _messageController.clear();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    // _chatService.getMessages(widget.receiverUserID, otherUserId)
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape:
            Border(bottom: BorderSide(color: Colors.grey.shade300, width: 4)),
        backgroundColor: Colors.white,
        title: Text(widget.fullName),
      ),
      body: Column(
        children: [
          // messages
          Expanded(
            child: _buildMessageList(),
          ),

          // user input
          _buildMessageInput(),
          const SizedBox(
            height: 25,
          ),
        ],
      ),
    );
  }

  // build messsage list
  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(
          widget.receiverUserID, _firebaseAuth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error${snapshot.error}");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...");
        }
            // Access and print the data from the documents
      final messages = snapshot.data!.docs.map((document) => document.data());
      print("message response: $messages");
        // listview
        return ListView(
          scrollDirection: Axis.vertical,
          children: snapshot.data!.docs
              .map((document) => _buildMessageItem(document))
              .toList(),
        );
      },
    );
  }

  // build messsage item
  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    final Timestamp timestamp = data['timestamp'] as Timestamp;
    final DateTime dateTime = timestamp.toDate();
    final timeString = DateFormat('K:mm').format(dateTime);

    // align the messages to the irght if the sener is the current user, otherwise the left
    var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;
        var currentUser = (data['senderId'] == _firebaseAuth.currentUser!.uid);
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: currentUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(data['senderEmail']),
          const SizedBox(
            height: 6,
          ),
          ChatBubble(
            
            message: data['message'],
            timeStamp: timeString,
            width:  180,
            bubbleColor: currentUser
                ? Colors.blue
                : Colors.grey.shade200, 
                messageColor: currentUser ? Colors.white : Colors.black,
                
          ),
        ],
      ),
    );
  }

  // build message input
  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
            IconButton(
                onPressed: sendMessage,
                icon: const Icon(
                  Icons.add,
                  size: 30,
                ),
              ),
          Expanded(
            child: SizedBox(
              height: 50.0,
              child: MyTextField(
                controller: _messageController,
                hintText: 'Enter message',
                obscureText: false,
              ),
            ),
          ),

          // send button
          Row(
            children: [
              IconButton(
                onPressed: sendMessage,
                icon: const Icon(
                  Icons.arrow_circle_up_rounded,
                  // size: 35,
                ),
              ),
              IconButton(
                onPressed: sendMessage,
                icon: const Icon(
                  Icons.mic_rounded,
                  // size: 30,
                ),
              ),
              
            ],
          ),
        ],
      ),
    );
  }
}
