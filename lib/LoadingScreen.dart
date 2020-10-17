import 'package:flutter/material.dart';
class Dialogs {
  static Future<void> showLoadingDialog(
      BuildContext context, GlobalKey key, {message:"Please Wait"}) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  key: key,
                  backgroundColor: Colors.black,
                  children: <Widget>[
                    Center(
                      child: Column(children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 20,),
                        Text(message,style: TextStyle(color: Colors.white),)
                      ]),
                    )
                  ]));
        });
  }
}