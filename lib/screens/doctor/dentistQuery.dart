import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DentistQuery extends StatefulWidget {
  final String dentistId;
  const DentistQuery({super.key, required this.dentistId});

  @override
  _DentistQueryState createState() => _DentistQueryState();
}

class _DentistQueryState extends State<DentistQuery> {
  String userName = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          setState(() {
            userName = userDoc.get('userName');
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void _postReply(String queryId, String replyText) async {
    if (replyText.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('queries')
          .doc(queryId)
          .collection('replies')
          .add({
        'dentistId': widget.dentistId,
        'reply': replyText,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _showReplyDialog(String queryId) async {
    TextEditingController replyController = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Reply to Query"),
          content: TextField(
            controller: replyController,
            decoration: const InputDecoration(labelText: "Enter your reply"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                _postReply(queryId, replyController.text);
                Navigator.pop(context);
              },
              child: const Text("Send"),
            ),
          ],
        );
      },
    );
  }

  Future<String> _getDentistName(String dentistId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(dentistId)
          .get();
      return doc.exists ? doc.get('userName') : "Unknown Dentist";
    } catch (e) {
      return "Unknown Dentist";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Patient Queries",
          style: TextStyle(
            fontFamily: "GoogleSans",
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('queries')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var queries = snapshot.data!.docs;
          return ListView.builder(
            itemCount: queries.length,
            itemBuilder: (context, index) {
              var query = queries[index];
              String queryId = query.id;

              return Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(query['question'],
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'GoogleSans')),
                      const SizedBox(height: 5),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('queries')
                            .doc(queryId)
                            .collection('replies')
                            .snapshots(),
                        builder: (context, replySnapshot) {
                          if (!replySnapshot.hasData ||
                              replySnapshot.data!.docs.isEmpty) {
                            return const Text("No replies yet",
                                style: TextStyle(fontFamily: 'GoogleSans', color: Colors.grey));
                          }
                          var replies = replySnapshot.data!.docs;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: replies.map((reply) {
                              return FutureBuilder<String>(
                                future: _getDentistName(reply['dentistId']),
                                builder: (context, dentistNameSnapshot) {
                                  if (dentistNameSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Text("Loading...",style:
                                    const TextStyle(fontFamily: 'GoogleSans'));
                                  }
                                  String dentistName =
                                      dentistNameSnapshot.data ?? "Dentist";
                                  return Row(
                                    children:[
                                  Text("Dr. $dentistName: ",
                                      style:
                                      const TextStyle(color: Colors.blue, fontFamily: 'GoogleSans')),
                                  Text("${reply['reply']}",
                                  style:
                                  const TextStyle(color: Color(0xFF545151), fontFamily: 'GoogleSans')),
                                    ],
                                  );
                                },
                              );
                            }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.comment),
                          label: const Text("Reply"),
                          onPressed: () => _showReplyDialog(queryId),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
