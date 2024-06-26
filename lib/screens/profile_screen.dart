// ignore_for_file: prefer_interpolation_to_compose_strings, prefer_const_constructors, non_constant_identifier_names, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mybukupink/screens/maternal_screen.dart';
import 'package:mybukupink/screens/user_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser!;

  Future<void> fetchPatientData() async {
    try {
      // Fetch patient data from Firestore
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot documentSnapshot =
          await firestore.collection('patient').doc(user.uid).get();

      // Update _userEmail with the fetched email
      setState(() {
        _userName = documentSnapshot['name'];
        _userPhone = documentSnapshot['phone'];
      });
    } catch (e) {
      print('Error fetching patient data: $e');
      // Handle error
    }
  }

  late String _userName = 'Loading...';
  late String _userPhone = 'Loading...';

  @override
  void initState() {
    super.initState();
    fetchPatientData();
  }
  

  String imageUrl = '';

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
                  Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(
                            left: 30, right: 20, bottom: 20),
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          "Profil Ibu",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 24),
                        ),
                      ),
                      const SizedBox(width: 150),
                      Container(
                        alignment: Alignment.centerRight,
                        child: Image.asset(
                          "assets/images/logo.png",
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 30, right: 30),
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadiusDirectional.circular(20),
                        ),
                        child: Row(
                          children: [
                            Column(
                              children: [
                                FutureBuilder<DocumentSnapshot>(
                                  future: FirebaseFirestore.instance
                                      .collection('patient')
                                      .doc(user.uid)
                                      .get(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<DocumentSnapshot>
                                          snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
                                      }
                                      if (snapshot.hasData &&
                                          snapshot.data != null) {
                                        final data = snapshot.data!.data()
                                            as Map<String, dynamic>;
                                        final imageUrl = data['profilepic'];
                                        return imageUrl != null
                                            ? ClipOval(
                                                child: Image.network(
                                                  imageUrl,
                                                  height: 150,
                                                  width: 150,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : Image.asset(
                                                "assets/icons/noprofile.png",
                                                width: 150,
                                                height: 150,
                                                fit: BoxFit.contain,
                                              );
                                      }
                                    }
                                    return CircularProgressIndicator();
                                  },
                                ),
                              ],
                            ),
                            SizedBox(width: 30),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _userName,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  _userPhone,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Container(
                    margin: EdgeInsets.only(left: 30, right: 30),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                          child: Row(
                            children: [
                              Image.asset("assets/icons/user.png", width: 25),
                              SizedBox(width: 20),
                              Text(
                                'Maklumat Ibu',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Spacer(),
                              Image.asset("assets/icons/arrow.png", width: 25),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserScreen(),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 10),
                        Divider(),
                        SizedBox(height: 10),
                        GestureDetector(
                          child: Row(
                            children: [
                              Image.asset("assets/icons/health.png", width: 25),
                              SizedBox(width: 20),
                              Text(
                                'Rekod Kesihatan Ibu',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Spacer(),
                              Image.asset("assets/icons/arrow.png", width: 25),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MaternalScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 250),
                  Container(
                    width: 150,
                    height: 50,
                    padding: EdgeInsets.only(left: 15, right: 15),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(255, 53, 139, 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        FirebaseAuth.instance.signOut();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/icons/exit.png", width: 25),
                          SizedBox(width: 10),
                          Text(
                            'Log Keluar',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).padding.top,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
