import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../Models/ChatCardModel.dart';
import '../customUI/othersMessageCard.dart';
import '../customUI/ownMessageCard.dart';

class IndividualChatScreen extends StatefulWidget {
  late ChatCardModel chatCardModel;
  IndividualChatScreen({required this.chatCardModel});

  @override
  _IndividualChatScreenState createState() => _IndividualChatScreenState();
}

class _IndividualChatScreenState extends State<IndividualChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // file pick
  PlatformFile? pickedFile;
  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    setState(() {
      pickedFile = result.files.first;
    });
    uploadFile();
  }

  Future uploadFile() async {
    var dateTimeNow = DateTime.now();
    final path = 'indiFile/${pickedFile!.name}';
    final file = File(pickedFile!.path!);
    //int status = 1;

    final ref = FirebaseStorage.instance.ref().child(path);
    final uploadTask = ref.putFile(file);

    final snapshot = await uploadTask.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();

    await _firestore
        .collection('users')
        .doc(loggedInUser!.uid)
        .collection('messages')
        .doc(widget.chatCardModel.uid)
        .collection('indiMessages')
        .doc()
        .set({
      'friendUID': widget.chatCardModel.uid,
      'message': urlDownload,
      'time': dateTimeNow,
      'isOwn': true,
    });
    print('Download Link : $urlDownload');
  }

  int showEmojiPicker = 0;
  // for focusing of the keyboard or textFormField
  FocusNode focusNode = FocusNode();
  // For adding emoji to textFormField we want textEditingController
  final TextEditingController _messageController = TextEditingController();
  String? profilePictureURL;
  User? loggedInUser = FirebaseAuth.instance.currentUser;
  ScrollController scrollController = ScrollController();

  getCurrentUser() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) => {
              profilePictureURL = value['profilePictureURL'],
              setState(() {
                profilePictureURL;
              }),
            });
  }

  @override
  // Here are we are adding listener in focusNode
  void initState() {
    // TODO: implement initState
    super.initState();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        setState(() {
          showEmojiPicker = 0;
        });
      }
    });
    getCurrentUser();
  }

  // emojiSelector method
  Widget emojiSelector() {
    return EmojiPicker(
      onEmojiSelected: (category, emoji) {
        setState(() {
          _messageController.text = _messageController.text + emoji.emoji;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leadingWidth: 115,
        backgroundColor: Colors.blue,
        leading: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Container(
                  child: const Padding(
                    padding: EdgeInsets.only(
                      left: 10,
                      top: 5,
                      bottom: 5,
                      right: 1,
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 4,
            ),
            CircleAvatar(
              radius: 20,
              backgroundImage: widget.chatCardModel.profilePic == null
                  ? AssetImage('images/generalProfile.jpeg')
                  : NetworkImage(widget.chatCardModel.profilePic!)
                      as ImageProvider,
            ),
          ],
        ),
        title: InkWell(
          onTap: () {},
          child: Container(
            margin: EdgeInsets.all(3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chatCardModel.name!,
                  style: const TextStyle(color: Colors.white, fontSize: 18.5),
                ),
              ],
            ),
          ),
        ),
        actions: [
          InkWell(
            onTap: () {},
            child: Icon(
              Icons.call,
              color: Colors.white,
              size: 28,
            ),
          ),
          SizedBox(
            width: 15,
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: WillPopScope(
          onWillPop: () {
            if (showEmojiPicker == 1) {
              setState(() {
                showEmojiPicker = 0;
              });
            } else {
              Navigator.pop(context);
            }
            return Future.value(false);
          },
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(loggedInUser!.uid)
                      .collection('messages')
                      .doc(widget.chatCardModel.uid)
                      .collection('indiMessages')
                      .orderBy('time', descending: true)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData == false) {
                      return Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.black12,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else {
                      return ListView.builder(
                        reverse: true,
                        controller: scrollController,
                        shrinkWrap: true,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var messageInfo = snapshot.data!.docs[index];
                          return messageInfo['isOwn']
                              ? OwnMessageCard(message: messageInfo['message'])
                              : OthersMessageCard(
                                  message: messageInfo['message']);
                        },
                      );
                    }
                  },
                ),
                // child: ListView(
                //   shrinkWrap: true,
                //   children: [],
                // ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (showEmojiPicker == 1)
                      SizedBox(
                        child: emojiSelector(),
                        height: MediaQuery.of(context).size.height / 3.2,
                      ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 90,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Card(
                                margin: const EdgeInsets.only(
                                  top: 8,
                                  left: 2,
                                  right: 2,
                                  bottom: 20,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                color: const Color(0xffF5F5F5),
                                child: TextFormField(
                                  controller: _messageController,
                                  focusNode: focusNode,
                                  textAlignVertical: TextAlignVertical.center,
                                  // keyboardType: TextInputType.multiline,

                                  style: const TextStyle(
                                    fontSize: 20,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Type something...',
                                    prefixIcon: IconButton(
                                      onPressed: () {
                                        focusNode.unfocus();
                                        focusNode.canRequestFocus = false;
                                        setState(() {
                                          showEmojiPicker ^= 1;
                                        });
                                      },
                                      icon: Icon(
                                        Icons.emoji_emotions,
                                        color: Color(0xff4E5152),
                                      ),
                                    ),
                                    // contentPadding: EdgeInsets.only(bottom: 2),
                                    border: InputBorder.none,
                                    suffixIcon: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          onPressed: selectFile,
                                          icon: Icon(
                                            Icons.link,
                                            color: Color(0xff4E5152),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                top: 8,
                                left: 2,
                                right: 2,
                                bottom: 22,
                              ),
                              child: CircleAvatar(
                                backgroundColor: Colors.blue,
                                radius: 24,
                                child: IconButton(
                                  onPressed: () async {
                                    scrollController.animateTo(
                                      scrollController.position.minScrollExtent,
                                      duration: const Duration(
                                        milliseconds: 100,
                                      ),
                                      curve: Curves.easeOut,
                                    );
                                    if (_messageController.text.isNotEmpty) {
                                      var dateTimeNow = DateTime.now();
                                      var mssg = _messageController.text;
                                      _messageController.clear();
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(loggedInUser!.uid)
                                          .collection('messages')
                                          .doc(widget.chatCardModel.uid)
                                          .collection('indiMessages')
                                          .doc()
                                          .set({
                                        'friendUID': widget.chatCardModel.uid,
                                        'message': mssg,
                                        'time': dateTimeNow,
                                        'isOwn': true,
                                      });
                                      dateTimeNow = DateTime.now();
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(widget.chatCardModel.uid)
                                          .collection('messages')
                                          .doc(loggedInUser!.uid)
                                          .collection('indiMessages')
                                          .doc()
                                          .set({
                                        'friendUID': loggedInUser!.uid,
                                        'message': mssg,
                                        'time': dateTimeNow,
                                        'isOwn': false,
                                      });
                                    }
                                  },
                                  icon: Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Icon(
                                      Icons.send_rounded,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



}
