import 'dart:convert';
import 'dart:io' as Io;
import 'dart:typed_data';
import 'package:assignment_two/RateThePost.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';
import 'apiCalls.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';


class DetailedPost extends StatefulWidget {
  String id;

  DetailedPost(this.id);

  @override
  _DetailedPostState createState() => _DetailedPostState();
}

class _DetailedPostState extends State<DetailedPost> {
  String comment;
  final _commentFormKey = GlobalKey<FormState>();
  int currentRating = 0;

  Widget _loadImage(String id) {
    return FutureBuilder(
      future: ApiCalls.getImage(id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data == null) {
            return Tooltip(
              message: "This post does not have image",
              child: Container(
                  height: 200.0, child: Center(child: Icon(Icons.image_not_supported))),
            );
          } else {
            try {
              Uint8List bytes = base64.decode(snapshot.data);
              return Image.memory(
                bytes,
                height: 200.0,
                fit: BoxFit.fill,
              );
            } catch (exception) {
              return Tooltip(
                message: "This image is broken",
                child: Container(
                    height: 200.0, child: Center(child: Icon(Icons.broken_image))),
              );
            }
          }
        } else {
          return Container(
              height: 200.0, child: Center(child: CircularProgressIndicator()));
        }
      },
    );
  }

  Future<List> _getUserCredentials() async {
    List<String> userCreds = new List();
    final prefs = await SharedPreferences.getInstance();
    userCreds.add(prefs.getString("EMAIL"));
    userCreds.add(prefs.getString("PASSWORD"));
    print(userCreds);
    return userCreds;
  }

  Future<bool> _rateThePost() async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return RateThePostDialog();
        }).then((rating) {
      currentRating = rating.round();
      if (currentRating > 0) {
        return _getUserCredentials().then((value) {
          String email = value[0];
          String password = value[1];
          return ApiCalls.rateThePost(
                  email, password, int.parse(widget.id), currentRating)
              .then((value) => value);
        });
      } else {
        return false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("InstaPost"),
          backgroundColor: Colors.black,
        ),
        body: FutureBuilder(
          future: ApiCalls.getPostForPostID(widget.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              String caption = snapshot.data['post']['text'].trim();
              String hashtags = snapshot.data['post']['hashtags'].join(" ");
              double rating =
                  snapshot.data['post']['ratings-average'].toDouble();
              String ratingCount =
                  snapshot.data['post']['ratings-count'].toString();
              List<dynamic> comments = snapshot.data['post']['comments'];
              return SingleChildScrollView(
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _loadImage(widget.id),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          RatingBar(
                            ignoreGestures: true,
                            initialRating: rating,
                            minRating: 0.00,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 25,
                            itemPadding: EdgeInsets.symmetric(horizontal: 1.0),
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Colors.black,
                            ),

                          ),
                          Text("Rated by $ratingCount people"),
                        ],
                      ),
                      Text(caption),
                      Text(hashtags),
                      Text(
                        'Comments',
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      RaisedButton(
                        onPressed: () async {
                          String message;
                          _rateThePost().then((value) {
                            if (currentRating > 0 && value) {
                              message = "Your rating has been submitted.";
                            } else if (currentRating > 0 && !value) {
                              message = "Something went wrong. Check your internet connection";
                            } else {
                              message = "Canceled";
                            }
                            final snackBar = SnackBar(content: Text(message));
                            Scaffold.of(context).showSnackBar(snackBar);
                          });
                        },
                        child: Text("Rate this post"),
                      ),
                      Form(
                        key: _commentFormKey,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 3,
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                        labelText: "Type your comment.."),
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return ERROR_TEXT;
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      comment = value;
                                    },
                                  )),
                              Expanded(
                                  flex: 1,
                                  child: RaisedButton(
                                    onPressed: () {
                                      if (_commentFormKey.currentState
                                          .validate()) {
                                        _commentFormKey.currentState.save();
                                        _getUserCredentials().then((value) {
                                          ApiCalls.postComment(value[0],
                                                  value[1], widget.id, comment)
                                              .then((value) {
                                            if (value) {
                                              final snackBar = SnackBar(
                                                  content:
                                                      Text("Comment posted"));
                                              Scaffold.of(context)
                                                  .showSnackBar(snackBar);
                                              setState(() {
                                                comments.add(comment);
                                              });
                                            } else {
                                              final snackBar = SnackBar(
                                                  content: Text(
                                                      "Could not post comment. Check your internet connection."));
                                              Scaffold.of(context)
                                                  .showSnackBar(snackBar);
                                            }
                                          });
                                        });
                                      }
                                    },
                                    child: Text("Submit"),
                                  ))
                            ],
                          ),
                        ),
                      ),
                      if (comments.length == 0)
                        Text(
                          'No comments found',
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      for (int i = 0; i < comments.length; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 0.0, horizontal: 1.0),
                          child: Card(
                            child: ListTile(
                              title: Text(comments[i].toString()),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
