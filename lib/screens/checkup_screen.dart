// ignore_for_file: prefer_interpolation_to_compose_strings, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CheckupScreen extends StatefulWidget {
  final String appointmentId;

  const CheckupScreen({Key? key, required this.appointmentId})
      : super(key: key);

  @override
  State<CheckupScreen> createState() => _CheckupScreenState();
}

class _CheckupScreenState extends State<CheckupScreen> {
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 20),
                      alignment: Alignment.centerRight,
                      child: Image.asset(
                        "assets/images/word.png",
                        width: 150,
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      margin:
                          const EdgeInsets.only(left: 30, right: 20, bottom: 0),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        "Rekod Pemeriksaan",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                    ),
                    SizedBox(height: 10),
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('appointment')
                          .doc(widget.appointmentId)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: Text("Error: ${snapshot.error}"));
                        }
                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return Center(child: Text("Appointment not found"));
                        }

                        final appointment = snapshot.data!;
                        final date = appointment['timestamp'] as Timestamp;
                        final title = appointment['title'];
                        final venue = appointment['venue'];
                        final formattedDate =
                            "${date.toDate().day}/${date.toDate().month}/${date.toDate().year}";
                        final hour = date.toDate().hour > 12
                            ? (date.toDate().hour - 12).toString()
                            : date.toDate().hour.toString();
                        final minute =
                            date.toDate().minute.toString().padLeft(2, '0');
                        final period = date.toDate().hour >= 12 ? 'PM' : 'AM';
                        final time = "$hour:$minute $period";
                        final dateTimeText = "$formattedDate, $time";

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          child: Container(
                            width: 500,
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  dateTimeText,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                                Text(
                                  venue,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 10),
                    Container(
                      margin:
                          const EdgeInsets.only(left: 30, right: 20, bottom: 0),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        "Maklumat Kesihatan",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                    ),
                    FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('checkup')
                          .where('appointmentId',
                              isEqualTo: widget.appointmentId)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: Text("Error: ${snapshot.error}"));
                        }
                        if (snapshot.data == null ||
                            snapshot.data!.docs.isEmpty) {
                          return Center(child: Text("Checkup data not found"));
                        }

                        final checkupData = snapshot.data!.docs[0];
                        // Extract data from the checkup document
                        final blood = checkupData['blood'];
                        final weight = checkupData['weight'];

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Tekanan Darah:",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          blood,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 28,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          "mmHg",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                  width:
                                      10), // Add space between the containers
                              Container(
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Berat Badan:",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          weight,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 28,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          "kg",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Add more containers for additional fields if needed
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
