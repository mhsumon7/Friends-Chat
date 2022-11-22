import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../Screens/individualChatScreen.dart';
import '../customUI/chatCard.dart';
import '../Models/ChatCardModel.dart';

class chatHomePage extends StatefulWidget {
  const chatHomePage({Key? key}) : super(key: key);

  @override
  _chatHomePageState createState() => _chatHomePageState();
}

class _chatHomePageState extends State<chatHomePage> {
  User? loggedInUser = FirebaseAuth.instance.currentUser;

  List<String> friendUIDs = [];
  List<ChatCardModel> friendsChatCard = [];
  bool isLoading = false;

  getFriendsList() async {
    setState(() {
      isLoading = true;
    });
    await FirebaseFirestore.instance
        .collection('users')
        .doc(loggedInUser!.uid)
        .collection('friends')
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                friendUIDs.add(doc['friendUID']);
              })
            });

    await getFriendsInfo();
    setState(() {
      isLoading = false;
    });
  }

  getFriendsInfo() async {
    setState(() {
      isLoading = true;
    });
    await FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                if (friendUIDs.contains(doc['uid']) == true) {
                  friendsChatCard.add(ChatCardModel(
                    uid: doc['uid'],
                    profilePic: doc['profilePictureURL'],
                    name: doc['name'],
                    isGroup: doc['isGroup'],
                    status: doc['status'],
                  ));
                }
              })
            });
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getFriendsList();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: Container(
              //height: MediaQuery.of(context).size.height,
              //color: Colors.black12,
              child: const CircularProgressIndicator(),
            ),
          )
        : ListView.builder(
            itemCount: friendsChatCard.length,
            itemBuilder: (context, index) => InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => IndividualChatScreen(
                      chatCardModel: friendsChatCard[index],
                    ),
                  ),
                );
              },
              child: ChatCard(
                chatCardModel: friendsChatCard[index],
              ),
            ),
          );
  }
}
