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
              child: Text("Delete", style: TextStyle(color: Colors.red, fontFamily: "GoogleSans")),
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
          title: Text(
            "User Queries",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,fontFamily: "GoogleSans"),
          ),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.add_comment), text: "Ask Question"),
              Tab(icon: Icon(Icons.forum), text: "All Queries"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAskQuestionTab(),
            _buildAllQueriesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildAskQuestionTab() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _questionController,
                decoration: InputDecoration(
                  labelText: "Ask your question...",
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
        ),
        Divider(thickness: 1),
        Expanded(child: _buildUserQuestionsTab())
      ],
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
        if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
          return Center(child: Text("You haven't asked any questions yet."));

        var queries = snapshot.data!.docs;

        return ListView.builder(
          itemCount: queries.length,
          itemBuilder: (context, index) {
            var data = queries[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              child: ListTile(
                title: Text(data['question'], style: TextStyle(fontSize: 16,fontFamily: "GoogleSans")),
                subtitle: Text(
                  data['timestamp'] != null
                      ? timeago.format(data['timestamp'].toDate())
                      : "Just now",
                  style: TextStyle(fontSize: 12, color:Colors.blue, fontFamily: "GoogleSans"),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteQuestion(data.id),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAllQueriesTab() {
    return Column(
      children: [
        SizedBox(height: 10),
        Image.asset("assets/images/query.jpg", height: 200,
          width: double.infinity,),
        Text(
          "All Queries",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,fontFamily: "GoogleSans"),
        ),
        SizedBox(height: 10),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('queries')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Center(child: Text("Error loading queries"));
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                return Center(child: Text("No queries found."));

              var queries = snapshot.data!.docs;

              return ListView.builder(
                itemCount: queries.length,
                itemBuilder: (context, index) {
                  var query = queries[index];
                  String question = query['question'];
                  String queryId = query.id;

                  return FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('queries')
                        .doc(queryId)
                        .collection('replies')
                        .get(),
                    builder: (context, replySnapshot) {
                      if (!replySnapshot.hasData) return SizedBox();

                      var replies = replySnapshot.data!.docs;

                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Q: $question",
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: "GoogleSans",
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 6),
                            if (replies.isEmpty)
                              Text(
                                "No reply yet.",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontFamily: "GoogleSans",
                                ),
                              )
                            else
                              ...replies.map((reply) {
                                return FutureBuilder<DocumentSnapshot>(
                                  future: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(reply['dentistId'])
                                      .get(),
                                  builder: (context, dentistSnap) {
                                    String dentistName = "Dentist";
                                    if (dentistSnap.hasData && dentistSnap.data!.exists) {
                                      var dentistData = dentistSnap.data!;
                                      dentistName = dentistData['userName'] ?? "Dentist";
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 6.0, bottom: 10.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${reply['reply']}",
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontFamily: "GoogleSans",
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            "Replied by Dr. $dentistName",
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                              fontFamily: "GoogleSans",
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            Divider(thickness: 1, color: Colors.grey.shade300),
                          ],
                        ),
                      );

                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
