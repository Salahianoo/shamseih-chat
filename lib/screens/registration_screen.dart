import 'package:flutter/material.dart';
import 'package:shamseih_chat/components/rounded_button.dart';
import 'package:shamseih_chat/screens/chat_screen.dart';
import '../core/constants/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../Firebase/firebase_notification.dart';
import '../core/utils/secure_storage_service.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class RegistrationScreen extends StatefulWidget {
  static String id = 'registration_screen';

  const RegistrationScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool showSpinner = false;
  String email = '';
  String password = '';
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool showPassword = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseNotification _firebaseNotification = FirebaseNotification();
  final SecureStorageService _secureStorageService = SecureStorageService();
  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  Future<void> _loadCredentials() async {
    final creds = await _secureStorageService.readCredentials();
    setState(() {
      email = creds['email'] ?? '';
      password = creds['password'] ?? '';
      emailController.text = email;
      passwordController.text = password;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: SizedBox(
                    height: 200.h,
                    child: Image.asset('images/shamslogo.png'),
                  ),
                ),
              ),
              SizedBox(height: 48.h),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  email = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter your E-mail',
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: passwordController,
                obscureText: !showPassword,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  password = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter your password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      showPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              RoundedButton(
                title: 'Register',
                color: Colors.blueAccent,
                onPressed: () async {
                  setState(() {
                    showSpinner = true;
                  });
                  if (email.isEmpty || password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please enter email and password'),
                      ),
                    );
                    return;
                  }
                  try {
                    final newUser = await _auth.createUserWithEmailAndPassword(
                      email: email,
                      password: password,
                    );
                    // ignore: unnecessary_null_comparison
                    if (newUser != null) {
                      // Initialize Firebase notifications after successful registration
                      await _firebaseNotification.init(null);

                      // ignore: use_build_context_synchronously
                      Navigator.pushNamed(context, ChatScreen.id);
                    }
                    setState(() {
                      showSpinner = false;
                    });
                  } catch (e) {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Registration failed: $e')),
                    );
                  }
                },
              ),
              SizedBox(height: 12.h),
              RoundedButton(
                title: 'Save',
                color: Colors.green,
                onPressed: () async {
                  if (email.isEmpty || password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Email and password cannot be empty!'),
                      ),
                    );
                    return;
                  }
                  await _secureStorageService.saveCredentials(email, password);
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Credentials saved securely!')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
