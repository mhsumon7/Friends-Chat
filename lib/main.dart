import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../Screens/homeScreen.dart';
import '../Screens/loginSignUp.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'offline_chat/devicesList.dart';
import 'offline_chat/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences pref = await SharedPreferences.getInstance();
  var email = pref.getString('email');
  runApp(talkin(
    email: email,
  ));
}

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (_) => Home());
    case 'send':
      return MaterialPageRoute(
          builder: (_) => DevicesListScreen(deviceType: DeviceType.sender));
    case 'recive':
      return MaterialPageRoute(
          builder: (_) => DevicesListScreen(deviceType: DeviceType.reciver));
    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
                child: Text('No route defined for ${settings.name}')),
          ));
  }
}//riyevo4325@teknowa.com
class talkin extends StatelessWidget {
  var email;
  talkin({Key? key, this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: generateRoute,
      initialRoute: '/',
      theme: ThemeData(
        primaryColor: Color(0xff06F1F2),
      ),
      home: email == null ? LoginSignUp() : HomeScreen(),
    );
  }
}