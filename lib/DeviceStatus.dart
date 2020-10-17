import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class DeviceStatus{
  DeviceStatus._();
  static final DeviceStatus dstate = DeviceStatus._();

  Future<bool> isDeviceOnline() async {
    try {
      String url = "https://bismarck.sdsu.edu/api/ping";
      final result = await http.get(url);
      Map<String, dynamic> response = jsonDecode(result.body);
      if (response['message']=="pong") {
        print(response);
        print('Device is online');
        return true;
      }
    }on SocketException catch (_) {
      print('Device is offline');
        return false;
    }
    return false;
    }
  }
