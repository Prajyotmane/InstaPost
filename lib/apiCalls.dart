import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ApiCalls {
  static Future<http.Response> _checkPing() async {
    var response = await http.get('https://bismarck.sdsu.edu/api/ping');
    print(response.statusCode);
    return response;
  }

  static Future<String> signUp(
      _firstName, _lastName, _nickName, _email, _password) async {
    String url =
        "https://bismarck.sdsu.edu/api/instapost-upload/newuser?firstname=" +
            _firstName +
            "&lastname=" +
            _lastName +
            "&nickname=" +
            _nickName +
            "&email=" +
            _email +
            "&password=" +
            _password;
    var response = await http.get(url);
    Map<String, dynamic> result = jsonDecode(response.body);
    if (result['result'] == "success") {
      return "";
    } else {
      print(result);
      return result['errors'];
    }
  }

  static Future<bool> logIn(_email, _password) async {
    String url =
        "https://bismarck.sdsu.edu/api/instapost-query/authenticate?email=" +
            _email +
            "&password=" +
            _password;
    var response = await http.get(url);
    Map<String, dynamic> result = jsonDecode(response.body);
    return result['result'];
  }

  static Future<List> getNickNames() async {
    String url = "https://bismarck.sdsu.edu/api/instapost-query/nicknames";
    var response = await http.get(url);
    Map<String, dynamic> result = jsonDecode(response.body);
    return result['nicknames'];
  }

  static Future<List> getPostIDS(String _nickName) async {
    String url =
        "https://bismarck.sdsu.edu/api/instapost-query/nickname-post-ids?nickname=$_nickName";
    var response = await http.get(url);
    Map<String, dynamic> result = jsonDecode(response.body);
    return result['ids'];
  }

  static Future<String> getImage(String id) async {
    String newurl =
        "https://bismarck.sdsu.edu/api/instapost-query/image?id=$id";
    var res = await http.get(newurl);
    Map<String, dynamic> resultImage = jsonDecode(res.body);
    if (resultImage['result'] == "fail") {
      return null;
    } else {
      return resultImage['image'];
    }
  }

  static Future<Map> getPostForPostID(String id) async {
    String url =
        "https://bismarck.sdsu.edu/api/instapost-query/post?post-id=$id";
    var response = await http.get(url);
    Map<String, dynamic> result = jsonDecode(response.body);
    return result;
  }


  static Future<bool> postComment(String email, String password, String id, String comment) async{
      var response = await http.post(
        'https://bismarck.sdsu.edu/api/instapost-upload/comment',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          "email": email,
          "password": password,
          "comment": comment,
          "post-id": int.parse(id)
        }),
      );
      Map<String, dynamic> result = jsonDecode(response.body);
      if(result['result']=="success"){
        return true;
      }else{
        return false;
      }
  }

  static Future<int> uploadPost(String email, String password, String post, List<String> hashtags) async {

    var response = await http.post(
      'https://bismarck.sdsu.edu/api/instapost-upload/post',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        "email": email,
        "password": password,
        "text": post,
        "hashtags": hashtags
      }),
    );
    Map<String, dynamic> result = jsonDecode(response.body);
    return result['id'];
  }
  static Future<bool> uploadImage(String email, String password,int postId,String encodedImage) async{
    var response = await http.post(
      'https://bismarck.sdsu.edu/api/instapost-upload/image',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        "email": email,
        "password": password,
        "image": encodedImage,
        "post-id": postId
      }),
    );
    Map<String, dynamic> result = jsonDecode(response.body);
    print(result['result']);
    if(result['result']=="success"){
      return true;
    }else{
      return false;
    }
  }
}
