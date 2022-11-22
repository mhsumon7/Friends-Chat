import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../Models/userModel.dart';
import '../Screens/homeScreen.dart';
import '../Screens/loginSignUp.dart';
import '../offline_chat/home.dart';
import '../pages/chatHomePage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({Key? key}) : super(key: key);

  @override
  _UpdateProfileState createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController nameController;
  late TextEditingController statusController;
  String? profilePictureURL;

  late UserModel loggedInUser;
  File? image;
  bool isLoading = false;
  getCurrentUser() async {
    setState(() {
      isLoading = true;
    });
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) => {
              loggedInUser = UserModel.fromMap(value),
              emailController = TextEditingController(text: loggedInUser.email),
              passwordController = TextEditingController(),
              nameController = TextEditingController(text: loggedInUser.name),
              statusController =
                  TextEditingController(text: loggedInUser.status),
            });
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

  Future uploadImage() async {
    setState(() {
      isLoading = true;
    });
    String profileId = DateTime.now().microsecondsSinceEpoch.toString();
    Reference ref = FirebaseStorage.instance
        .ref()
        .child("${loggedInUser.uid}profilePicture")
        .child('profile_$profileId');
    await ref.putFile(image!);
    profilePictureURL = await ref.getDownloadURL();
  }

  updateDetails(String email, String password) async {
    // Create a credential
    AuthCredential credential =
        EmailAuthProvider.credential(email: email, password: password);
    // Reauthenticate
    try {
      setState(() {
        isLoading = true;
      });
      await FirebaseAuth.instance.currentUser!
          .reauthenticateWithCredential(credential);

      if (image != null) {
        await uploadImage();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(loggedInUser.uid)
            .update({
          'name': nameController.text,
          'status': statusController.text,
          'profilePictureURL': profilePictureURL,
        });
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(loggedInUser.uid)
            .update({
          'name': nameController.text,
          'status': statusController.text,
        });
      }
      passwordController.clear();
      setState(() {
        isLoading = false;
      });
      showSnackBar(msg: 'Details updated successfully');
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });
      if (e.code == 'wrong-password') {
        showSnackBar(msg: 'Incorrect password');
      }
    } catch (e) {
      showSnackBar(msg: e.toString());
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: Container(
              // height: MediaQuery.of(context).size.height,
              // color: Colors.black12,
              child: const CircularProgressIndicator(),
            ),
          )
        : SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height / 50,
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
                              ? loggedInUser.profilePictureURL == null
                                  ? const AssetImage(
                                      'images/generalProfile.jpeg')
                                  : NetworkImage(
                                          loggedInUser.profilePictureURL!)
                                      as ImageProvider
                              : FileImage(image!) as ImageProvider,
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
                              color: Theme.of(context).scaffoldBackgroundColor,
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
                    height: MediaQuery.of(context).size.height / 30,
                  ),
                  Text(
                    loggedInUser.email!,
                    style: TextStyle(
                      fontSize: 25,
                      color: Color(0xff4E5152),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 14,
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
                              labelText: 'Name',
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
                              labelText: 'Status',
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
                            obscureText: true,
                            controller: passwordController,
                            keyboardType: TextInputType.name,
                            onSaved: (value) {
                              passwordController.text = value!;
                            },
                            decoration: kTextFieldDecoration.copyWith(
                                labelText: 'Password',
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                hintText: 'Enter password to update details'),
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
                    height: MediaQuery.of(context).size.height / 13,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 25.0,
                            right: 25,
                          ),
                          child: InkWell(
                            onTap: () {
                              if (passwordController.text.isEmpty) {
                                showSnackBar(
                                    msg:
                                        'Please provide password to update details');
                              } else {
                                updateDetails(loggedInUser.email!,
                                    passwordController.text);
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
                                    'Update',
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
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 25.0,
                            right: 25,
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomeScreen(),
                                ),
                              );
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
                                    'Cancel',
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
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28)
                      ),
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    onPressed: () async {
                      try {
                        await FirebaseAuth.instance.signOut().then((value) => {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginSignUp(),
                              ),
                                  (route) => false),
                        });
                        SharedPreferences pref = await SharedPreferences.getInstance();
                        pref.remove('email');
                      } catch (e) {
                        final snackBar = SnackBar(
                          content: Text(
                            e.toString(),
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    },
                    child: Container(
                      height: 50,
                      width: 70,
                      child: Center(child: Text('Sign Out')),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}

const kTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.only(bottom: 5.0, left: 5.0),
  labelStyle: TextStyle(
    color: Colors.black,
  ),
  enabledBorder: UnderlineInputBorder(
    borderSide: BorderSide(color: Colors.grey, width: 1),
  ),
  focusedBorder: UnderlineInputBorder(
    borderSide: BorderSide(color: Color(0xff4E5152), width: 2),
  ),
);




