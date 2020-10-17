import 'dart:convert';
import 'dart:io';
import 'package:assignment_two/APICalls.dart';
import 'package:assignment_two/DBHandler.dart';
import 'package:assignment_two/DeviceStatus.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hashtagable/hashtagable.dart';

import 'LoadingScreen.dart';
import 'main.dart';

class MakeAPost extends StatefulWidget {
  @override
  _MakeAPostState createState() => _MakeAPostState();
}

class _MakeAPostState extends State<MakeAPost> {
  File _image;
  String _postText, _textErrorText, _hashTagErrorText;
  bool _textError = false, isConnected = true;
  List<String> _hashTags;
  Widget show = Container();
  final hashTagController = TextEditingController(),
      postController = TextEditingController();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  Future<List> _getUserCredentials() async {
    List<String> userCreds = new List();
    final prefs = await SharedPreferences.getInstance();
    userCreds.add(prefs.getString("EMAIL"));
    userCreds.add(prefs.getString("PASSWORD"));
    print(userCreds);
    return userCreds;
  }

  Future<bool> _userLogout() async {
    final prefs = await SharedPreferences.getInstance();
    bool res = await prefs.clear();
    await DBProvider.db.deleteAll();
    return res;
  }

  final picker = ImagePicker();

  _getImage() async {
    final PickedFile pickedFile = await picker.getImage(
        source: ImageSource.gallery, imageQuality: 50, maxWidth: 400.0);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  bool _validatePostFields() {
    _postText = hashTagController.text;
    _hashTags = extractHashTags(_postText);

    print(_postText);
    print(_hashTags);

    if (_postText.length == 0) {
      setState(() {
        _textError = true;
        _textErrorText = "Post must contain text";
      });
    } else if (_postText.length > 140) {
      setState(() {
        _textError = true;
        _textErrorText = "Post must not contain more than 140 characters";
      });
    } else {
      setState(() {
        _textError = false;
      });
    }

    if (_hashTags.length == 0) {
      setState(() {
        _textError = true;
        _textErrorText = "Post must have some hashtags";
      });
    } else {
      setState(() {
        _textError = false;
      });
    }
    print(_textError);
    return !_textError;
  }

  Future<bool> _uploadPost(String email, String password) async {
    isConnected = await DeviceStatus.dstate.isDeviceOnline();
    if (isConnected) {
      return ApiCalls.uploadPost(email, password, _postText, _hashTags)
          .then((id) {
        if (id == -1) {
          print("Error occurred while uploading the post");
          return false;
        } else {
          print("Post ID is " + id.toString());
          if (_image != null) {
            return _image.readAsBytes().then((value) {
              String encodedImage = base64Encode(value);
              return ApiCalls.uploadImage(email, password, id, encodedImage)
                  .then((response) {
                if (response == true) {
                  return true;
                } else {
                  return false;
                }
              });
            });
          } else {
            return true;
          }
        }
      });
    } else {
      return _image.readAsBytes().then((value) {
        String encodedImage = base64Encode(value);
        return DBProvider.db
            .newPost(encodedImage, _postText, _hashTags.join(" "))
            .then((value) {
          return true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(
        padding: EdgeInsets.all(6.0),
        height: 200.0,
        child: InkWell(
          onTap: () {
            _getImage();
          },
          child: _image == null
              ? Image.asset("assets/placeholder_image.png")
              : Image.file(_image, fit: BoxFit.fill),
        ),
      ),
      Text(
        "Add Image",
        textAlign: TextAlign.center,
      ),
      Column(
        children: [
          HashTagTextField(
            decoration: InputDecoration(
                labelText: "Type your post and Give some hashtags..",
                errorText: _textError ? _textErrorText : null),
            maxLength: 140,
            controller: hashTagController,
          ),
          Container(
            width: 120.0,
            child: RaisedButton(
              onPressed: () {
                if (_validatePostFields()) {
                  Dialogs.showLoadingDialog(context, _keyLoader); //invoking login
                  _getUserCredentials().then((value) {
                    String email = value[0];
                    String password = value[1];
                    _uploadPost(email, password).then((value) {
                      if (value == true && isConnected == true) {
                        Navigator.of(_keyLoader.currentContext,
                                rootNavigator: true)
                            .pop();
                        final snackBar =
                            SnackBar(content: Text("Post uploaded successfully"));
                        Scaffold.of(context).showSnackBar(snackBar);
                      } else if (value == true && isConnected == false) {
                        Navigator.of(_keyLoader.currentContext,
                                rootNavigator: true)
                            .pop();
                        final snackBar = SnackBar(
                            content: Text(
                                "You are offline. Post will be updated when device comes online"));
                        Scaffold.of(context).showSnackBar(snackBar);
                      } else {
                        Navigator.of(_keyLoader.currentContext,
                            rootNavigator: true)
                            .pop();
                        final snackBar =
                            SnackBar(content: Text("Post upload failed"));
                        Scaffold.of(context).showSnackBar(snackBar);
                      }
                    });
                  });
                }
              },
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(2.0,0.0,4.0,0.0),
                    child: Icon(Icons.upload_outlined),
                  ),
                  Text("Post", textAlign: TextAlign.center,),
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0.0,10.0,0,0),
            width: 120.0,
            child: RaisedButton(
              onPressed: () async {
                print("Logout clicked");
                Dialogs.showLoadingDialog(context, _keyLoader);
                bool res = await _userLogout();
                if(res){
                  print("Logout successful");
                }
                Navigator.of(_keyLoader.currentContext,rootNavigator: true).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          MyApp()),
                );
              },
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(2.0,0.0,4.0,0.0),
                    child: Icon(Icons.logout),
                  ),
                  Text("Logout", textAlign: TextAlign.center,),
                ],
              ),
            ),
          )
        ],
      )
    ]));
  }
}
