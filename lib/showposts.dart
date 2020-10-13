import 'dart:convert';
import 'dart:io' as Io;
import 'dart:typed_data';
import 'package:assignment_two/postDetails.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'apiCalls.dart';

class ShowPosts extends StatefulWidget {
  String nickName;

  ShowPosts(this.nickName);

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
            return Container(
                height: 200.0, child: Center(child: Text("No Image found")));
          } else {
            try {
              Uint8List bytes = base64.decode(snapshot.data);
              return Image.memory(
                bytes,
                height: 200.0,
                fit: BoxFit.fill,
              );
            } catch (exception) {
              return Container(
                  height: 200.0, child: Center(child: Text("Invalid Image")));
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
            String rating = snapshot.data['post']['ratings-average'].toString();
            String ratingCount =
                snapshot.data['post']['ratings-count'].toString();

            return Padding(
              padding: EdgeInsets.all(2.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Average Rating: $rating, Rated by $ratingCount people"),
                  Text(caption),
                  Text(hashtags)
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
                  const EdgeInsets.symmetric(vertical: 2.0, horizontal: 0.0),
              child: Card(
                margin: EdgeInsets.fromLTRB(0.0, 2.0, 0.0, 4.0),
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
          future: ApiCalls.getPostIDS(widget.nickName),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              print(snapshot.data);
              if (snapshot.data.length > 0) {
                return _loadPosts(snapshot.data);
              } else {
                return Center(
                  child: Text("There are No IDs"),
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
