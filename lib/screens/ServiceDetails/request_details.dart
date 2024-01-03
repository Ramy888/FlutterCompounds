import 'package:flutter/material.dart';

class RequestDetails extends StatefulWidget {

  const RequestDetails({Key? key}) : super(key: key);

  static const routeName = 'support/request-details';
  @override
  _RequestDetailsState createState() => _RequestDetailsState();
}

class _RequestDetailsState extends State<RequestDetails> {
  List<Message> messages = [
    Message(text: 'Hello!', isUser: true, time: DateTime.now()),
    Message(text: 'Hi there!', isUser: false, time: DateTime.now()),
    // Add more messages as needed
  ];

  TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              reverse: true, // Reverse the list to show recent messages at the bottom
              itemBuilder: (context, index) {
                Message message = messages[index];
                return ChatBubble(
                  text: message.text,
                  isUser: message.isUser,
                  time: message.time,
                );
              },
            ),
          ),
          Divider(height: 1.0),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textEditingController,
                    decoration: InputDecoration.collapsed(
                      hintText: 'Type your message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    sendMessage();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void sendMessage() {
    String text = _textEditingController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        //delay insertion of message to show typing indicator
        messages.insert(0,
          Message(text: text, isUser: true, time: DateTime.now()),
        );
        _textEditingController.clear();
      });
    }

    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        messages.insert(0,
          Message(text: 'please hold...', isUser: false, time: DateTime.now()),
        );
      });
    });
  }
}

class Message {
  final String text;
  final bool isUser;
  final DateTime time;

  Message({
    required this.text,
    required this.isUser,
    required this.time,
  });
}

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final DateTime time;

  ChatBubble({
    required this.text,
    required this.isUser,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.all(8.0),
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue : Colors.grey,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${time.hour}:${time.minute}',
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4.0),
            Text(
              text,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
