import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Models/userModel.dart';
import '../Screens/selectContact.dart';
import '../Screens/updateProfile.dart';
import '../group_chats/group_chat_screen.dart';
import '../offline_chat/home.dart';
import '../pages/chatHomePage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  String? profilePictureURL;

  getData() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get()
        .then(
          (value) => {
            loggedInUser = UserModel.fromMap(value),
          },
        );
    setState(() {
      if (loggedInUser.profilePictureURL != null) {
        profilePictureURL = loggedInUser.profilePictureURL;
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  int selectedIndex = 0;
  final List<Widget> _screens = <Widget>[
    chatHomePage(),
    Container(),
    UpdateProfile(),
    SelectContact(),
    Home(),
  ];

  void updateIndex(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GroupChatHomeScreen(),
        ),
      );
    } else {
      setState(() {
        selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading: TextButton(
        //   onPressed: () {Navigator.of(context).push(MaterialPageRoute(builder: (_)=>searchScreen(),),);},
        //   child: Padding(
        //     padding: const EdgeInsets.all(2.0),
        //     child: Container(
        //       decoration: BoxDecoration(
        //         color: Color(0xffE2E2E2),
        //         borderRadius: BorderRadius.circular(10),
        //       ),
        //       child: const Padding(
        //         padding: EdgeInsets.all(6.0),
        //         child: Icon(
        //           Icons.search,
        //           color: Color(0xff4E5152),
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
        backgroundColor: Colors.blue,
        title: const Text(
          'TALK-in',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              radius: 28,
              backgroundImage: profilePictureURL != null
                  ? NetworkImage(profilePictureURL!) as ImageProvider
                  : AssetImage('images/generalProfile.jpeg'),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedIconTheme: const IconThemeData(color: Colors.blue),
        selectedLabelStyle: const TextStyle(color: Colors.blue),
        unselectedIconTheme: const IconThemeData(
          color: Color(0xff4E5152),
        ),
        unselectedLabelStyle: const TextStyle(
          color: Color(0xff4E5152),
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              CupertinoIcons.chat_bubble_2_fill,
            ),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              CupertinoIcons.group_solid,
            ),
            label: 'Group',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              CupertinoIcons.profile_circled,
            ),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              CupertinoIcons.person_add_solid,
            ),
            label: 'Contacts',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              CupertinoIcons.bluetooth,
            ),
            label: 'Offline Chat',
          ),
        ],
        currentIndex: selectedIndex,
        onTap: updateIndex,
      ),
      body: _screens[selectedIndex],
    );
  }
}
