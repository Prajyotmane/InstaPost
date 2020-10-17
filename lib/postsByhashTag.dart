import 'dart:io';
import 'package:assignment_two/showposts.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'apiCalls.dart';
import 'makepost.dart';

class HashTagList extends StatefulWidget {
  @override
  _HashTagListState createState() => _HashTagListState();
}

class _HashTagListState extends State<HashTagList> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: ApiCalls.getHashTags(),
        builder:(context, snapshot){
          if(snapshot.connectionState == ConnectionState.done){
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 2.0),
                  child: Card(
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ShowPosts(snapshot.data[index],false)),
                        );
                      },
                      title: Text(snapshot.data[index]),
                      leading: CircleAvatar(
                        backgroundImage: AssetImage('assets/hashtag_placeholder.png'),
                      ),
                    ),
                  ),
                );
              },
            );
          }else{
            return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ));
          }

        });
  }
}
