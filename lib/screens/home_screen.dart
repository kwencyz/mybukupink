// ignore_for_file: prefer_const_constructors

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
  int selectedTrimesterIndex = 0;

  @override
  void initState() {
    super.initState();
    _calculateCurrentTrimester();
  }

  void _calculateCurrentTrimester() async {
    final DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('records')
        .doc(user.uid)
        .get();

    final data = snapshot.data() as Map<String, dynamic>?;
    Timestamp? startTimestamp;
    if (data != null && data.containsKey('start')) {
      startTimestamp = data['start'] as Timestamp;
    }

    DateTime? startDate;
    if (startTimestamp != null) {
      startDate = startTimestamp.toDate();
    }

    if (startDate != null) {
      final now = DateTime.now();
      final difference = now.difference(startDate);
      final weeks = (difference.inDays / 7).floor();

      int trimester;
      if (weeks < 12) {
        trimester = 0;
      } else if (weeks < 28) {
        trimester = 1;
      } else {
        trimester = 2;
      }

      setState(() {
        selectedTrimesterIndex = trimester;
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
                            "Tiada data kehamilan tersedia",
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

                      final List<Map<String, String>> trimesters = [
                        {
                          'trimester': "Pertama",
                          'duration': "Kurang daripada 12 Minggu",
                          'article':
                              "Perubahan fizikal tubuh badan adalah perkara yang paling jelas berlaku sewaktu trimester pertama. Antara perubahan yang mungkin anda alami seperti keletihan, loya dan payudara menjadi lebih lembut.",
                        },
                        {
                          'trimester': "Kedua",
                          'duration': "13 hingga ke 27 Minggu",
                          'article':
                              "Pada trimester kedua, bayi di dalam kandungan anda akan terbentuk dengan lebih jelas. Anda sudah boleh merasakan pergerakan bayi pada trimester ini. Selain itu, pendengaran bayi anda juga sudah mula terbentuk pada fasa ini.",
                        },
                        {
                          'trimester': "Ketiga",
                          'duration': "28 hingga 40 Minggu",
                          'article':
                              "Pada ketika ini, anda mungkin agak sukar untuk bergerak memandangkan fizikal perut yang semakin besar. Pada fasa ini juga, ia mungkin lebih mencabar berbanding trimester pertama dan kedua.",
                        },
                      ];

                      return Column(
                        children: [
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
                                left: 30, right: 20, bottom: 20),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "$weeks Minggu",
                              style: TextStyle(
                                color: Color.fromRGBO(56, 56, 56, 1),
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    selectedTrimesterIndex = 0;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: selectedTrimesterIndex == 0
                                      ? Color.fromRGBO(255, 53, 139, 1)
                                      : Colors.grey,
                                ),
                                child: Text(
                                  'Trimester 1',
                                  style: TextStyle(
                                    color: selectedTrimesterIndex == 0
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    selectedTrimesterIndex = 1;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: selectedTrimesterIndex == 1
                                      ? Color.fromRGBO(255, 53, 139, 1)
                                      : Colors.grey,
                                ),
                                child: Text(
                                  'Trimester 2',
                                  style: TextStyle(
                                    color: selectedTrimesterIndex == 1
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    selectedTrimesterIndex = 2;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: selectedTrimesterIndex == 2
                                      ? Color.fromRGBO(255, 53, 139, 1)
                                      : Colors.grey,
                                ),
                                child: Text(
                                  'Trimester 3',
                                  style: TextStyle(
                                    color: selectedTrimesterIndex == 2
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Container(
                            width: 400,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Color.fromRGBO(218, 234, 246, 1),
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Trimester ${trimesters[selectedTrimesterIndex]['trimester']}",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(56, 56, 56, 1),
                                  ),
                                ),
                                Text(
                                  trimesters[selectedTrimesterIndex]
                                      ['duration']!,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(102, 102, 102, 1),
                                  ),
                                ),
                                SizedBox(height: 20),
                                Text(
                                  trimesters[selectedTrimesterIndex]
                                      ['article']!,
                                  textAlign: TextAlign.justify,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(56, 56, 56, 1),
                                  ),
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ],
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
