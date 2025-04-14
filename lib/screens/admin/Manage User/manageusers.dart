import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageUsersPage extends StatefulWidget {
  @override
  _ManageUsersPageState createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('isDoctor', isEqualTo: false)
          .where('id', isNotEqualTo: "0")
          .get();

      setState(() {
        users = snapshot.docs.map((doc) {
          final data = doc.data();
          data['docId'] = doc.id;
          return data;
        }).toList();
        isLoading = false;
      });
    } catch (error) {
      print("Error fetching users: $error");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteUser(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User deleted successfully")),
      );
      _fetchUsers();
    } catch (error) {
      print("Error deleting user: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete user")),
      );
    }
  }

  void _showDeleteDialog(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          "Delete User",
          style: TextStyle(fontFamily: "GoogleSans", fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to delete this user?",
          style: TextStyle(fontFamily: "GoogleSans"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "Cancel",
              style: TextStyle(fontFamily: "GoogleSans", color: Colors.blue),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteUser(docId);
            },
            child: const Text(
              "Delete",
              style: TextStyle(fontFamily: "GoogleSans", color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserItem(Map<String, dynamic> user) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.shade100),
        borderRadius: BorderRadius.circular(12),
        color: Colors.blue.shade50.withOpacity(0.2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['userName'] ?? "No Name",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: "GoogleSans",
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Gender: ${user['gender'] ?? 'N/A'}",
                  style: const TextStyle(fontFamily: "GoogleSans"),
                ),
                Text(
                  "DOB: ${user['dateOfBirth'] ?? 'N/A'}",
                  style: const TextStyle(fontFamily: "GoogleSans"),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              _showDeleteDialog(user['docId']);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Manage Users",
          style: TextStyle(fontFamily: "GoogleSans", fontSize: 18, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/Images/patients.png',
              width: double.infinity,
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            const Text(
              "All Users",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: "GoogleSans",
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "You can see all users here",
              style: TextStyle(fontSize: 16, fontFamily: "GoogleSans"),
            ),
            const SizedBox(height: 16),
            users.isEmpty
                ? const Center(
              child: Text(
                "No users found",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontFamily: "GoogleSans"),
              ),
            )
                : Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return _buildUserItem(users[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
