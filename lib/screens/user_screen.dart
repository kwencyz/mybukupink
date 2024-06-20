// ignore_for_file: prefer_interpolation_to_compose_strings, prefer_const_constructors, avoid_print

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mybukupink/screens/register_husband_screen.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final user = FirebaseAuth.instance.currentUser!;

  String imageUrl = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Stack(
          children: [
            SafeArea(
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
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Text("No data found.");
                      }

                      final data = snapshot.data!.docs.first.data()
                          as Map<String, dynamic>?;

                      final name = data?['name'];
                      final etnik = data?['etnik'];
                      final ic = data?['ic'];
                      final national = data?['national'];
                      final phone = data?['phone'];

                      return Column(
                        children: [
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
                              SizedBox(height: 10),
                              GestureDetector(
                                onTap: () async {
                                  ImagePicker imagePicker = ImagePicker();
                                  XFile? file = await imagePicker.pickImage(
                                      source: ImageSource.gallery);

                                  if (file == null) return;

                                  String fileName = DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString();

                                  Reference referenceRoot =
                                      FirebaseStorage.instance.ref();
                                  Reference referenceDirImages =
                                      referenceRoot.child('profilePic');

                                  Reference referenceImageToUpload =
                                      referenceDirImages.child(fileName);
                                  try {
                                    // Get the file extension
                                    String extension =
                                        file.path.split('.').last;

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
                                      SettableMetadata(
                                          contentType: contentType),
                                    );
                                    imageUrl = await referenceImageToUpload
                                        .getDownloadURL();
                                    print(
                                        'Image uploaded to Firebase Storage: $imageUrl');

                                    // Upload the imageUrl to Firestore
                                    await FirebaseFirestore.instance
                                        .collection('patient')
                                        .doc(user.uid)
                                        .update({'profilepic': imageUrl});
                                    print(
                                        'ImageUrl uploaded to Firestore: $imageUrl');

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
                          SizedBox(height: 20),
                          Container(
                            margin: const EdgeInsets.only(
                                left: 30, right: 20, bottom: 20),
                            alignment: Alignment.centerLeft,
                            child: const Text(
                              "Maklumat Ibu",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 24),
                            ),
                          ),
                          Container(
                            width: 400,
                            padding: EdgeInsets.only(
                                left: 20, right: 20, bottom: 10, top: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.black26,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Nama:",
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  name,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            width: 400,
                            padding: EdgeInsets.only(
                                left: 20, right: 20, bottom: 10, top: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.black26,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "No Kad Pengenalan:",
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  ic,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            width: 400,
                            padding: EdgeInsets.only(
                                left: 20, right: 20, bottom: 10, top: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.black26,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "No Telefon:",
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  phone,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            width: 400,
                            padding: EdgeInsets.only(
                                left: 20, right: 20, bottom: 10, top: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.black26,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Etnik:",
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  etnik,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            width: 400,
                            padding: EdgeInsets.only(
                                left: 20, right: 20, bottom: 10, top: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.black26,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Warganegara:",
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  national,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 30),
                          Container(
                            margin: const EdgeInsets.only(
                                left: 30, right: 20, bottom: 10),
                            alignment: Alignment.centerLeft,
                            child: const Text(
                              "Maklumat Bapa",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 24),
                            ),
                          ),
                          FutureBuilder<QuerySnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('patientHusband')
                                .where('uid', isEqualTo: user.uid)
                                .get(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              }

                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      child:
                                          Text('Sila masukkan maklumat suami'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        fixedSize: Size.fromWidth(300),
                                        backgroundColor: Colors.white,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                RegisterHusbandScreen(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Kemaskini',
                                        style: TextStyle(
                                          color:
                                              Color.fromRGBO(255, 53, 139, 1),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 50),
                                  ],
                                );
                              }

                              final data = snapshot.data!.docs.first.data()
                                  as Map<String, dynamic>?;

                              final nameHusband = data?['nameHusband'];
                              final etnikHusband = data?['etnikHusband'];
                              final icHusband = data?['icHusband'];
                              final nationalHusband = data?['nationalHusband'];
                              final phoneHusband = data?['phoneHusband'];

                              return Column(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FutureBuilder<QuerySnapshot>(
                                        future: FirebaseFirestore.instance
                                            .collection('patientHusband')
                                            .where('uid', isEqualTo: user.uid)
                                            .get(),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<QuerySnapshot>
                                                snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return CircularProgressIndicator();
                                          }
                                          if (snapshot.hasError) {
                                            return Text(
                                                'Error: ${snapshot.error}');
                                          }
                                          if (!snapshot.hasData ||
                                              snapshot.data!.docs.isEmpty) {
                                            return Image.asset(
                                              "assets/icons/noprofile.png",
                                              width: 150,
                                              height: 150,
                                              fit: BoxFit.contain,
                                            );
                                          }
                                          final data = snapshot.data!.docs.first
                                              .data() as Map<String, dynamic>;
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
                                        },
                                      ),
                                      SizedBox(height: 10),
                                      GestureDetector(
                                        onTap: () async {
                                          ImagePicker imagePicker =
                                              ImagePicker();
                                          XFile? file =
                                              await imagePicker.pickImage(
                                                  source: ImageSource.gallery);

                                          if (file == null) return;

                                          String fileName = DateTime.now()
                                              .millisecondsSinceEpoch
                                              .toString();

                                          Reference referenceRoot =
                                              FirebaseStorage.instance.ref();
                                          Reference referenceDirImages =
                                              referenceRoot.child('profilePic');

                                          Reference referenceImageToUpload =
                                              referenceDirImages
                                                  .child(fileName);
                                          try {
                                            // Get the file extension
                                            String extension =
                                                file.path.split('.').last;

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
                                            await referenceImageToUpload
                                                .putFile(
                                              File(file.path),
                                              SettableMetadata(
                                                  contentType: contentType),
                                            );
                                            imageUrl =
                                                await referenceImageToUpload
                                                    .getDownloadURL();
                                            print(
                                                'Image uploaded to Firebase Storage: $imageUrl');

                                            // Upload the imageUrl to Firestore
                                            await FirebaseFirestore.instance
                                                .collection('patient')
                                                .doc(user.uid)
                                                .update(
                                                    {'profilepic': imageUrl});
                                            print(
                                                'ImageUrl uploaded to Firestore: $imageUrl');

                                            // Update the UI with the new image URL
                                            setState(() {
                                              imageUrl = imageUrl;
                                            });
                                          } catch (error) {
                                            print(
                                                'Error uploading image: $error');
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
                                  SizedBox(height: 20),
                                  Container(
                                    width: 400,
                                    padding: EdgeInsets.only(
                                        left: 20,
                                        right: 20,
                                        bottom: 10,
                                        top: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.black26,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Nama:",
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          nameHusband,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Container(
                                    width: 400,
                                    padding: EdgeInsets.only(
                                        left: 20,
                                        right: 20,
                                        bottom: 10,
                                        top: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.black26,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "No Kad Pengenalan:",
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          icHusband,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Container(
                                    width: 400,
                                    padding: EdgeInsets.only(
                                        left: 20,
                                        right: 20,
                                        bottom: 10,
                                        top: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.black26,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "No Telefon:",
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          phoneHusband,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Container(
                                    width: 400,
                                    padding: EdgeInsets.only(
                                        left: 20,
                                        right: 20,
                                        bottom: 10,
                                        top: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.black26,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Etnik:",
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          etnikHusband,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Container(
                                    width: 400,
                                    padding: EdgeInsets.only(
                                        left: 20,
                                        right: 20,
                                        bottom: 10,
                                        top: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.black26,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Warganegara:",
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          nationalHusband,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 50),
                                ],
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
