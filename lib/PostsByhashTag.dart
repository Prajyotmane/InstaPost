import 'dart:io';
import 'package:assignment_two/ShowPosts.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'APICalls.dart';
import 'MakePost.dart';

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
            if (snapshot.data!=null) {
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
              return Center(child: Text("No data found in cache"),);
            }
          }else{
            return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ));
          }

        });
  }
}
