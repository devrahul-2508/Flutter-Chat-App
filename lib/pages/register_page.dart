import 'package:chat_app/pages/home_page.dart';
import 'package:chat_app/pages/login_page.dart';
import 'package:chat_app/service/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../helper/helper_function.dart';
import '../service/database_service.dart';
import '../widgets/widgets.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isLoading = false;
  final formKey = GlobalKey<FormState>();
  String email = " ";
  String password = " ";
  String username = " ";
  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: (_isLoading)
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).accentColor),
            )
          : SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
                child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Groupie",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Create your account to chat and explore",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w400),
                        ),
                        Image.asset("assets/register.png"),
                        TextFormField(
                          decoration: textInputDecoration.copyWith(
                              labelText: "Username",
                              prefixIcon: Icon(
                                Icons.person,
                                color: Theme.of(context).accentColor,
                              )),
                          onChanged: (value) {
                            setState(() {
                              username = value;
                            });
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          decoration: textInputDecoration.copyWith(
                              labelText: "Email",
                              prefixIcon: Icon(
                                Icons.email,
                                color: Theme.of(context).accentColor,
                              )),
                          onChanged: (value) {
                            setState(() {
                              email = value;
                            });
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          obscureText: true,
                          decoration: textInputDecoration.copyWith(
                              labelText: "Password",
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Theme.of(context).accentColor,
                              )),
                          onChanged: ((value) {
                            setState(() {
                              password = value;
                            });
                          }),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: Theme.of(context).accentColor,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20))),
                              onPressed: () {
                                register();
                              },
                              child: Text("Register")),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text.rich(
                          TextSpan(text: "Already have an account?", children: [
                            TextSpan(
                                text: " Login Here",
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    nextScreenReplace(context, LoginPage());
                                  },
                                style: TextStyle(
                                    color: Theme.of(context).accentColor,
                                    fontSize: 14))
                          ]),
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        )
                      ],
                    )),
              ),
            ),
    );
  }

  register() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      await authService
          .registerUserwithEmailAndPassword(username, email, password)
          .then(((value) async {
        if (value == true) {
          // saving the values to our shared preferences
          await HelperFunctions.saveUserLoggedInStatus(true);
          await HelperFunctions.saveUserEmailSF(email);
          await HelperFunctions.saveUserNameSF(username);
          nextScreenReplace(context, const HomePage());
        } else {
          showSnackbar(context, Colors.red, value);
          _isLoading = false;
        }
      }));
    }
  }
}
