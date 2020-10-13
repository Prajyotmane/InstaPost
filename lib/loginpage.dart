import 'dart:io';
import 'package:assignment_two/instapostfeed.dart';
import 'package:assignment_two/main.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'apiCalls.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _email = "", _password = "";
  final _formKey = GlobalKey<FormState>();

  bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    return (!regex.hasMatch(value)) ? false : true;
  }

  Future<bool> _saveUserDetails(String _email, String _password) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("USER_LOGGED_IN", true);
    prefs.setString("EMAIL", _email);
    prefs.setString("PASSWORD", _password);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Login"),
          backgroundColor: Colors.black,
        ),
        body: SingleChildScrollView(
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
                      decoration: InputDecoration(labelText: EMAIL),
                      validator: (value) {
                        if (value.isEmpty) {
                          return ERROR_TEXT;
                        } else if (validateEmail(value) == false) {
                          return "Email ID is invalid";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _email = value;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: PASSWORD),
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
                    Builder(
                      builder: (context) => Column(
                        children: [
                          Container(
                              padding: EdgeInsets.all(5.0),
                              child: RaisedButton(
                                  color: Theme.of(context).dividerColor,
                                  onPressed: () {
                                    print("Button pressed");
                                    if (_formKey.currentState.validate()) {
                                      _formKey.currentState.save();
                                      ApiCalls.logIn(_email, _password)
                                          .then((value) {
                                        if (value) {
                                          _saveUserDetails(_email, _password)
                                              .then((value) {
                                            final snackBar = SnackBar(
                                                content:
                                                    Text("Login successful"));
                                            Scaffold.of(context)
                                                .showSnackBar(snackBar);
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      MyApp()),
                                            );
                                          });
                                        } else {
                                          final snackBar = SnackBar(
                                              content: Text("Login Failed"));
                                          Scaffold.of(context)
                                              .showSnackBar(snackBar);
                                        }
                                      });
                                    }
                                  },
                                  child: Text("Login"))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
