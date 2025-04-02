import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;

class UserQuery extends StatefulWidget {
  final String userId;

  UserQuery({required this.userId});

  @override
  _UserQueryState createState() => _UserQueryState();
}

class _UserQueryState extends State<UserQuery> {
  final TextEditingController _questionController = TextEditingController();

  Future<void> _postQuestion() async {
    if (_questionController.text.isEmpty) return;

    await FirebaseFirestore.instance.collection('queries').add({
      'userId': widget.userId,
      'question': _questionController.text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _questionController.clear();
  }

  Future<void> _deleteQuestion(String queryId) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete this question?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance.collection('queries').doc(queryId).delete();
                Navigator.pop(context);
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          title: Text("User Queries",
            style: const TextStyle(
            color: Colors.white,
            fontFamily: "GoogleSans",
            fontSize: 18,
            // fontWeight: FontWeight.bold,
          ),),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.question_answer), text: "Ask Question"),
              Tab(icon: Icon(Icons.list), text: "Your Questions"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAskQuestionTab(),
            _buildUserQuestionsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildAskQuestionTab() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _questionController,
            decoration: InputDecoration(
              labelText: "Enter your question",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
            ),
            maxLines: 3,
          ),
          SizedBox(height: 15),
          ElevatedButton.icon(
            onPressed: _postQuestion,
            icon: Icon(Icons.send),
            label: Text("Post Question"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserQuestionsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('queries')
          .where('userId', isEqualTo: widget.userId)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No questions found."));
        }

        var queries = snapshot.data!.docs;

        return ListView.builder(
          itemCount: queries.length,
          itemBuilder: (context, index) {
            var queryData = queries[index];
            String queryId = queryData.id;
            String question = queryData['question'];
            Timestamp? timestamp = queryData['timestamp'];

            return Card(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(question, style: const TextStyle(
                      color: Colors.black,
                      fontFamily: "GoogleSans",
                      fontSize: 18,
                      // fontWeight: FontWeight.bold,
                    ),),
                    SizedBox(height: 5),
                    Text(
                      timestamp != null ? timeago.format(timestamp.toDate()) : "Just now",
                      style: TextStyle(color: Colors.grey),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteQuestion(queryId),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
