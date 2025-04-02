import 'package:flutter/material.dart';
import 'package:tooth_tales/models/articleModel.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailScreen({Key? key, required this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Article Details', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),

            Image.network(
              article.urlToImage.isNotEmpty
                  ? article.urlToImage
                  : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT1qWAIpqePEAH-UPypnABjdT_eNu7hlLi54Q&s',
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(child: Text('Failed to load image'));
              },
            ),
            SizedBox(height: 16),

            Text(
              article.description,
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 16),

            Text(
              'Read more at: ${article.url}',
              style: TextStyle(fontSize: 14, color: Colors.blue),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
