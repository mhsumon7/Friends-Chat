import '../Screens/individualChatScreen.dart';

import '../Models/ChatCardModel.dart';
import '../customUI/chatCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class searchScreen extends StatefulWidget {
  @override
  _searchScreenState createState() => _searchScreenState();
}

class _searchScreenState extends State<searchScreen> with WidgetsBindingObserver {
  Map<String, dynamic>? userMap;
  bool isLoading = false;
  final TextEditingController _search = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> friendUIDs = [];
  List<ChatCardModel> friendsChatCard = [];

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
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setStatus("Online");
  }

  void setStatus(String status) async {
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      "status": status,
    });
  }

  @override

  void onSearch() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    setState(() {
      isLoading = true;
    });

    await _firestore
        .collection('users')
        .where("email", isEqualTo: _search.text)
        .get()
        .then((value) {
      setState(() {
        userMap = value.docs[0].data();
        isLoading = false;
      });
      print(userMap);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text("Search"),
      ),
      body: isLoading
          ? Center(
              child: Container(
                height: size.height / 20,
                width: size.height / 20,
                child: CircularProgressIndicator(),
              ),
            )
          : Column(
              children: [
                SizedBox(
                  height: 0,
                ),
                Container(
                  color: Colors.blue,
                  height: size.height / 16,
                  alignment: Alignment.center,
                  child: Container(
                    height: size.height / 20,
                    width: size.width / 1.25,
                    child: TextField(
                      textAlignVertical: TextAlignVertical.center,
                      maxLines: 1,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w500),
                      controller: _search,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                            onPressed: onSearch,
                            icon: Icon(
                              Icons.search,
                              color: Colors.white,
                            )),
                        hintText: "Search",
                        hintStyle: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w500),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(90.0)),
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(90.0)),
                          borderSide:
                              BorderSide(color: Colors.white, width: 2.0),
                        ),
                      ),
                    ),
                  ),
                ),
                userMap != null
                    ? ListView.builder(
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
                )
                    : Container(),
              ],
            ),
    );
  }
}
