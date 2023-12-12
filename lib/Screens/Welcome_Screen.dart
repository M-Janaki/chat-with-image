import 'package:flash_chat/Screens/Login_Screen.dart';
import 'package:flash_chat/Screens/Registration_Screen.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flash_chat/Components/RoundedButton.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'Welcome_Screen';
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation animation;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = AnimationController(
      vsync: this,
      //upperBound: 1,
      duration: Duration(seconds: 1),
    );
    animation = CurvedAnimation(parent: controller, curve: Curves.decelerate);
    controller.forward();
    controller.addListener(
      () {
        setState(() {});
        // print(animation.value);
      },
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      //Color(0xffF8F3B9).withOpacity(controller.value),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Container(
                    height: 150,
                    child: Image.asset('images/bb.png'),
                  ),
                ),
                ColorizeAnimatedTextKit(
                  text: ['Bee Chat'],
                  textStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 40.0,
                    fontWeight: FontWeight.w900,
                  ),
                  colors: [
                    Color(0xFF3E2723),
                    Color(0xFFC6FF00),
                    Colors.yellow,
                    Color(0xFFE65100)
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            RoundedButton(
              Color(0xffF6C221),
              'Log In',
              () {
                Navigator.pushNamed(context, LoginScreen.id);
              },
            ),
            RoundedButton(
              Color(0xFF5C3600),
              'Register',
              () {
                Navigator.pushNamed(context, RegistrationScreen.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
