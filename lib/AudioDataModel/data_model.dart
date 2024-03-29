// To parse this JSON data, do
//
//     final songData = songDataFromJson(jsonString);

import 'dart:convert';

List<SongData> songDataFromJson(String str) => List<SongData>.from(json.decode(str).map((x) => SongData.fromJson(x)));

String songDataToJson(List<SongData> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SongData {
  String title;
  String imageUrl;
  String songLink;
  String artist;


  SongData({
    required this.title,
    required this.imageUrl,
    required this.songLink,
    required this.artist
  });

  factory SongData.fromJson(Map<String, dynamic> json) => SongData(
    title: json["Title"],
    imageUrl: json["ImageUrl"],
    songLink: json["SongLink"],
    artist: json["Artist"]
  );

  Map<String, dynamic> toJson() => {
    "Title": title,
    "ImageUrl": imageUrl,
    "SongLink": songLink,
    "ArtistName":artist
  };
}
