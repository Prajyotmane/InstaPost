import 'dart:io';
import 'package:assignment_two/postsByNickName.dart';
import 'package:assignment_two/postsByhashTag.dart';
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
  @override
  Widget build(BuildContext context) {
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
              children: [MakeAPost(), NickNameList(), HashTagList()],
            ),
          ),
        ],
      ),
    );
  }
}
