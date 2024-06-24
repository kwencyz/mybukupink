// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mybukupink/screens/appointment_screen.dart';
import 'package:mybukupink/screens/history_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  int selectedTrimesterIndex = 0;

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

  @override
  void initState() {
    super.initState();
    _checkStatusAndCalculate();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkAndShowMessage();
    });
  }

  Future<void> _checkAndShowMessage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasShownMessage = prefs.getBool('hasShownMessage') ?? false;

    if (!hasShownMessage) {
      final patientSnapshot = await FirebaseFirestore.instance
          .collection('patient')
          .where('uid', isEqualTo: user.uid)
          .get();

      if (patientSnapshot.docs.isNotEmpty) {
        final data = patientSnapshot.docs.first.data() as Map<String, dynamic>?;
        final status = data?['status'];

        if (status == 'tidak hamil') {
          _showPopupMessage("Selamat Datang",
              "Sila hadir ke klinik kesihatan sekiranya anda hamil.");
        }
      }

      await prefs.setBool('hasShownMessage', true);
    }
  }

  Future<List<QueryDocumentSnapshot>> fetchRecords() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('records')
        .where('uid', isEqualTo: user.uid)
        .get();
    return snapshot.docs
        .where((doc) => !doc.data().containsKey('end'))
        .toList();
  }

  void _showPopupMessage(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkStatusAndCalculate() async {
    final DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('patient')
        .doc(user.uid)
        .get();

    if (!snapshot.exists) {
      // Handle case where no document is found for the user
      return;
    }

    final data = snapshot.data() as Map<String, dynamic>?;

    if (data == null) {
      // Handle case where data is null
      return;
    }

    final status = data['status'];
    if (status == 'hamil') {
      _calculateCurrentTrimester();
    }
  }

  void _calculateCurrentTrimester() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('records')
        .where('uid', isEqualTo: user.uid)
        .get();

    if (snapshot.docs.isEmpty) {
      // Handle case where no records are found for the user
      return;
    }

    final data = snapshot.docs.first.data() as Map<String, dynamic>?;
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
      if (weeks <= 12) {
        trimester = 0;
      } else if (weeks > 12 && weeks < 28) {
        trimester = 1;
      } else {
        trimester = 2;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          selectedTrimesterIndex = trimester;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
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
                    FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('patient')
                          .where('uid', isEqualTo: user.uid)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Text("No data found.");
                        }

                        final data = snapshot.data!.docs.first.data()
                            as Map<String, dynamic>?;

                        if (data == null || !data.containsKey('status')) {
                          return Text("Status not found.");
                        }

                        final status = data['status'];

                        if (status == "tidak hamil") {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/pregnant.png',
                                width: 400,
                              ),
                              Text(
                                "Selamat Datang Ke MyBukuPink",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                width: 400,
                                padding: EdgeInsets.all(5),
                                child: Text(
                                  "Kami di sini untuk menyokong anda dalam setiap langkah perjalanan kehamilan anda.",
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(height: 20),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  fixedSize: Size.fromWidth(400),
                                  backgroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HistoryScreen()),
                                  );
                                },
                                child: Text(
                                  'Sejarah Kehamilan',
                                  style: TextStyle(
                                    color: Color.fromRGBO(255, 53, 139, 1),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              SizedBox(height: 100),
                            ],
                          );
                        } else if (status == "hamil") {
                          return FutureBuilder<QuerySnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('records')
                                .where('uid', isEqualTo: user.uid)
                                .get(),
                            builder: (context, recordSnapshot) {
                              if (recordSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              }

                              if (!recordSnapshot.hasData ||
                                  recordSnapshot.data!.docs.isEmpty) {
                                return Text("No record data found.");
                              }

                              final recordData = recordSnapshot.data!.docs.first
                                  .data() as Map<String, dynamic>?;

                              Timestamp? startTimestamp;
                              if (recordData != null &&
                                  recordData.containsKey('start')) {
                                startTimestamp =
                                    recordData['start'] as Timestamp;
                              }

                              DateTime? startDate;
                              if (startTimestamp != null) {
                                startDate = startTimestamp.toDate();
                              }

                              final now = DateTime.now();
                              final difference = now.difference(startDate!);
                              final weeks = (difference.inDays / 7).floor();

                              return Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(
                                        left: 30, right: 20),
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
                                        fontSize: 40,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            selectedTrimesterIndex = 0;
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              selectedTrimesterIndex == 0
                                                  ? Color.fromRGBO(
                                                      255, 53, 139, 1)
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
                                          backgroundColor:
                                              selectedTrimesterIndex == 1
                                                  ? Color.fromRGBO(
                                                      255, 53, 139, 1)
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
                                          backgroundColor:
                                              selectedTrimesterIndex == 2
                                                  ? Color.fromRGBO(
                                                      255, 53, 139, 1)
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Trimester ${trimesters[selectedTrimesterIndex]['trimester']}",
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Color.fromRGBO(56, 56, 56, 1),
                                          ),
                                        ),
                                        Text(
                                          trimesters[selectedTrimesterIndex]
                                              ['duration']!,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromRGBO(
                                                102, 102, 102, 1),
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
                                            color:
                                                Color.fromRGBO(56, 56, 56, 1),
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Container(
                                    width: 400,
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Color.fromRGBO(201, 241, 243, 1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Image.asset(
                                        'assets/images/trimester.gif'),
                                  ),
                                  SizedBox(height: 20),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      fixedSize: Size.fromWidth(400),
                                      backgroundColor: Colors.white,
                                    ),
                                    onPressed: () async {
                                      final records = await fetchRecords();
                                      if (records.isNotEmpty) {
                                        final recordsId = records.first.id;
                                        Navigator.push(
                                          // ignore: use_build_context_synchronously
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AppointmentScreen(
                                                    recordsId: recordsId),
                                          ),
                                        );
                                      } else {
                                        // ignore: use_build_context_synchronously
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content:
                                                  Text('Tiada Rekod Ditemui')),
                                        );
                                      }
                                    },
                                    child: Text(
                                      'Rekod Temujanji',
                                      style: TextStyle(
                                        color: Color.fromRGBO(255, 53, 139, 1),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      fixedSize: Size.fromWidth(400),
                                      backgroundColor: Colors.white,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                HistoryScreen()),
                                      );
                                    },
                                    child: Text(
                                      'Sejarah Kehamilan',
                                      style: TextStyle(
                                        color: Color.fromRGBO(255, 53, 139, 1),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 50),
                                ],
                              );
                            },
                          );
                        }
                        return SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
