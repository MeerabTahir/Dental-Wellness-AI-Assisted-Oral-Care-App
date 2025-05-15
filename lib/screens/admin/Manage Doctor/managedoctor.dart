import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageDoctorsPage extends StatefulWidget {
  @override
  _ManageDoctorsPageState createState() => _ManageDoctorsPageState();
}

class _ManageDoctorsPageState extends State<ManageDoctorsPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> doctors = [];
  List<Map<String, dynamic>> filteredDoctors = [];
  String _selectedSpecialization = 'All';
  List<String> specializations = ['All'];

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('isDoctor', isEqualTo: true)
          .get();

      if (snapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> tempDoctors = snapshot.docs.map((doc) {
          final data = doc.data();
          data['docId'] = doc.id;
          return data;
        }).toList();

        // Extract unique specializations
        Set<String> specSet = {'All'};
        for (var doctor in tempDoctors) {
          if (doctor['specialization'] != null) {
            specSet.add(doctor['specialization']);
          }
        }

        setState(() {
          doctors = tempDoctors;
          filteredDoctors = tempDoctors;
          specializations = specSet.toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      print("Error fetching doctors: $error");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterDoctors(String specialization) {
    setState(() {
      _selectedSpecialization = specialization;
      if (specialization == 'All') {
        filteredDoctors = doctors;
      } else {
        filteredDoctors = doctors.where((doctor) =>
        doctor['specialization'] == specialization).toList();
      }
    });
  }

  void _showDeleteDialog(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: const Text("Are you sure you want to delete this dentist?"),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel", style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance.collection('users').doc(docId).delete();
                setState(() {
                  doctors.removeWhere((doctor) => doctor['docId'] == docId);
                  _filterDoctors(_selectedSpecialization);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Dentist deleted successfully')),
                );
              } catch (e) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting dentist: $e')),
                );
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorItem(Map<String, dynamic> doctor) {
    String? imageUrl = doctor['profileImage'];
    Color specColor = _getSpecializationColor(doctor['specialization'] ?? 'General');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Specialization header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: specColor.withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.medical_services, size: 18, color: specColor),
                const SizedBox(width: 8),
                Text(
                  doctor['specialization'] ?? 'General Dentistry',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: specColor,
                  ),
                ),
              ],
            ),
          ),
          // Doctor details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Profile Image
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blue.shade50,
                  backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                      ? NetworkImage(imageUrl)
                      : const AssetImage('assets/Images/avatar.png') as ImageProvider,
                  child: imageUrl == null || imageUrl.isEmpty
                      ? const Icon(Icons.person, size: 40, color: Colors.blue)
                      : null,
                ),
                const SizedBox(width: 16),
                // Doctor Information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Dr. ${doctor['userName'] ?? 'No Name'}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: "GoogleSans",
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              doctor['location'] ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontFamily: "GoogleSans",
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                            ),
                          )


                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.exposure, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            doctor['experience'] != null && doctor['experience'].toString().isNotEmpty
                            ? '${doctor['experience']} years of experience'
                                : '',
                              style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontFamily: "GoogleSans",
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Delete Button
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.delete, color: Colors.red),
                  ),
                  onPressed: () => _showDeleteDialog(doctor['docId']),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getSpecializationColor(String specialization) {
    final colors = {
      'Orthodontics': Colors.purple,
      'Periodontics': Colors.green,
      'Endodontics': Colors.blue,
      'Prosthodontics': Colors.orange,
      'Pediatric Dentistry': Colors.pink,
      'Oral Surgery': Colors.red,
    };
    return colors[specialization] ?? Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Manage Dentists",
          style: TextStyle(
            fontSize: 18,
            fontFamily: "GoogleSans",
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  "Filter Dentists",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: "GoogleSans",
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButton<String>(
                    value: _selectedSpecialization,
                    isExpanded: true,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
                    items: specializations.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            fontFamily: "GoogleSans",
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      _filterDoctors(newValue!);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: filteredDoctors.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/Images/doctors.png',
                      width: 200,
                      height: 200,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "No dentists found",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                        fontFamily: "GoogleSans",
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedSpecialization == 'All'
                          ? "There are no dentists registered"
                          : "No dentists for $_selectedSpecialization",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontFamily: "GoogleSans",
                      ),
                    ),
                  ],
                ),
              )
                  : RefreshIndicator(
                onRefresh: _fetchDoctors,
                child: ListView.builder(
                  itemCount: filteredDoctors.length,
                  itemBuilder: (context, index) {
                    return _buildDoctorItem(filteredDoctors[index]);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}