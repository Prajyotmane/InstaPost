import 'dart:io';
import 'package:assignment_two/CacheFileManager.dart';
import 'package:assignment_two/DBHandler.dart';
import 'package:assignment_two/DeviceStatus.dart';
import 'package:assignment_two/InstaPostFeed.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'LoadingScreen.dart';
import 'constants.dart';
import 'APICalls.dart';
import 'LoginPage.dart';

void main() {
  HttpOverrides.global = new MyHttpOverrides();
  runApp(MyApp());
}

//Configuring the HTTPs certificate for the client
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
      _confirmPassword = "",
      _pendingPostMessage = "Checking for pending posts";
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    CacheFileManager.init();
  }

  //This function handles the pending post upload operation if any
  Future<Widget> _uploadPendingPost(List mapFromDB) async {
    bool uploadResponse;
    for (Map<String, dynamic> eachPost in mapFromDB) {
      String image = eachPost["image"];
      String postText = eachPost["posttext"];
      List<String> postHashTags = eachPost["hashtags"].split(" ");

      int id =
          await ApiCalls.uploadPost(_email, _password, postText, postHashTags);
      if (id == -1) {
        print("Error occurred while uploading the post"); //Debug message
        return InstaPostFeed();
      } else {
        print("Post ID is " + id.toString());
        if (image.length > 0) {
          uploadResponse =
              await ApiCalls.uploadImage(_email, _password, id, image);
        } else {
          uploadResponse = true;
        }
      }
      if (uploadResponse == false) {
        break;
      }
    }
    //if pending posts have been uploaded, delete the entries from the SQLite database
    if (uploadResponse) {
      print("All good in upload"); //Debug message
      int deletedRows = await DBProvider.db.deleteAll();
      if (deletedRows > 0) {
        print("deleted successfully"); //Debug message
        return InstaPostFeed();
      } else {
        print("Database delete failed"); //Debug message
        return InstaPostFeed();
      }
    } else {
      print("Post upload interrupted"); //Debug message
      return InstaPostFeed();
    }
  }

  bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    return (!regex.hasMatch(value)) ? false : true;
  }

  //Check if user is logged in by checking the sharedpreferences data
  Future<bool> _isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    bool response = prefs.getBool("USER_LOGGED_IN");
    if (response) {
      _email = prefs.getString("EMAIL");
      _password = prefs.getString("PASSWORD");
    }
    print("Response: " + response.toString()); //Debug message
    return response;
  }

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

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
                      return FutureBuilder(
                        future: DeviceStatus.dstate.isDeviceOnline(),
                        builder: (context, isOnline) {
                          if (isOnline.connectionState ==
                              ConnectionState.done) {
                            if (isOnline.data) {
                              return FutureBuilder(
                                  future: DBProvider.db.getPendingPosts(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      if (snapshot.data.length == 0) {
                                        return InstaPostFeed();
                                      } else {
                                        return FutureBuilder(
                                          future:
                                              _uploadPendingPost(snapshot.data),
                                          builder:
                                              (context, postUploadSnapshot) {
                                            _pendingPostMessage =
                                                "Uploading pending posts";
                                            if (postUploadSnapshot
                                                    .connectionState ==
                                                ConnectionState.done) {
                                              return postUploadSnapshot.data;
                                            } else {
                                              return SimpleDialog(
                                                  backgroundColor: Colors.black,
                                                  children: <Widget>[
                                                    Center(
                                                      child: Column(children: [
                                                        CircularProgressIndicator(),
                                                        SizedBox(
                                                          height: 20,
                                                        ),
                                                        Text(
                                                          _pendingPostMessage,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        )
                                                      ]),
                                                    )
                                                  ]);
                                            }
                                          },
                                        );
                                      }
                                    } else {
                                      return SimpleDialog(
                                          backgroundColor: Colors.black,
                                          children: <Widget>[
                                            Center(
                                              child: Column(children: [
                                                CircularProgressIndicator(),
                                                SizedBox(
                                                  height: 20,
                                                ),
                                                Text(
                                                  "Checking Pending Posts",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                )
                                              ]),
                                            )
                                          ]);
                                    }
                                  });
                            } else {
                              return InstaPostFeed();
                            }
                          } else {
                            return SimpleDialog(
                                backgroundColor: Colors.black,
                                children: <Widget>[
                                  Center(
                                    child: Column(children: [
                                      CircularProgressIndicator(),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        "Checking connection",
                                        style: TextStyle(color: Colors.white),
                                      )
                                    ]),
                                  )
                                ]);
                          }
                        },
                      );
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
                                                    if (_formKey.currentState
                                                        .validate()) {
                                                      _formKey.currentState
                                                          .save();
                                                      if (_password ==
                                                          _confirmPassword) {
                                                        Dialogs
                                                            .showLoadingDialog(
                                                                context,
                                                                _keyLoader);
                                                        ApiCalls.signUp(
                                                                _firstName,
                                                                _lastName,
                                                                _nickName,
                                                                _email,
                                                                _password)
                                                            .then((value) {
                                                          if (value == "") {
                                                            Navigator.of(
                                                                    _keyLoader
                                                                        .currentContext,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop();
                                                            final snackBar = SnackBar(
                                                                content: Text(
                                                                    "Signup successful"));
                                                            Scaffold.of(context)
                                                                .showSnackBar(
                                                                    snackBar);
                                                          } else {
                                                            Navigator.of(
                                                                    _keyLoader
                                                                        .currentContext,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop();
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
                    return SimpleDialog(
                        backgroundColor: Colors.black,
                        children: <Widget>[
                          Center(
                            child: Column(children: [
                              CircularProgressIndicator(),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                "Please wait",
                                style: TextStyle(color: Colors.white),
                              )
                            ]),
                          )
                        ]);
                  }
                })));
  }
}
