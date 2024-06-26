// ignore_for_file: prefer_interpolation_to_compose_strings, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mybukupink/screens/checkup_screen.dart';

class AppointmentScreen extends StatefulWidget {
  final String recordsId;

  const AppointmentScreen({Key? key, required this.recordsId})
      : super(key: key);

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final user = FirebaseAuth.instance.currentUser!;

  Map<String, dynamic>? checkupData;

  @override
  void initState() {
    super.initState();
    _fetchCheckupData();
  }

  Future<void> _fetchCheckupData() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('appointment')
        .where('recordsId', isEqualTo: widget.recordsId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        checkupData = snapshot.docs[0].data() as Map<String, dynamic>?;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/pinkbg.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
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
                  FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('records')
                        .where('uid', isEqualTo: user.uid)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }

                      if (!snapshot.hasData) {
                        return Text("No data found.");
                      }

                      final data = snapshot.data!.docs.first.data()
                          as Map<String, dynamic>?;

                      Timestamp? startTimestamp;
                      if (data != null && data.containsKey('start')) {
                        startTimestamp = data['start'] as Timestamp;
                      }

                      DateTime startDate = DateTime.now();
                      if (startTimestamp != null) {
                        startDate = startTimestamp.toDate();
                      }

                      final now = DateTime.now();
                      final difference = now.difference(startDate);
                      final weeks = (difference.inDays / 7).floor();

                      final status = data?['status'] ?? '';

                      if (status == 'hamil') {
                        return Column(children: [
                          Container(
                            margin: const EdgeInsets.only(left: 30, right: 20),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Anda telah hamil selama",
                              style: TextStyle(
                                color: Color.fromRGBO(56, 56, 56, 1),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                                left: 30, right: 20, bottom: 10),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "$weeks Minggu",
                              style: TextStyle(
                                color: Color.fromRGBO(56, 56, 56, 1),
                                fontWeight: FontWeight.bold,
                                fontSize: 40,
                              ),
                            ),
                          )
                        ]);
                      }
                      return Container();
                    },
                  ),
                  Container(
                    margin:
                        const EdgeInsets.only(left: 30, right: 20, bottom: 20),
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      "Jadual Temujanji Anda",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('appointment')
                          .where('recordsId', isEqualTo: widget.recordsId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Text("No appointments found.");
                        }

                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final appointments = snapshot.data!.docs;
                            appointments.sort((a, b) {
                              final dateA = a['timestamp'] as Timestamp;
                              final dateB = b['timestamp'] as Timestamp;
                              return dateB
                                  .compareTo(dateA); // Sort in descending order
                            });

                            final appointment = appointments[index];
                            final date = appointment['timestamp'] as Timestamp;
                            final title = appointment['title'];
                            final formattedDate =
                                "${date.toDate().day}/${date.toDate().month}/${date.toDate().year}";
                            final hour = date.toDate().hour > 12
                                ? (date.toDate().hour - 12).toString()
                                : date.toDate().hour.toString();
                            final minute =
                                date.toDate().minute.toString().padLeft(2, '0');
                            final period =
                                date.toDate().hour >= 12 ? 'PM' : 'AM';
                            final time = "$hour:$minute $period";

                            return ListTile(
                              title: Container(
                                width: 300,
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      formattedDate,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                      ),
                                    ),
                                    Text(
                                      time,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
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
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CheckupScreen(
                                        appointmentId: appointment.id),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
