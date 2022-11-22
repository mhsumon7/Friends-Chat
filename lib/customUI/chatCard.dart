import 'package:flutter/material.dart';
import '../Screens/individualChatScreen.dart';
import '../Models/ChatCardModel.dart';

class ChatCard extends StatelessWidget {
  final ChatCardModel chatCardModel;
  const ChatCard({Key? key, required this.chatCardModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ListTile(
              leading: CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(chatCardModel.profilePic!),
              ),
              title: Text(
                chatCardModel.name!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                ),
              ),
              subtitle: Text(
                chatCardModel.status!,
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const Divider(
            thickness: 0.5,
          ),
        ],
      ),
    );
  }
}
