import 'dart:convert';
import 'dart:io';
import 'package:assignment_two/APICalls.dart';
import 'package:assignment_two/DBHandler.dart';
import 'package:assignment_two/DeviceStatus.dart';
import 'package:assignment_two/User.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:hashtagable/hashtagable.dart';
import 'LoadingScreen.dart';
import 'main.dart';

/* This module handles the user's post upload action*/

class MakeAPost extends StatefulWidget {
  @override
  _MakeAPostState createState() => _MakeAPostState();
}

class _MakeAPostState extends State<MakeAPost> {
  File _image;
  String _postText, _textErrorText;
  bool _textError = false, isConnected = true;
  List<String> _hashTags;
  Widget show = Container();
  final hashTagController = TextEditingController(),
      postController = TextEditingController();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  final picker = ImagePicker();

  //Picks the image from user's gallery
  _getImage() async {
    final PickedFile pickedFile = await picker.getImage(
        source: ImageSource.gallery, imageQuality: 50, maxWidth: 400.0);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.'); //Debug message
      }
    });
  }

  //Validates the post for text and hashtags
  bool _validatePostFields() {
    _postText = hashTagController.text; //Post text
    _hashTags = extractHashTags(_postText); //Extracts hashtags from the post

    //If no text in post
    if (_postText.length == 0) {
      setState(() {
        _textError = true;
        _textErrorText = "Post must contain text";
      });
    } else if (_postText.length > 144) {
      //if post has more than 144 characters
      setState(() {
        _textError = true;
        _textErrorText = "Post must not contain more than 140 characters";
      });
    } else {
      setState(() {
        _textError = false;
      });
    }

    //if no hashtags in post
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
    print(_textError); //Debug message
    return !_textError;
  }

  //Uploads the post
  Future<bool> _uploadPost(String email, String password) async {
    isConnected = await DeviceStatus.dstate
        .isDeviceOnline(); //Check the network connection

    //if device is online, upload the post
    if (isConnected) {
      return ApiCalls.uploadPost(email, password, _postText, _hashTags)
          .then((id) {
        if (id == -1) {
          print("Error occurred while uploading the post"); //Debug message
          return false;
        } else {
          print("Post ID is " + id.toString()); //Debug message
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
      //else save the post in file locally
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
      Text("Add Image",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(6.0, 2.0, 6.0, 0.0),
            child: HashTagTextField(
              decoration: InputDecoration(
                  labelText: "Type your post and Give some hashtags..",
                  errorText: _textError ? _textErrorText : null),
              maxLength: 144,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              controller: hashTagController,
            ),
          ),
          Container(
            width: 120.0,
            child: RaisedButton(
              onPressed: () {
                if (_validatePostFields()) {
                  Dialogs.showLoadingDialog(
                      context, _keyLoader); //invoking loading screen
                  User.getUserCredentials().then((value) {
                    String email = value[0];
                    String password = value[1];
                    _uploadPost(email, password).then((value) {
                      if (value == true && isConnected == true) {
                        Navigator.of(_keyLoader.currentContext,
                                rootNavigator: true)
                            .pop();
                        final snackBar = SnackBar(
                            content: Text("Post uploaded successfully"));
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
                      setState(() {
                        _image = null;
                        hashTagController.clear();
                      });
                    });
                  });
                }
              },
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(2.0, 0.0, 4.0, 0.0),
                    child: Icon(Icons.upload_outlined),
                  ),
                  Text(
                    "Post",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0.0, 10.0, 0, 0),
            width: 120.0,
            child: RaisedButton(
              onPressed: () async {
                Dialogs.showLoadingDialog(context, _keyLoader);
                bool res = await User.userLogout();
                if (!res) {
                  final snackBar = SnackBar(content: Text("Logout Failed"));
                  Scaffold.of(context).showSnackBar(snackBar);
                }
                Navigator.of(_keyLoader.currentContext, rootNavigator: true)
                    .pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MyApp()),
                );
              },
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(2.0, 0.0, 4.0, 0.0),
                    child: Icon(Icons.logout),
                  ),
                  Text(
                    "Logout",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        ],
      )
    ]));
  }
}
