import 'package:assignment_two/PostsByNickName.dart';
import 'package:assignment_two/PostsByhashTag.dart';
import 'package:flutter/material.dart';
import 'MakePost.dart';

class InstaPostFeed extends StatefulWidget {
  @override
  _InstaPostFeedState createState() => _InstaPostFeedState();
}

/*This is the first screen user sees after logging into the app. There are three tabs and every tab is a stateful widget defined here */
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
              //to display tabview at the top of the screen
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
