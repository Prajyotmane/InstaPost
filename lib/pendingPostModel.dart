import 'dart:convert';

PendingPost postFromJson(String str) {
  final jsonData = json.decode(str);
  return PendingPost.fromMap(jsonData);
}

String postToJson(PendingPost data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class PendingPost {
  int id;
  String image;
  String postText;
  List<String> hashTags;

  PendingPost({
    this.id,
    this.image,
    this.postText,
    this.hashTags,
  });

  factory PendingPost.fromMap(Map<String, dynamic> json) => new PendingPost(
    id: json["id"],
    image: json["first_name"],
    postText: json["last_name"],
    hashTags: json["blocked"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "first_name": image,
    "last_name": postText,
    "blocked": hashTags,
  };
}