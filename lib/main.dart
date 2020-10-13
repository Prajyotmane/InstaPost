import 'dart:io';
import 'package:assignment_two/instapostfeed.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';
import 'apiCalls.dart';
import 'loginpage.dart';

void main() {
  HttpOverrides.global = new MyHttpOverrides();
  runApp(MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _firstName = "",
      _lastName = "",
      _nickName = "",
      _email = "",
      _password = "",
      _confirmPassword = "";
  final _formKey = GlobalKey<FormState>();

  bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    return (!regex.hasMatch(value)) ? false : true;
  }

  Future<bool> _isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("USER_LOGGED_IN");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text("InstaPost"),
              backgroundColor: Colors.black,
            ),
            body: FutureBuilder(
                future: _isUserLoggedIn(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.data == true) {
                      return InstaPostFeed();
                    } else {
                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  TextFormField(
                                    decoration:
                                        InputDecoration(labelText: FIRST_NAME),
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return ERROR_TEXT;
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      _firstName = value;
                                    },
                                  ),
                                  TextFormField(
                                    decoration:
                                        InputDecoration(labelText: LAST_NAME),
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return ERROR_TEXT;
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      _lastName = value;
                                    },
                                  ),
                                  TextFormField(
                                    decoration:
                                        InputDecoration(labelText: NICKNAME),
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return ERROR_TEXT;
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      _nickName = value;
                                    },
                                  ),
                                  TextFormField(
                                    decoration:
                                        InputDecoration(labelText: EMAIL),
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return ERROR_TEXT;
                                      } else if (validateEmail(value) ==
                                          false) {
                                        return "Email ID is invalid";
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      _email = value;
                                    },
                                  ),
                                  TextFormField(
                                    decoration:
                                        InputDecoration(labelText: PASSWORD),
                                    obscureText: true,
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return ERROR_TEXT;
                                      } else if (value.length < 3) {
                                        return "Password length must be at least 3";
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      _password = value;
                                    },
                                  ),
                                  TextFormField(
                                    decoration: InputDecoration(
                                        labelText: CONFIRM_PASSWORD),
                                    obscureText: true,
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return ERROR_TEXT;
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      _confirmPassword = value;
                                    },
                                  ),
                                  Builder(
                                    builder: (context) => Column(
                                      children: [
                                        Container(
                                            padding: EdgeInsets.all(5.0),
                                            child: Column(children: [
                                              RaisedButton(
                                                  color: Theme.of(context)
                                                      .dividerColor,
                                                  onPressed: () {
                                                    print("Button pressed");
                                                    if (_formKey.currentState
                                                        .validate()) {
                                                      _formKey.currentState
                                                          .save();
                                                      if (_password ==
                                                          _confirmPassword) {
                                                        ApiCalls.signUp(
                                                                _firstName,
                                                                _lastName,
                                                                _nickName,
                                                                _email,
                                                                _password)
                                                            .then((value) {
                                                          if (value == "") {
                                                            final snackBar = SnackBar(
                                                                content: Text(
                                                                    "Signup successful"));
                                                            Scaffold.of(context)
                                                                .showSnackBar(
                                                                    snackBar);
                                                          } else {
                                                            final snackBar =
                                                                SnackBar(
                                                                    content: Text(
                                                                        value));
                                                            Scaffold.of(context)
                                                                .showSnackBar(
                                                                    snackBar);
                                                          }
                                                        });
                                                      } else {
                                                        final snackBar = SnackBar(
                                                            content: Text(
                                                                "Confirm password must match with Password"));
                                                        Scaffold.of(context)
                                                            .showSnackBar(
                                                                snackBar);
                                                      }
                                                    }
                                                  },
                                                  child: Text("Sign Up")),
                                              RaisedButton(
                                                  color: Theme.of(context)
                                                      .dividerColor,
                                                  onPressed: () {
                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              LoginPage()),
                                                    );
                                                    //TODO
                                                  },
                                                  child: Text("Login")),
                                            ])),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  } else {
                    return Center(
                        child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ));
                  }
                })));
  }
}
