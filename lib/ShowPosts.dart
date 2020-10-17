import 'dart:convert';
import 'dart:io' as Io;
import 'dart:typed_data';
import 'package:assignment_two/PostDetails.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'APICalls.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ShowPosts extends StatefulWidget {
  String keyForIDs;
  bool showPostsfromNickName;

  ShowPosts(this.keyForIDs, this.showPostsfromNickName);

  @override
  _ShowPostsState createState() => _ShowPostsState();
}

class _ShowPostsState extends State<ShowPosts> {
  Widget _loadImage(String id) {
    return FutureBuilder(
      future: ApiCalls.getImage(id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data == null) {
            return Tooltip(
              message: "This post does not have image",
              child: Container(
                  height: 200.0,
                  child: Center(child: Icon(Icons.image_not_supported))),
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
                  height: 200.0,
                  child: Center(
                      child: Icon(Icons.broken_image),
                    ),
                ),
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

  Widget _loadPostText(String id) {
    return FutureBuilder(
      future: ApiCalls.getPostForPostID(id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data != null) {
            String caption = snapshot.data['post']['text'].trim();
            String hashtags = snapshot.data['post']['hashtags'].join(" ");
            double rating = snapshot.data['post']['ratings-average'].toDouble();
            String ratingCount =
                snapshot.data['post']['ratings-count'].toString();

            return Padding(
              padding: EdgeInsets.all(2.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: RatingBar(
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
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: RichText(text: TextSpan(
                          text: 'Rated by ',
                          style: DefaultTextStyle.of(context).style,
                          children: <TextSpan>[
                            TextSpan(text: ratingCount, style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: ' people'),
                          ],)),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Text(caption,style: TextStyle(fontSize: 14.0),),
                  ),
                ],
              ),
            );
          } else {
            return Padding(
              padding: EdgeInsets.all(2.0),
              child: Text("No caption"),
            );
          }
        } else {
          return Text("..");
        }
      },
    );
  }

  Widget _loadPosts(List<dynamic> ids) {
    return ListView.builder(
        itemCount: ids.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DetailedPost(ids[index].toString())),
              );
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
              child: Card(
                elevation: 10.0,
                margin: EdgeInsets.fromLTRB(6.0, 0.0, 6.0, 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _loadImage(ids[index].toString()),
                    _loadPostText(ids[index].toString())
                  ],
                ),
              ),
            ),
          );
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
          future: widget.showPostsfromNickName
              ? ApiCalls.getPostIDswithNickName(widget.keyForIDs)
              : ApiCalls.getPostIDswithHashTag(widget.keyForIDs),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              print(snapshot.data);
              if (snapshot.data!=null && snapshot.data.length > 0) {
                return _loadPosts(snapshot.data);
              } else {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(Icons.image_search_rounded),
                      ),
                      Text("No posts found"),
                    ],
                  ),
                );
              }
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
