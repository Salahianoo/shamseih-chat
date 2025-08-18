import 'package:shamseih_chat/components/rounded_button.dart';
import 'login_screen.dart';
import 'registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:shamseih_chat/Firebase/firebase_notification.dart';

class WelcomeScreen extends StatefulWidget {
  static String id = 'welcome_screen';

  const WelcomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? controller;
  late Animation animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    animation = CurvedAnimation(parent: controller!, curve: Curves.decelerate);
    controller?.forward();
    controller?.addListener(() {
      setState(() {});
    });

    // Initialize Firebase notifications
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    await FirebaseNotification().init(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ignore: deprecated_member_use
      backgroundColor: Colors.cyan.withOpacity(controller?.value ?? 1.0),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                AnimatedBuilder(
                  animation: controller!,
                  builder: (context, child) {
                    double floatY =
                        10 *
                        (1 - animation.value) *
                        (animation.value < 0.5 ? 1 : -1);
                    return Transform.translate(
                      offset: Offset(0, floatY),
                      child: Hero(
                        tag: 'logo',
                        child: SizedBox(
                          height: animation.value * 50.0,
                          child: Image.asset('images/shamslogo.png'),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 60.0),
                AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'Shamseih Chat',
                      textStyle: TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.w900,
                        color: Colors.black54,
                      ),
                      speed: Duration(milliseconds: 200),
                      cursor: '|',
                    ),
                  ],
                  repeatForever: true,
                  pause: Duration(seconds: 3),
                ),
              ],
            ),
            SizedBox(height: 48.0),
            RoundedButton(
              title: 'Log in',
              color: Colors.lightBlueAccent,
              onPressed: () {
                Navigator.pushNamed(context, LoginScreen.id);
              },
            ),
            RoundedButton(
              title: 'Register',
              color: Colors.blueAccent,
              onPressed: () {
                Navigator.pushNamed(context, RegistrationScreen.id);
              },
            ),
            SizedBox(height: 20.0),
            TextButton(
              onPressed: () async {
                await FirebaseNotification().init(context);
              },
              child: Text(
                'Show FCM Token',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16.0,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
