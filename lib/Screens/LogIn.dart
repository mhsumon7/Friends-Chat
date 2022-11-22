import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Screens/homeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogIn extends StatefulWidget {
  const LogIn({Key? key}) : super(key: key);

  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool isLoading = false;

  Future<void> login({required String email, required String password}) async {
    try {
      setState(() {
        isLoading = true;
      });
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });
      if (e.code == 'user-not-found') {
        const snackBar = SnackBar(
          content: Text(
            'No user found for that email.',
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else if (e.code == 'wrong-password') {
        setState(() {
          isLoading = false;
        });
        const snackBar = SnackBar(
          content: Text(
            'Wrong password provided for that user.',
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else if (e.code == 'invalid-email') {
        const snackBar = SnackBar(
          content: Text('Invalid Email'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      final snackBar = SnackBar(
        content: Text(
          e.toString(),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height / 5,
                ),
                Image.asset(
                  "assets/campus_talk_logo.png",
                  height: MediaQuery.of(context).size.height / 7,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 14,
                ),
                const Padding(
                  padding: EdgeInsets.only(
                    left: 12.0,
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 50,
                      color: Color(0xff4E5152),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 14,
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 12,
                        right: 18,
                      ),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.email,
                              size: 30,
                              color: Color(0xff4E5152),
                            ),
                            const SizedBox(
                              width: 14,
                            ),
                            Expanded(
                              child: TextFormField(
                                autofocus: false,
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return ("Please enter your Email");
                                  }
                                  if (!RegExp(
                                          "^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                                      .hasMatch(value)) {
                                    return ("Please Enter valid Email");
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  emailController.text = value!;
                                },
                                decoration: kTextFieldDecoration.copyWith(
                                    hintText: 'Email ID'),
                                style: const TextStyle(
                                  fontSize: 24,
                                  color: Color(0xff4E5152),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 8.0,
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
                            const Icon(
                              Icons.lock,
                              size: 30,
                              color: Color(0xff4E5152),
                            ),
                            const SizedBox(
                              width: 14,
                            ),
                            Expanded(
                              child: TextFormField(
                                autofocus: false,
                                obscureText: true,
                                controller: passwordController,
                                validator: (value) {
                                  RegExp regex = RegExp(r'^.{6,}$');
                                  if (value!.isEmpty) {
                                    return ("Please enter you password");
                                  }
                                  if (!regex.hasMatch(value)) {
                                    return ("Password must contain at least 6 characters");
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  print(value);
                                  passwordController.text = value!;
                                },
                                decoration: kTextFieldDecoration.copyWith(
                                    hintText: 'Password'),
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
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 12,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 25.0,
                    right: 25,
                  ),
                  child: InkWell(
                    onTap: () async {
                      if (emailController.text.isEmpty) {
                        const snackBar = SnackBar(
                          content: Text(
                            'Email Can\'t be empty',
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                      if (passwordController.text.isEmpty) {
                        const snackBar = SnackBar(
                          content: Text(
                            'Password Can\'t be empty',
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      } else {
                        SharedPreferences pref =
                            await SharedPreferences.getInstance();
                        login(
                          email: emailController.text,
                          password: passwordController.text,
                        );
                        //It will save user email in email key
                        // By this we can check if this email is present in key then goto chat screen else login screen
                        pref.setString('email', emailController.text);
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
                            'LogIn',
                            style: TextStyle(
                              fontSize: 25,
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
