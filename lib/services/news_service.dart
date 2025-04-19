import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tooth_tales/models/articleModel.dart';
// import 'package:tooth_tales/constants/constant.dart';

class NewsService {
  final String baseUrl = 'https://newsapi.org/v2/everything';

  Future<List<Article>> fetchDentalHealthArticles() async {
    final url = '$baseUrl?q=dental+care+oral&apiKey=c2b6b3799d5040bca84ad0c449d35338';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> articlesJson = data['articles'];
      return articlesJson.map((json) => Article.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load articles: ${response.reasonPhrase}');
    }
  }
}
