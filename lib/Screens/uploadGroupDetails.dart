import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';

import '../Models/contactCardModel.dart';
import '../Models/userModel.dart';
import 'homeScreen.dart';

class UploadGroupDetails extends StatefulWidget {
  List<ContactCardModel> members;
  UploadGroupDetails({required this.members, Key? key}) : super(key: key);

  @override
  _UploadGroupDetailsState createState() => _UploadGroupDetailsState();
}

class _UploadGroupDetailsState extends State<UploadGroupDetails> {
  bool isLoading = false;
  String? profilePictureURL;
  File? image;
  late UserModel loggedInUser;
  String? groupId;

  TextEditingController nameController = TextEditingController();
  TextEditingController statusController = TextEditingController();

  uploadGroupProfile() async {
    var collUser = FirebaseFirestore.instance.collection('users');
    await FirebaseFirestore.instance.collection('users').doc(groupId).set({
      'email': loggedInUser.email,
      'isGroup': true,
      'name': nameController.text,
      'status': statusController.text,
      'uid': groupId,
    });
    for (ContactCardModel mem in widget.members) {
      await collUser.doc(groupId).collection('members').doc(mem.uid).set({
        'friendUID': mem.uid,
      });
      await collUser.doc(mem.uid).collection('friends').doc(groupId).set({
        'friendUID': groupId,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: Container(
              height: MediaQuery.of(context).size.height,
              color: Colors.black12,
              child: const SpinKitThreeBounce(
                color: Color(0xffE76F52),
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              leading: TextButton(
                onPressed: () {},
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xffE2E2E2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Icon(
                        Icons.search,
                        color: Color(0xff4E5152),
                      ),
                    ),
                  ),
                ),
              ),
              backgroundColor: Colors.white,
              title: const Text(
                'New Group',
                style: TextStyle(color: Colors.black),
              ),
              centerTitle: true,
              actions: [
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: loggedInUser.profilePictureURL == null
                        ? AssetImage('images/generalProfile.jpeg')
                        : NetworkImage(loggedInUser.profilePictureURL!)
                            as ImageProvider,
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height / 10,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 50,
                    ),
                    Stack(
                      children: [
                        Center(
                          child: CircleAvatar(
                            radius: MediaQuery.of(context).size.height / 10,
                            backgroundImage: image == null
                                ? const AssetImage('images/generalProfile.jpeg')
                                : FileImage(image!) as ImageProvider,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        Positioned(
                          right: MediaQuery.of(context).size.width / 3,
                          bottom: 0,
                          child: Container(
                            height: MediaQuery.of(context).size.height / 20,
                            width: MediaQuery.of(context).size.width / 11,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.teal,
                              border: Border.all(
                                width: 4,
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                              ),
                            ),
                            child: InkWell(
                              onTap: () {
                                pickImageMethod();
                              },
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 25,
                    ),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 20,
                          right: 20,
                        ),
                        child: Text(
                          'Please set your group profile, name and description.',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff4E5152),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 20,
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 18,
                            right: 18,
                          ),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: TextFormField(
                              autofocus: false,
                              controller: nameController,
                              keyboardType: TextInputType.name,
                              onSaved: (value) {
                                nameController.text = value!;
                              },
                              decoration: kTextFieldDecoration.copyWith(
                                labelText: 'Group Name',
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                hintText: 'Group Name',
                              ),
                              style: const TextStyle(
                                fontSize: 20,
                                color: Color(0xff4E5152),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 30.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 18,
                            right: 18,
                          ),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: TextFormField(
                              autofocus: false,
                              controller: statusController,
                              keyboardType: TextInputType.text,
                              onSaved: (value) {
                                statusController.text = value!;
                              },
                              decoration: kTextFieldDecoration.copyWith(
                                labelText: 'Description',
                                hintText: 'Description',
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                              ),
                              style: const TextStyle(
                                fontSize: 20,
                                color: Color(0xff4E5152),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 20,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.height / 10,
                        horizontal: MediaQuery.of(context).size.width / 15,
                      ),
                      child: InkWell(
                        onTap: () async {
                          if (nameController.text.isEmpty) {
                            showSnackBar(msg: 'Name field can\'t be empty.');
                          } else if (statusController.text.isEmpty) {
                            showSnackBar(
                                msg: 'Description field can\'t be empty.');
                          } else {
                            if (image != null) {
                              await uploadImage().whenComplete(
                                () => showSnackBar(
                                    msg: 'Image Uploaded Successfully'),
                              );
                            }
                            await uploadGroupProfile().whenComplete(
                              () => showSnackBar(
                                  msg: 'Group Created Successfully'),
                            );
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => HomeScreen(),
                              ),
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xffE76F52),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                'Create Group',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    loggedInUser = await getData();
    setState(() {
      isLoading = false;
    });
  }

  pickImageMethod() async {
    setState(() {
      isLoading = true;
    });
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      isLoading = false;
    });
    if (pickedImage != null) {
      setState(() {
        image = File(pickedImage.path);
      });
    } else {
      showSnackBar(msg: 'Image not selected');
    }
  }

  showSnackBar({required String msg}) {
    final snackBar = SnackBar(
      content: Text(
        msg,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  uploadImage() async {
    setState(() {
      isLoading = true;
    });
    String profileId = DateTime.now().millisecondsSinceEpoch.toString();
    groupId = profileId + nameController.text;
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('${profileId}profilePicture')
        .child('profile_$profileId');
    await ref.putFile(image!);
    profilePictureURL = await ref.getDownloadURL();
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }
}

const kTextFieldDecoration = InputDecoration(
  hintText: 'Enter a value',
  contentPadding: EdgeInsets.only(bottom: 5.0, left: 5.0),
  enabledBorder: UnderlineInputBorder(
    borderSide: BorderSide(color: Colors.grey, width: 1),
  ),
  focusedBorder: UnderlineInputBorder(
    borderSide: BorderSide(color: Color(0xff4E5152), width: 2),
  ),
);
