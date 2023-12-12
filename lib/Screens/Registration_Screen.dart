import 'package:flash_chat/Constants.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/Components/RoundedButton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Chat_Screen.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = 'Registration_Screen';

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  bool Showspinner = false;
  late String email;
  late String password;
  // Future _auth()async{ final UserCredential userCredential = await FirebaseAuth.instance
  //     .createUserWithEmailAndPassword(email: email, password: password);}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: Showspinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/bb.png'),
                  ),
                ),
              ),
              const SizedBox(
                height: 48.0,
              ),
              TextField(
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    //Do something with the user input.
                    email = value;
                  },
                  decoration:
                      kInputTextFields.copyWith(hintText: 'Enter your email')),
              const SizedBox(
                height: 8.0,
              ),
              TextField(
                  obscureText: true,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    //Do something with the user input.
                    password = value;
                  },
                  decoration: kInputTextFields.copyWith(
                      hintText: 'Enter your password')),
              const SizedBox(
                height: 24.0,
              ),
              RoundedButton(Color(0xffF6C221), 'Register', () async {
                setState(() {
                  Showspinner = true;
                });
                try {
                  final newUser = await _auth.createUserWithEmailAndPassword(
                      email: email, password: password);
                  if (newUser != null) {
                    Navigator.pushNamed(context, ChatScreen.id);
                  }
                  setState(() {
                    Showspinner = false;
                  });
                } catch (e) {
                  print(e);
                }
              })
            ],
          ),
        ),
      ),
    );
  }
}
