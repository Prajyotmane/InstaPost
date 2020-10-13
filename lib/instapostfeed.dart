import 'dart:io';
import 'package:assignment_two/showposts.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'apiCalls.dart';
import 'makepost.dart';

class InstaPostFeed extends StatefulWidget {
  @override
  _InstaPostFeedState createState() => _InstaPostFeedState();
}

class _InstaPostFeedState extends State<InstaPostFeed> {
  List<dynamic> _nickNames;

  Widget _loadNickNames() {
    return ListView.builder(
      itemCount: _nickNames.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 2.0),
          child: Card(
            child: ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ShowPosts(_nickNames[index])),
                );
              },
              title: Text(_nickNames[index]),
              leading: CircleAvatar(
                backgroundImage: AssetImage('assets/profile_pic_dummy.jpg'),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ApiCalls.getNickNames(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          _nickNames = snapshot.data;
          return DefaultTabController(
            length: 3,
            child: Column(
              children: <Widget>[
                Container(
                  constraints: BoxConstraints(maxHeight: 150.0),
                  child: Material(
                    color: Colors.black,
                    child: TabBar(
                      tabs: [
                        Tab(
                          text: "Post",
                        ),
                        Tab(
                          text: "Users",
                        ),
                        Tab(
                          text: "Hashtags",
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      MakeAPost(),
                      _loadNickNames(),
                      Icon(Icons.directions_transit),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return Center(
              child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
          ));
        }
      },
    );
  }
}
