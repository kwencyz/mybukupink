// ignore_for_file: prefer_const_constructors, avoid_print

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mybukupink/screens/user_screen.dart';
import 'package:uuid/uuid.dart';

class RegisterHusbandScreen extends StatefulWidget {
  const RegisterHusbandScreen({super.key});

  @override
  State<RegisterHusbandScreen> createState() => _RegisterHusbandScreenState();
}

class _RegisterHusbandScreenState extends State<RegisterHusbandScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  final uuid = Uuid();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _icController = TextEditingController();
  final _etnikController = TextEditingController();
  final _nationalController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _icController.dispose();
    _etnikController.dispose();
    _nationalController.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ralat'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  String _phoneErrorMessage = '';
  String _icErrorMessage = '';

  void _validatePhoneNumber(String value) {
    if (!value.startsWith('0') || value.length > 11) {
      setState(() {
        _phoneErrorMessage =
            'No. telefon mesti bermula dengan 0 dan tidak melebihi 11 digit';
      });
    } else {
      setState(() {
        _phoneErrorMessage = '';
      });
    }
  }

  void _validateIc(String value) {
    if (!(value.length == 12)) {
      setState(() {
        _icErrorMessage = 'No. Kad Pengenalan mesti 12 digit';
      });
    } else {
      setState(() {
        _icErrorMessage = '';
      });
    }
  }

  Future<void> updateHusband() async {
    try {
      // Validate text fields
      if (_nameController.text.trim().isEmpty ||
          _phoneController.text.trim().isEmpty ||
          _icController.text.trim().isEmpty ||
          _etnikController.text.trim().isEmpty ||
          _nationalController.text.trim().isEmpty) {
        _showErrorDialog('Sila isikan semua ruangan');
        return;
      }

      // Initialize Firestore
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      String husbandId = uuid.v4();

      // Create a new user document
      final patient = <String, dynamic>{
        "uid": user.uid,
        "husbandId": husbandId,
        "nameHusband": _nameController.text.trim(),
        "phoneHusband": _phoneController.text.trim(),
        "icHusband": _icController.text.trim(),
        "etnikHusband": _etnikController.text.trim(),
        "nationalHusband": _nationalController.text.trim(),
      };

      await firestore.collection("patientHusband").doc(husbandId).set(patient);

      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => UserScreen()),
      );

      print('User data uploaded successfully');
    } catch (e) {
      print('Error uploading user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: [
            //Hello Again
            Row(
              children: [
                Container(
                  margin: EdgeInsets.all(30),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Maklumat Bapa",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                ),
                SizedBox(width: 30),
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

            SizedBox(height: 20),

            //nama Bapa
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Nama Bapa',
                      contentPadding: EdgeInsets.all(10.0)),
                ),
              ),
            ),

            SizedBox(height: 10),

            //nombor telefon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Nombor Telefon',
                      errorText: _phoneErrorMessage.isNotEmpty
                          ? _phoneErrorMessage
                          : null,
                      contentPadding: EdgeInsets.all(10.0)),
                  onChanged: _validatePhoneNumber,
                ),
              ),
            ),

            SizedBox(height: 10),

            //nombor kad pengenalan
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _icController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(12),
                  ],
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: 'No. Kad Pengenalan',
                      errorText:
                          _icErrorMessage.isNotEmpty ? _icErrorMessage : null,
                      contentPadding: EdgeInsets.all(10.0)),
                  onChanged: _validateIc,
                ),
              ),
            ),

            SizedBox(height: 10),

            //etnik
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _etnikController,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Etnik',
                      contentPadding: EdgeInsets.all(10.0)),
                ),
              ),
            ),

            SizedBox(height: 10),

            //warganegara
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _nationalController,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Warganegara',
                      contentPadding: EdgeInsets.all(10.0)),
                ),
              ),
            ),

            SizedBox(height: 100),

            //sign in button
            SizedBox(
              height: 45,
              width: 350,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(255, 53, 139, 1),
                  side: BorderSide(width: 1, color: Colors.white),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.all(10),
                ),
                onPressed: updateHusband,
                child: Text(
                  'Kemaskini',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            SizedBox(height: 30),
          ]),
        ),
      ),
    );
  }
}
