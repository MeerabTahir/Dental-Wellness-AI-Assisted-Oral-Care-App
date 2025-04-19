import 'package:flutter/material.dart';
import 'package:tooth_tales/services/news_service.dart';
import 'package:tooth_tales/models/articleModel.dart';
import 'package:tooth_tales/screens/article/article_detail_screen.dart';

class ArticleListScreen extends StatefulWidget {
  @override
  _ArticleListScreenState createState() => _ArticleListScreenState();
}

class _ArticleListScreenState extends State<ArticleListScreen> {
  late Future<List<Article>> _articles;
  final NewsService _newsService = NewsService();

  @override
  void initState() {
    super.initState();
    _articles = _newsService.fetchDentalHealthArticles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dental Health Articles', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Article>>(
        future: _articles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No articles found'));
          } else {
            final articles = snapshot.data!;
            return ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ArticleDetailScreen(article: article),
                      ),
                    );
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(
                            article.urlToImage.isNotEmpty
                                ? article.urlToImage
                                : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT1qWAIpqePEAH-UPypnABjdT_eNu7hlLi54Q&s',
                            width: double.infinity,
                            height: 250,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(height: 8),
                          Text(
                            article.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
