// ignore_for_file: prefer_interpolation_to_compose_strings, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mybukupink/screens/appointment_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final user = FirebaseAuth.instance.currentUser!;

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
                        "Sejarah Kehamilan",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                    ),
                    FutureBuilder<QuerySnapshot>(
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
                          return Text("Tiada Sejarah Kehamilan Tersedia");
                        }

                        final records = recordSnapshot.data!.docs
                            .where((doc) => (doc.data() as Map<String, dynamic>)
                                .containsKey('end'))
                            .toList();

                        if (records.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            child: Text(
                              "Tiada Sejarah Kehamilan Tersedia",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            child: Container(
                              width: 500,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: records.length,
                                itemBuilder: (context, index) {
                                  final recordData = records[index].data()
                                      as Map<String, dynamic>?;

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

                                  Timestamp? endTimestamp;
                                  if (recordData != null &&
                                      recordData.containsKey('end')) {
                                    endTimestamp =
                                        recordData['end'] as Timestamp;
                                  }

                                  DateTime? endDate;
                                  if (endTimestamp != null) {
                                    endDate = endTimestamp.toDate();
                                  }

                                  final dateFormatter =
                                      DateFormat('dd/MM/yyyy');
                                  final startDateFormat = startDate != null
                                      ? dateFormatter.format(startDate)
                                      : "Tiada Data";
                                  final endDateFormat = endDate != null
                                      ? dateFormatter.format(endDate)
                                      : "Tiada Data";

                                  final titleDate = endDate != null
                                      ? DateFormat('yyyy').format(endDate)
                                      : (startDate != null
                                          ? DateFormat('yyyy').format(startDate)
                                          : "Tiada Data");

                                  final current =
                                      recordData?['current'] ?? "Tiada Data";
                                  final delivery =
                                      recordData?['delivery'] ?? "Tiada Data";
                                  final gender =
                                      recordData?['gender'] ?? "Tiada Data";
                                  final pob =
                                      recordData?['pob'] ?? "Tiada Data";
                                  final weight =
                                      recordData?['weight'] ?? "Tiada Data";
                                  final result =
                                      recordData?['result'] ?? "Tiada Data";

                                  final recordsId =
                                      recordData?['recordsId'] ?? "Tiada Data";

                                  if (result == 'Keguguran') {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        dividerColor: Colors.transparent,
                                      ),
                                      child: ExpansionTile(
                                        title: Text(
                                          titleDate,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Tarikh Hamil: ",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                    Spacer(),
                                                    Text(
                                                      startDateFormat,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Divider(),
                                                SizedBox(height: 10),
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Hasil Kandungan: ",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                    Spacer(),
                                                    Text(
                                                      result,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Divider(),
                                                SizedBox(height: 10),
                                                Container(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      fixedSize: Size(210, 50),
                                                      backgroundColor:
                                                          Colors.white,
                                                      side: BorderSide(
                                                          color: Colors.pink,
                                                          width: 1),
                                                    ),
                                                    onPressed: () {
                                                      // ignore: avoid_print
                                                      print(recordsId);
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              AppointmentScreen(
                                                            recordsId:
                                                                recordsId,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Image.asset(
                                                            "assets/icons/record.png",
                                                            width: 20),
                                                        SizedBox(width: 5),
                                                        Text(
                                                          'Rekod Pemeriksaan',
                                                          style: TextStyle(
                                                            color:
                                                                Color.fromRGBO(
                                                                    255,
                                                                    53,
                                                                    139,
                                                                    1),
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 10),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        dividerColor: Colors.transparent,
                                      ),
                                      child: ExpansionTile(
                                        title: Text(
                                          titleDate,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Tarikh Hamil: ",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                    Spacer(),
                                                    Text(
                                                      startDateFormat,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Divider(),
                                                SizedBox(height: 10),
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Tarikh Lahir: ",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                    Spacer(),
                                                    Text(
                                                      endDateFormat,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Divider(),
                                                SizedBox(height: 10),
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Hasil Kandungan: ",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                    Spacer(),
                                                    Text(
                                                      result,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Divider(),
                                                SizedBox(height: 10),
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Keadaan Anak: ",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                    Spacer(),
                                                    Text(
                                                      current,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Divider(),
                                                SizedBox(height: 10),
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Jenis Kelahiran: ",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                    Spacer(),
                                                    Text(
                                                      delivery,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Divider(),
                                                SizedBox(height: 10),
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Jantina: ",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                    Spacer(),
                                                    Text(
                                                      gender,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Divider(),
                                                SizedBox(height: 10),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Tempat Lahir: ",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                    Flexible(
                                                      child: Text(
                                                        pob,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18,
                                                        ),
                                                        overflow: TextOverflow
                                                            .visible,
                                                        textAlign:
                                                            TextAlign.right,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Divider(),
                                                SizedBox(height: 10),
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Berat Lahir: ",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                    Spacer(),
                                                    Text(
                                                      "$weight kg",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Divider(),
                                                SizedBox(height: 10),
                                                Container(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      fixedSize: Size(210, 50),
                                                      backgroundColor:
                                                          Colors.white,
                                                      side: BorderSide(
                                                          color: Colors.pink,
                                                          width: 1),
                                                    ),
                                                    onPressed: () {
                                                      // ignore: avoid_print
                                                      print(recordsId);
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              AppointmentScreen(
                                                            recordsId:
                                                                recordsId,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Image.asset(
                                                            "assets/icons/record.png",
                                                            width: 20),
                                                        SizedBox(width: 5),
                                                        Text(
                                                          'Rekod Pemeriksaan',
                                                          style: TextStyle(
                                                            color:
                                                                Color.fromRGBO(
                                                                    255,
                                                                    53,
                                                                    139,
                                                                    1),
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 10),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    SizedBox(height: 800),
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
