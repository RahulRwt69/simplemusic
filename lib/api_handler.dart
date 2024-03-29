import 'dart:convert';
import 'package:http/http.dart' as http;

import 'AudioDataModel/data_model.dart';

class SongApi {
  static const String baseUrl = "https://song-api-w9od.onrender.com/getsongs"; // Replace with your API endpoint

  Future<List<SongData>> fetchSongs() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((item) => SongData.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch songs');
    }
  }
}
