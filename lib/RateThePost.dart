import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RateThePostDialog extends StatefulWidget {
  @override
  _RateThePostDialogState createState() => _RateThePostDialogState();
}

class _RateThePostDialogState extends State<RateThePostDialog> {
  double rating = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Rate the post"),
      content: RatingBar(
        initialRating: 0,
        minRating: 1,
        direction: Axis.horizontal,
        allowHalfRating: false,
        itemCount: 5,
        itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
        itemBuilder: (context, _) => Icon(
          Icons.star,
          color: Colors.amber,
        ),
        onRatingUpdate: (currRating) {
          rating = currRating;
        },
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("Submit"),
          onPressed: () {
            Navigator.of(context).pop(rating);
          },
        ),
        FlatButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop(0);
          },
        ),
      ],
    );
  }
}
