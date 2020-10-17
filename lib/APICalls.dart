import 'dart:io';
import 'package:assignment_two/CacheFileManager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class ApiCalls {
  static Future<String> signUp(
      _firstName, _lastName, _nickName, _email, _password) async {
    try {
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
        return result['errors'];
      }
    } on Exception catch (e) {
      return "No internet connection";
    }
  }

  static Future<bool> logIn(_email, _password) async {
    try {
      String url =
          "https://bismarck.sdsu.edu/api/instapost-query/authenticate?email=" +
              _email +
              "&password=" +
              _password;
      var response = await http.get(url);
      Map<String, dynamic> result = jsonDecode(response.body);
      return result['result'];
    } on Exception catch (e) {
      return false;
    }
  }

  static Future<List> getNickNames() async {
    String fileName = "nicknames.json";
    try {
      String url = "https://bismarck.sdsu.edu/api/instapost-query/nicknames";
      var response = await http.get(url);
      Map<String, dynamic> result = jsonDecode(response.body);
      print("Writing to Cache");
      bool fileWriteResponse =
          await CacheFileManager.saveDataToCache(fileName, response.body);
      print("Completed writing to the file");
      return result['nicknames'];
    } on SocketException catch (_) {
      print('Device is offline');
      Map<String, dynamic> result =
          await CacheFileManager.readDataFromCache(fileName);
      return result['nicknames'];
    } catch (e) {
      print("Exception " + e);
      return [];
    }
  }

  static Future<List> getHashTags() async {
    String fileName = "hashtags.json";
    try {
      String url = "https://bismarck.sdsu.edu/api/instapost-query/hashtags";
      var response = await http.get(url);
      Map<String, dynamic> result = jsonDecode(response.body);
      print("Writing to Cache");
      bool fileWriteResponse =
          await CacheFileManager.saveDataToCache(fileName, response.body);
      print("Completed writing to the file");
      return result['hashtags'];
    } on SocketException catch (_) {
      print('Device is offline');
      Map<String, dynamic> result =
          await CacheFileManager.readDataFromCache(fileName);
      return result['hashtags'];
    } catch (e) {
      print("Exception " + e);
      return [];
    }
  }

  static Future<List> getPostIDswithNickName(String _nickName) async {
    String fileName = "user_$_nickName.json";
    try {
      String url =
          "https://bismarck.sdsu.edu/api/instapost-query/nickname-post-ids?nickname=$_nickName";
      var response = await http.get(url);
      Map<String, dynamic> result = jsonDecode(response.body);
      bool fileWriteResponse =
          await CacheFileManager.saveDataToCache(fileName, response.body);
      return result['ids'];
    } on SocketException catch (e) {
      print('Device is offline');
      Map<String, dynamic> result =
          await CacheFileManager.readDataFromCache(fileName);
      return result['ids'];
    }
  }

  static Future<List> getPostIDswithHashTag(String _hashTag) async {
    String fileName = "hashtag_$_hashTag.json";
    try {
      String url =
          "https://bismarck.sdsu.edu/api/instapost-query/hashtags-post-ids?hashtag=$_hashTag"
              .replaceAll("#", "%23");
      var response = await http.get(url);
      Map<String, dynamic> result = jsonDecode(response.body);
      bool fileWriteResponse =
          await CacheFileManager.saveDataToCache(fileName, response.body);
      return result['ids'];
    } on SocketException catch (e) {
      print('Device is offline');
      Map<String, dynamic> result =
          await CacheFileManager.readDataFromCache(fileName);
      return result['ids'];
    }
  }

  static Future<String> getImage(String id) async {
    String fileName = "image_$id.json";
    try {
      String newurl =
          "https://bismarck.sdsu.edu/api/instapost-query/image?id=$id";
      var response = await http.get(newurl);
      Map<String, dynamic> resultImage = jsonDecode(response.body);
      bool fileWriteResponse =
          await CacheFileManager.saveDataToCache(fileName, response.body);
      if (resultImage['result'] == "fail") {
        return null;
      } else {
        return resultImage['image'];
      }
    } on Exception catch (e) {
      print('Device is offline');
      Map<String, dynamic> result =
          await CacheFileManager.readDataFromCache(fileName);
      if (result.isEmpty || result['result'] == "fail") {
        return null;
      } else {
        return result['image'];
      }
    }
  }

  static Future<Map> getPostForPostID(String id) async {
    String fileName = "post_$id.json";
    try {
      String url =
          "https://bismarck.sdsu.edu/api/instapost-query/post?post-id=$id";
      var response = await http.get(url);
      Map<String, dynamic> result = jsonDecode(response.body);
      bool fileWriteResponse =
          await CacheFileManager.saveDataToCache(fileName, response.body);
      return result;
    } on Exception catch (e) {
      Map<String, dynamic> result =
          await CacheFileManager.readDataFromCache(fileName);
      return result;
    }
  }

  static Future<bool> postComment(
      String email, String password, String id, String comment) async {
    try {
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
      if (result['result'] == "success") {
        return true;
      } else {
        return false;
      }
    } on Exception catch (e) {
      return false;
    }
  }

  static Future<int> uploadPost(
      String email, String password, String post, List<String> hashtags) async {
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
    print(result['errors']);
    return result['id'];
  }

  static Future<bool> uploadImage(
      String email, String password, int postId, String encodedImage) async {
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
    if (result['result'] == "success") {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> rateThePost(
      String email, String password, int postId, int rating) async {
    try {
      var response = await http.post(
        'https://bismarck.sdsu.edu/api/instapost-upload/rating',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          "email": email,
          "password": password,
          "rating": rating,
          "post-id": postId
        }),
      );
      Map<String, dynamic> result = jsonDecode(response.body);
      print(result['result']);
      if (result['result'] == "success") {
        return true;
      } else {
        return false;
      }
    } on Exception catch (e) {
      return false;
    }
  }
}
