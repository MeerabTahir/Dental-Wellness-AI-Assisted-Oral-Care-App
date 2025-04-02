import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewAppointmentsPage extends StatefulWidget {
  @override
  _ViewAppointmentsPageState createState() => _ViewAppointmentsPageState();
}

class _ViewAppointmentsPageState extends State<ViewAppointmentsPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> appointments = [];

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          appointments = snapshot.docs.map((doc) {
            return {
              'id': doc.id,
              ...doc.data(),
            };
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      print("Error fetching appointments: $error");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteAppointment(String id) async {
    try {
      await FirebaseFirestore.instance.collection('appointments').doc(id).delete();
      setState(() {
        appointments.removeWhere((appointment) => appointment['id'] == id);
      });
    } catch (error) {
      print("Error deleting appointment: $error");
    }
  }

  Future<void> _editAppointment(String id, Map<String, dynamic> updatedData) async {
    try {
      await FirebaseFirestore.instance.collection('appointments').doc(id).update(updatedData);
      setState(() {
        appointments = appointments.map((appointment) {
          if (appointment['id'] == id) {
            return {...appointment, ...updatedData};
          }
          return appointment;
        }).toList();
      });
    } catch (error) {
      print("Error updating appointment: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white,size: 18,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Appointments",
          style: TextStyle(
            fontFamily: "GoogleSans",
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/Images/app.jpg',
              width: 350,
              height: 200,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                "All Appointments",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: "GoogleSans",
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                "You can see all appointments here.",
                style: TextStyle(fontSize: 16, fontFamily: "GoogleSans"),
              ),
            ),
            const SizedBox(height: 16),
            appointments.isEmpty
                ? const Center(
              child: Text(
                "No appointments found",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  fontFamily: "GoogleSans",
                ),
              ),
            )
                : Expanded(
              child: ListView.builder(
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appointment = appointments[index];
                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    color: Colors.blueGrey[50],
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Dr. ${appointment['doctorName'] ?? 'N/A'}",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "GoogleSans",
                                  color: Colors.blueAccent,
                                ),
                              ),
                              Text(
                                appointment['appointmentTime'] ?? 'N/A',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontFamily: "GoogleSans",
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.person, color: Colors.blue, size: 20),
                              const SizedBox(width:8),
                              Text(
                                "Patient: ${appointment['patientName'] ?? 'N/A'}",
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "GoogleSans",
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 4),

                          Row(
                            children: [
                              const Icon(Icons.emoji_people, color: Colors.orange, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                "Age: ${appointment['patientAge'] ?? 'N/A'}",
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "GoogleSans",
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.phone, color: Colors.red, size: 20),
                              const SizedBox(width: 8,),
                              Text(
                                "Phone No: ${appointment['phoneNo'] ?? 'N/A'}",
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "GoogleSans",
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blueAccent),
                                onPressed: () async {
                                  // Show dialog for editing appointment details
                                  _showEditDialog(appointment);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  // Confirm delete
                                  _showDeleteDialog(appointment['id']);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> appointment) {
    final doctorNameController = TextEditingController(text: appointment['doctorName']);
    final appointmentTimeController = TextEditingController(text: appointment['appointmentTime']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit Appointment"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: doctorNameController,
                  decoration: const InputDecoration(labelText: "Doctor's Name"),
                ),

                TextField(
                  controller: appointmentTimeController,
                  decoration: const InputDecoration(labelText: "Appointment Time"),
                ),

              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final updatedData = {
                  'doctorName': doctorNameController.text,
                  'appointmentTime': appointmentTimeController.text,

                };
                _editAppointment(appointment['id'], updatedData);
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Appointment"),
          content: const Text("Are you sure you want to delete this appointment?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _deleteAppointment(id);
                Navigator.pop(context);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
