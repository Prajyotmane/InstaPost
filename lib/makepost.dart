import 'dart:convert';
import 'dart:io';
import 'package:assignment_two/apiCalls.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';

class MakeAPost extends StatefulWidget {
  @override
  _MakeAPostState createState() => _MakeAPostState();
}

class _MakeAPostState extends State<MakeAPost> {
  File _image;
  final _postFormKey = GlobalKey<FormState>();
  String _postText;
  List<String> _hashTags;
  Widget show = Container();

  Future<List> _getUserCredentials() async {
    List<String> userCreds = new List();
    final prefs = await SharedPreferences.getInstance();
    userCreds.add(prefs.getString("EMAIL"));
    userCreds.add(prefs.getString("PASSWORD"));
    print(userCreds);
    return userCreds;
  }

  final picker = ImagePicker();

  _getImage() async {
    final PickedFile pickedFile =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 50, maxWidth: 400.0);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<bool> _uploadPost(String email, String password) async{
      return ApiCalls.uploadPost(email, password, _postText, _hashTags).then((id) {
        if (id == -1) {
          print("Error occurred while uploading the post");
          return false;
        } else {
          print("Post ID is "+id.toString());
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
          }else{
            return true;
          }
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(6.0),
            height: 150.0,
            child: InkWell(
              onTap: () {
                _getImage();
              },
              child: Center(
                  child:
                      _image == null ? Image.asset("assets/placeholder_image.png") : Image.file(_image)),
            ),
          ),
          Text("Add Image"),
          Form(
            key: _postFormKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: "Type your post.."),
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Post must have some text..";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _postText = value;
                  },
                ),
                TextFormField(
                  decoration:
                      InputDecoration(labelText: "Give some hashtags.."),
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Post must have some hashtags too..";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _hashTags = value.split(" ");
                  },
                )
              ],
            ),
          ),
          RaisedButton(
            onPressed: () {
              if (_postFormKey.currentState.validate()) {
                _postFormKey.currentState.save();
                print("Post button pressed");
                setState(() {
                  show = CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  );
                });
                _getUserCredentials().then((value) {
                  String email = value[0];
                  String password = value[1];
                  _uploadPost(email, password).then((value) {

                    print("Result after all calls " + value.toString());
                    if (value == true) {
                      final snackBar = SnackBar(
                          content: Text(
                              "Post uploaded successfully"));
                      Scaffold.of(context)
                          .showSnackBar(
                          snackBar);
                    } else {
                      final snackBar = SnackBar(
                          content: Text(
                              "Post upload failed"));
                      Scaffold.of(context)
                          .showSnackBar(
                          snackBar);
                    }

                    setState(() {
                      show = Container();
                    });
                  });
                });
              }
            },
            child: Text("Post"),
          ),
          show
        ],
      ),
    );
  }
}
