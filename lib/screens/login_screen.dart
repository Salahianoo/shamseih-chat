import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:flutter/material.dart';
import 'package:shamseih_chat/components/rounded_button.dart';
import 'package:shamseih_chat/screens/chat_screen.dart';
import '../core/constants/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Firebase/firebase_notification.dart';
import '../core/utils/secure_storage_service.dart';

class LoginScreen extends StatefulWidget {
  static String id = 'login_screen';

  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseNotification _firebaseNotification = FirebaseNotification();
  final SecureStorageService _secureStorageService = SecureStorageService();
  String email = '';
  String password = '';
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool showSpinner = false;
  bool showPassword = false;
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
                    height: 200.0,
                    child: Image.asset('images/shamslogo.png'),
                  ),
                ),
              ),
              SizedBox(height: 48.0),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  email = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter your email',
                ),
              ),
              SizedBox(height: 8.0),
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
              SizedBox(height: 24.0),
              RoundedButton(
                title: 'Log In',
                color: Colors.lightBlueAccent,
                onPressed: () async {
                  setState(() {
                    showSpinner = true;
                  });
                  try {
                    // ignore: unused_local_variable
                    final user = await _auth.signInWithEmailAndPassword(
                      email: email,
                      password: password,
                    );
                    await _firebaseNotification.init(null);
                    // ignore: use_build_context_synchronously
                    Navigator.pushNamed(context, ChatScreen.id);
                  } on FirebaseAuthException catch (e) {
                    String message;
                    if (e.code == 'user-not-found') {
                      message = 'No user found for that email.';
                    } else if (e.code == 'wrong-password') {
                      message = 'Incorrect password.';
                    } else {
                      message = 'Login failed: ${e.message}';
                    }
                    ScaffoldMessenger.of(
                      // ignore: use_build_context_synchronously
                      context,
                    ).showSnackBar(SnackBar(content: Text(message)));
                  } catch (e) {
                    ScaffoldMessenger.of(
                      // ignore: use_build_context_synchronously
                      context,
                    ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
                  } finally {
                    setState(() {
                      showSpinner = false;
                    });
                  }
                },
              ),
              SizedBox(height: 12.0),
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
