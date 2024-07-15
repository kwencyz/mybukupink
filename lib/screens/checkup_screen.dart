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

  Map<String, dynamic>? checkupData;

  @override
  void initState() {
    super.initState();
    _fetchCheckupData();
  }

  Future<void> _fetchCheckupData() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('checkup')
        .where('appointmentId', isEqualTo: widget.appointmentId)
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
                                    Row(
                                      children: [
                                        Text(
                                          "Tekanan Darah",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Image.asset(
                                          "assets/icons/heart.png",
                                          width: 20,
                                          height: 20,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                                    Row(
                                      children: [
                                        Text(
                                          "Berat Badan",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Image.asset(
                                          "assets/icons/scale.png",
                                          width: 20,
                                          height: 20,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          weight.toString(),
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
                            ],
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
                        "Pemeriksaan Jangkamasa",
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
                        final womb = checkupData['womb'];
                        final weeks = checkupData['weeks'];

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
                                      "Tempoh Hamil",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          weeks.toString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 28,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          "minggu",
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
                                      "Tinggi Rahim",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          womb.toString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 28,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          "cm",
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
                            ],
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
                        "Pemeriksaan Janin",
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
                        final fetal = checkupData['fetal'];
                        final heartRate = checkupData['heartRate'];

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
                                      "Kedudukan",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text(
                                      fetal,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 28,
                                      ),
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
                                      "Jantung",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          heartRate.toString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 28,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          "bpm",
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
                            ],
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
                        "Keputusan Ujian Makmal",
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
                        final checkupId = checkupData.id;

                        return FutureBuilder<QuerySnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('lab')
                              .where('checkupId', isEqualTo: checkupId)
                              .get(),
                          builder: (context, labSnapshot) {
                            if (labSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            if (labSnapshot.hasError) {
                              return Center(
                                  child: Text("Error: ${labSnapshot.error}"));
                            }
                            if (labSnapshot.data == null ||
                                labSnapshot.data!.docs.isEmpty) {
                              return Center(child: Text("Lab data not found"));
                            }

                            final labData = labSnapshot.data!.docs[0];
                            final albumin = labData['albumin'];
                            final sugar = labData['sugar'];
                            final glucose = labData['glucose'];
                            final bilirubin = labData['bilirubin'];
                            final ketones = labData['ketones'];
                            final gravity = labData['gravity'];
                            final redBlood = labData['redBlood'];
                            final pH = labData['pH'];
                            final protein = labData['protein'];
                            final urobilinogen = labData['urobilinogen'];
                            final nitrites = labData['nitrites'];
                            final leukosit = labData['leukosit'];

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Albumin",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              albumin ? "+ve" : "-ve",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: albumin
                                                    ? Colors.red
                                                    : Colors.green,
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Switch(
                                              value: albumin,
                                              onChanged:
                                                  null, // Set to null to make the switch view-only
                                              activeTrackColor: Colors.red,
                                              activeColor: Colors.white,
                                              inactiveTrackColor: Colors
                                                  .green, // Change the inactive track color to green
                                              inactiveThumbColor: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Gula",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              sugar ? "+ve" : "-ve",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: sugar
                                                    ? Colors.red
                                                    : Colors.green,
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Switch(
                                              value: sugar,
                                              onChanged:
                                                  null, // Set to null to make the switch view-only
                                              activeTrackColor: Colors.red,
                                              activeColor: Colors.white,
                                              inactiveTrackColor: Colors
                                                  .green, // Change the inactive track color to green
                                              inactiveThumbColor: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Glukosa",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              glucose ? "+ve" : "-ve",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: glucose
                                                    ? Colors.red
                                                    : Colors.green,
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Switch(
                                              value: glucose,
                                              onChanged:
                                                  null, // Set to null to make the switch view-only
                                              activeTrackColor: Colors.red,
                                              activeColor: Colors.white,
                                              inactiveTrackColor: Colors
                                                  .green, // Change the inactive track color to green
                                              inactiveThumbColor: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Bilirubin",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              bilirubin ? "+ve" : "-ve",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: bilirubin
                                                    ? Colors.red
                                                    : Colors.green,
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Switch(
                                              value: bilirubin,
                                              onChanged:
                                                  null, // Set to null to make the switch view-only
                                              activeTrackColor: Colors.red,
                                              activeColor: Colors.white,
                                              inactiveTrackColor: Colors
                                                  .green, // Change the inactive track color to green
                                              inactiveThumbColor: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Ketones",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              ketones ? "+ve" : "-ve",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: ketones
                                                    ? Colors.red
                                                    : Colors.green,
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Switch(
                                              value: ketones,
                                              onChanged:
                                                  null, // Set to null to make the switch view-only
                                              activeTrackColor: Colors.red,
                                              activeColor: Colors.white,
                                              inactiveTrackColor: Colors
                                                  .green, // Change the inactive track color to green
                                              inactiveThumbColor: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Sel Darah Merah",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              redBlood ? "+ve" : "-ve",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: redBlood
                                                    ? Colors.red
                                                    : Colors.green,
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Switch(
                                              value: redBlood,
                                              onChanged:
                                                  null, // Set to null to make the switch view-only
                                              activeTrackColor: Colors.red,
                                              activeColor: Colors.white,
                                              inactiveTrackColor: Colors
                                                  .green, // Change the inactive track color to green
                                              inactiveThumbColor: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Protein",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              protein ? "+ve" : "-ve",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: protein
                                                    ? Colors.red
                                                    : Colors.green,
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Switch(
                                              value: protein,
                                              onChanged:
                                                  null, // Set to null to make the switch view-only
                                              activeTrackColor: Colors.red,
                                              activeColor: Colors.white,
                                              inactiveTrackColor: Colors
                                                  .green, // Change the inactive track color to green
                                              inactiveThumbColor: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Nitrites",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              nitrites ? "+ve" : "-ve",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: nitrites
                                                    ? Colors.red
                                                    : Colors.green,
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Switch(
                                              value: nitrites,
                                              onChanged:
                                                  null, // Set to null to make the switch view-only
                                              activeTrackColor: Colors.red,
                                              activeColor: Colors.white,
                                              inactiveTrackColor: Colors
                                                  .green, // Change the inactive track color to green
                                              inactiveThumbColor: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Leukosit",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              leukosit ? "+ve" : "-ve",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: leukosit
                                                    ? Colors.red
                                                    : Colors.green,
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Switch(
                                              value: leukosit,
                                              onChanged:
                                                  null, // Set to null to make the switch view-only
                                              activeTrackColor: Colors.red,
                                              activeColor: Colors.white,
                                              inactiveTrackColor: Colors
                                                  .green, // Change the inactive track color to green
                                              inactiveThumbColor: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    height: 50,
                                    padding:
                                        EdgeInsets.only(left: 15, right: 25),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Graviti Spesifik Urinari",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        Text(
                                          gravity.toString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    height: 50,
                                    padding:
                                        EdgeInsets.only(left: 15, right: 25),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "pH",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        Text(
                                          pH.toString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    height: 50,
                                    padding:
                                        EdgeInsets.only(left: 15, right: 25),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Urobilinogen",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              urobilinogen.toString(),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: Colors.black,
                                              ),
                                            ),
                                            SizedBox(width: 5),
                                            Text(
                                              "E.U/dl",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                    SizedBox(height: 10),
                    Container(
                      margin:
                          const EdgeInsets.only(left: 30, right: 20, bottom: 0),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        "Masalah dan Pengendalian",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                    ),
                    FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('advice')
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
                          return Center(child: Text("Advice data not found"));
                        }

                        final adviceData = snapshot.data!.docs[0];
                        final advice = adviceData['advice'];
                        final warning = adviceData['warning'];

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  advice,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                  textAlign: TextAlign.justify,
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                              SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  warning,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                  textAlign: TextAlign.justify,
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 50),
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
