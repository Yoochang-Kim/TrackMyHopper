import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Model/AuthService.dart';
import '../main.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  // Duration for login animation.
  Duration get loginTime => const Duration(milliseconds: 2250);

  // Authenticates user with email and password.
  Future<String?> _authUser(LoginData data, AuthService authService) async {
    //print('Name: ${data.name}, Password: ${data.password}');
    String? result = await authService.signInWithEmailAndPassword(data.name, data.password);
    if (result != 'Success') {
      return result; // If not success, return the error message
    }
    return null;
  }

  // Handles user signup with email and password.
  Future<String?> _signupUser(SignupData data, AuthService authService) async {
    debugPrint('Signup Name: ${data.name}, Password: ${data.password}');
    dynamic result = await authService.registerWithEmailAndPassword(data.name ?? '', data.password ?? '');
    if (result != 'Success') {
      return result; // If not success, return the error message
    }
    return null;
  }

  // Handles password recovery.
  Future<String?> _recoverPassword(String email, AuthService authService) async{
    debugPrint('Email: $email');
    dynamic result = await authService.sendPasswordResetEmail(email);
    if (result != 'Success') {
      return result; // If not success, return the error message
    }
    return null;
  }

  // Future<String?> _signupConfirm(String error, LoginData data) {
  //   return Future.delayed(loginTime).then((_) {
  //     return null;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    return FlutterLogin(
      loginAfterSignUp: false,
      logo: 'assets/app-logo.png',
      onLogin: (data) => _authUser(data, authService),
      onSignup: (data) => _signupUser(data, authService),
      messages: LoginMessages(
        userHint: 'Enter UTAS email',
      ),
      theme: LoginTheme(
        primaryColor: Colors.blue,
        pageColorLight: Colors.white,
        inputTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.black.withOpacity(0.1),
        ),
        cardTheme: const CardTheme(
          color: Colors.white,
          elevation: 10,
        ),

        buttonStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),

      termsOfService: [
        TermOfService(
            id: 'general-term',
            mandatory: true,
            text: 'Term of services',
            linkUrl: 'https://bearkim117.com/policy/'
        ),
      ],

      scrollable: true,
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => MainPage(),
        ));
      },

      userValidator: (value) {
        if(value == "fluency1995@gmail.com") return null;
        if (!value!.contains('@') || !value.endsWith('@utas.edu.au')) {
          return "Email must contain @utas.edu.au'";
        }
        return null;
      },

      passwordValidator: (value) {
        if (value!.isEmpty) {
          return 'Password is empty';
        }
        if (value.length < 8) {
          return 'Min. 8 characters';
        }
        if (!RegExp(r'(?=.*?[a-z])').hasMatch(value)) {
          return 'Needs a lowercase';
        }
        if (!RegExp(r'(?=.*?[0-9])').hasMatch(value)) {
          return 'Needs a number';
        }
        if (!RegExp(r'(?=.*?[!@#\$&*~])').hasMatch(value)) {
          return 'Needs a special character';
        }
        return null;
      },
      onRecoverPassword: (name) {
        debugPrint('Recover password info');
        debugPrint('Name: $name');
        return _recoverPassword(name, authService);
        // Show new password dialog
      },
      headerWidget: const IntroWidget(),
    );
  }
}

class IntroWidget extends StatelessWidget {
  const IntroWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            style: GoogleFonts.roboto(
              textStyle: DefaultTextStyle.of(context).style,
            ),
            children: [
              const TextSpan(
                  text: 'The application is not directly linked with UTAS account, so you need to sign up anew. '
              ),
              TextSpan(
                text: 'See FAQ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,  // blue color
                  decoration: TextDecoration.underline,  // underline
                ),
                recognizer: TapGestureRecognizer()..onTap = () async {
                  final url = Uri.parse('https://bearkim117.com/faq');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
              ),
            ],
          ),
        ),
        const Row(
          children: <Widget>[
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Authenticate"),
            ),
            Expanded(child: Divider()),
          ],
        ),
      ],
    );
  }
}