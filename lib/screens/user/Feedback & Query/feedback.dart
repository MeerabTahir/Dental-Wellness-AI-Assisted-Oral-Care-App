import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackScreen extends StatefulWidget {
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _rating = 0;
  TextEditingController _commentController = TextEditingController();

  Future<String> _fetchUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return "Anonymous";

    DocumentSnapshot userDoc =
    await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    return userDoc.exists ? (userDoc['userName'] ?? "Anonymous") : "Anonymous";
  }

  void _submitFeedback() async {
    if (_rating == 0) return;

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You must be logged in to provide feedback.")),
      );
      return;
    }

    String username = await _fetchUserName();

    Map<String, dynamic> feedback = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'userId': user.uid,
      'userName': username,
      'rating': _rating,
      'comment': _commentController.text,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance.collection('feedbacks').doc(feedback['id']).set(feedback);

    setState(() {
      _rating = 0;
      _commentController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Feedback submitted successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("Feedback", style: TextStyle(fontFamily: 'GoogleSans', fontSize: 18)),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            tabs: [
              Tab(text: "Provide Feedback"),
              Tab(text: "All Feedback"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFeedbackForm(),
            _buildFeedbackList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(
                'assets/Images/feedback.png',
                width: 500,
                height: 250,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Feedback",
              style: TextStyle(fontSize: 24, fontFamily: 'GoogleSans', fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              "How would you rate your experience?",
              style: TextStyle(fontSize: 18, fontFamily: 'GoogleSans', fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    Icons.star,
                    color: _rating > index ? Colors.orange : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                );
              }),
            ),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: "Add a comment",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: _submitFeedback,
                child: Text("Submit Feedback", style: TextStyle(fontFamily: 'GoogleSans')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackList() {
    return Column(
      children: [
        Center(
          child: Image.asset(
            'assets/Images/feedback.png',
            width: 500,
            height: 250,
          ),
        ),
        SizedBox(height: 10),
        Text(
          "All Feedbacks",
          style: TextStyle(fontSize: 24, fontFamily: 'GoogleSans', fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Expanded(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('feedbacks').orderBy('timestamp', descending: true).snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text("No feedback available", style: TextStyle(fontFamily: 'GoogleSans')));
              }
              return ListView(
                children: snapshot.data!.docs.map((doc) {
                  var feedback = doc.data() as Map<String, dynamic>;
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.blue, width: 2),
                    ),
                    elevation: 3,
                    color: Colors.lightBlue[50],
                    child: ListTile(
                      leading: Icon(Icons.star, color: Colors.orange),
                      title: Text(
                        "${feedback['userName'] ?? 'Anonymous'}",
                        style: TextStyle(fontFamily: 'GoogleSans', fontWeight: FontWeight.w800, color: Colors.black),
                      ),
                      subtitle: Text(
                        feedback['comment'] ?? '',
                        style: TextStyle(fontFamily: 'GoogleSans'),

                      ),
                      trailing: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                      Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.lime[50], // Yellow box for rating
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        " ${feedback['rating']} ⭐",
                        style: TextStyle(
                          fontFamily: 'GoogleSans',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    ]),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}