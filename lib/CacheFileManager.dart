import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class CacheFileManager {
  static Future<Directory> get _getcachedir async =>
      _cachedir ??= await getTemporaryDirectory();
  static Directory _cachedir;

  static Future<Directory> init() async {
    _cachedir = await _getcachedir;
    return _cachedir;
  }

  static Future<bool> saveDataToCache(String fileName,String data) async {
    try {
      File file = new File(_cachedir.path + "/" + fileName);
      await file.writeAsString(data,
          flush: true, mode: FileMode.write);
      return true;
    } on Exception catch (e) {
      print("Exception while writing to file : "+e.toString());
      return false;
    }
  }

  static Future<Map<String, dynamic>> readDataFromCache(String fileName) async{
    Map<String, dynamic> result;
    try {
      if (await File(_cachedir.path + "/" + fileName).exists()) {
        print("Loading from cache");
        var response = File(_cachedir.path + "/" + fileName).readAsStringSync();
        result = jsonDecode(response);
        return result;
      }else{
        return result;
      }
    } on Exception catch (e) {
      print("Exception while writing to file : "+e.toString());
      return result;
    }
  }
}
