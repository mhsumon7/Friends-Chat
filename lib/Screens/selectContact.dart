import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../customUI/ContactCard.dart';
import 'package:campus_talk/group_chats/create_group/create_group.dart';
import '../Models/contactCardModel.dart';

class SelectContact extends StatefulWidget {
  const SelectContact({Key? key}) : super(key: key);

  @override
  _SelectContactState createState() => _SelectContactState();
}

class _SelectContactState extends State<SelectContact> {
  bool isLoading = false;
  User? loggedInUser = FirebaseAuth.instance.currentUser;
  List<String> friendsUIDs = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getFriendsList();
  }

  addFriend({required String friendUID, required int index}) async {
    setState(() {
      isLoading = true;
    });
    await FirebaseFirestore.instance
        .collection('users')
        .doc(loggedInUser!.uid)
        .collection('friends')
        .doc(friendUID)
        .set({'friendUID': friendUID});
    setState(() {
      isLoading = false;
      contacts.removeAt(index);
    });
    await FirebaseFirestore.instance
        .collection('users')
        .doc(friendUID)
        .collection('friends')
        .doc(loggedInUser!.uid)
        .set({'friendUID': loggedInUser!.uid});
  }

  getUsersList() async {
    setState(() {
      isLoading = true;
    });
    await FirebaseFirestore.instance.collection('users').get().then(
          (QuerySnapshot querySnapshot) => {
            querySnapshot.docs.forEach(
              (doc) {
                if (loggedInUser!.uid != doc['uid'] &&
                    friendsUIDs.contains(doc['uid']) == false &&
                    doc['isGroup'] == false) {
                  contacts.add(
                    ContactCardModel(
                      name: doc['name'],
                      profilePictureURL: doc['profilePictureURL'],
                      status: doc['status'],
                      uid: doc['uid'],
                    ),
                  );
                }
              },
            ),
          },
        );
    setState(() {
      isLoading = false;
      contacts;
    });
  }

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
              querySnapshot.docs.forEach(
                (doc) {
                  friendsUIDs.add(doc['friendUID']);
                },
              ),
            });

    await getUsersList();
    setState(() {
      isLoading = false;
    });
  }

  List<ContactCardModel> contacts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(
              child: Container(
                // height: MediaQuery.of(context).size.height,
                // color: Colors.black12,
                child: const CircularProgressIndicator(),
              ),
            )
          : ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) => InkWell(
                onTap: () {
                  addFriend(friendUID: contacts[index].uid!, index: index);
                },
                child: ContactCard(
                  contactCardModel: contacts[index],
                ),
              ),
            ),
    );
  }
}
