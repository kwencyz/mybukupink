// ignore_for_file: prefer_interpolation_to_compose_strings, prefer_const_constructors, non_constant_identifier_names, avoid_print

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mybukupink/screens/maternal_screen.dart';

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
        _userEmail = documentSnapshot['email'];
        _userName = documentSnapshot['name'];
      });
    } catch (e) {
      print('Error fetching patient data: $e');
      // Handle error
    }
  }

  late String _userEmail = 'Loading...';
  late String _userName = 'Loading...';

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
                image: AssetImage('assets/images/background.png'),
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
                      const SizedBox(width: 130),
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
                  SizedBox(height: 30),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('patient')
                            .doc(user.uid)
                            .get(),
                        builder: (BuildContext context,
                            AsyncSnapshot<DocumentSnapshot> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }
                            if (snapshot.hasData && snapshot.data != null) {
                              final data =
                                  snapshot.data!.data() as Map<String, dynamic>;
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
                      SizedBox(height: 10),
                      GestureDetector(
                        onTap: () async {
                          ImagePicker imagePicker = ImagePicker();
                          XFile? file = await imagePicker.pickImage(
                              source: ImageSource.gallery);
                          print('${(file?.path)}');

                          if (file == null) return;

                          String fileName =
                              DateTime.now().millisecondsSinceEpoch.toString();

                          Reference referenceRoot =
                              FirebaseStorage.instance.ref();
                          Reference referenceDirImages =
                              referenceRoot.child('profilePic');

                          Reference referenceImageToUpload =
                              referenceDirImages.child(fileName);
                          try {
                            // Get the file extension
                            String extension = file.path.split('.').last;

                            // Set the content type based on the file extension
                            String contentType =
                                'image/jpeg'; // Default content type for images
                            if (extension == 'png') {
                              contentType = 'image/png';
                            } else if (extension == 'jpg' ||
                                extension == 'jpeg') {
                              contentType = 'image/jpeg';
                            }

                            // Upload the file to Firebase Storage with the specified content type
                            await referenceImageToUpload.putFile(
                              File(file.path),
                              SettableMetadata(contentType: contentType),
                            );
                            imageUrl =
                                await referenceImageToUpload.getDownloadURL();
                            print(
                                'Image uploaded to Firebase Storage: $imageUrl');

                            // Upload the imageUrl to Firestore
                            await FirebaseFirestore.instance
                                .collection('patient')
                                .doc(user.uid)
                                .update({'profilepic': imageUrl});
                            print('ImageUrl uploaded to Firestore: $imageUrl');

                            // Update the UI with the new image URL
                            setState(() {
                              imageUrl = imageUrl;
                            });
                          } catch (error) {
                            print('Error uploading image: $error');
                          }
                        },
                        child: Text(
                          'Kemaskini Gambar Profil',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30.0,
                    ),
                    child: Container(
                      width: 400,
                      padding: EdgeInsets.all(10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _userEmail,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30.0,
                    ),
                    child: Container(
                      width: 400,
                      padding: EdgeInsets.all(10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _userName,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30.0,
                    ),
                    child: Container(
                      width: 400,
                      padding: EdgeInsets.all(10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: GestureDetector(
                        child: Text(
                          'Riwayat Kesihatan Ibu',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MaternalScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 200),
                  GestureDetector(
                    onTap: () {
                      FirebaseAuth.instance.signOut();
                    },
                    child: const Text(
                      'Log Keluar',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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
