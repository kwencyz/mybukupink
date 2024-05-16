// ignore_for_file: prefer_interpolation_to_compose_strings, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
                      "Anda telah hamil selama",
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('records')
                        .doc(user.uid)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }

                      if (!snapshot.hasData) {
                        return Text("No data found.");
                      }

                      final data =
                          snapshot.data!.data() as Map<String, dynamic>?;

                      Timestamp? startTimestamp;
                      if (data != null && data.containsKey('start')) {
                        startTimestamp = data['start'] as Timestamp;
                      }

                      DateTime? startDate;
                      if (startTimestamp != null) {
                        startDate = startTimestamp.toDate();
                      }

                      if (startDate == null) {
                        return Container(
                          margin: const EdgeInsets.only(
                              left: 30, right: 20, bottom: 20),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "- Minggu",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                            ),
                          ),
                        );
                      }

                      final now = DateTime.now();
                      final difference = now.difference(startDate);
                      final weeks = (difference.inDays / 7).floor();

                      return Container(
                        margin: const EdgeInsets.only(
                            left: 30, right: 20, bottom: 20),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "$weeks Minggu",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                          ),
                        ),
                      );
                    },
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
