import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../Screens/homeScreen.dart';
import 'package:image_picker/image_picker.dart';

class UploadProfile extends StatefulWidget {
  String? userId;
  UploadProfile({required this.userId, Key? key}) : super(key: key);

  @override
  _UploadProfileState createState() => _UploadProfileState();
}

class _UploadProfileState extends State<UploadProfile> {
  late String? profilePictureURL;
  TextEditingController statusController = TextEditingController();
  File? image;
  final imagePicker = ImagePicker();
  bool isLoading = false;

  pickImageMethod() async {
    setState(() {
      isLoading = true;
    });
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);
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

  // uploading file to firestore storage and getting url of that image
  Future uploadProfile() async {
    setState(() {
      isLoading = true;
    });
    String profileId = DateTime.now().microsecondsSinceEpoch.toString();
    Reference ref = FirebaseStorage.instance
        .ref()
        .child("${widget.userId}profilePicture")
        .child('profile_$profileId');
    await ref.putFile(image!);
    profilePictureURL = await ref.getDownloadURL();

    // saving URL and status to firestore database
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .update(
      {
        'profilePictureURL': profilePictureURL,
        'status': statusController.text,
      },
    );
    setState(() {
      isLoading = false;
    });
  }

  showSnackBar({required String msg}) {
    final snackBar = SnackBar(
      content: Text(
        msg,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height / 7,
                ),
                Stack(
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: MediaQuery.of(context).size.height / 8,
                        backgroundImage: image == null
                            ? const AssetImage('images/generalProfile.jpeg')
                            : FileImage(image!) as ImageProvider,
                      ),
                    ),
                    Positioned(
                      bottom: 5,
                      right: MediaQuery.of(context).size.width / 4,
                      child: InkWell(
                        onTap: () {
                          pickImageMethod();
                        },
                        child: const Icon(
                          Icons.add_photo_alternate,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 18,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 12.0,
                    right: 18,
                  ),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 14,
                        ),
                        Expanded(
                          child: TextFormField(
                            autofocus: false,
                            controller: statusController,
                            onSaved: (value) {
                              statusController.text = value!;
                            },
                            decoration: kTextFieldDecoration.copyWith(
                                hintText: 'Status'),
                            style: const TextStyle(
                              color: Color(0xff4E5152),
                              fontSize: 25,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 20,
                ),
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                    ),
                    child: Text(
                      'Please set your profile picture and status',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff4E5152),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 5,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 25.0,
                    right: 25,
                  ),
                  child: InkWell(
                    onTap: () async {
                      if (image != null) {
                        if (statusController.text.isEmpty) {
                          showSnackBar(msg: 'Status can\'t be empty');
                        } else {
                          await uploadProfile().whenComplete(
                            () => showSnackBar(
                                msg: 'Image Uploaded Successfully'),
                          );
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(),
                            ),
                          );
                        }
                      } else {
                        showSnackBar(msg: 'Please select an image');
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            'Save and Continue',
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
                SizedBox(
                  height: MediaQuery.of(context).size.height / 28,
                ),
                // Padding(
                //   padding: const EdgeInsets.only(
                //     left: 25.0,
                //     right: 25,
                //   ),
                //   child: InkWell(
                //     onTap: () async {
                //       if (statusController.text.isEmpty) {
                //         showSnackBar(msg: 'Status field can\'t be empty');
                //       } else {
                //         Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //             builder: (context) => HomeScreen(),
                //           ),
                //         );
                //       }
                //     },
                //     child: Container(
                //       decoration: BoxDecoration(
                //         color: Colors.blue,
                //         borderRadius: BorderRadius.circular(20),
                //       ),
                //       child: const Padding(
                //         padding: EdgeInsets.all(8.0),
                //         child: Center(
                //           child: Text(
                //             'Skip',
                //             style: TextStyle(
                //               fontSize: 20,
                //               color: Colors.white,
                //             ),
                //           ),
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
            isLoading
                ? Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.black12,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
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
