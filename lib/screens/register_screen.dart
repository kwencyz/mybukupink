// ignore_for_file: prefer_const_constructors, avoid_print

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback showLoginScreen;
  const RegisterScreen({Key? key, required this.showLoginScreen})
      : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _icController = TextEditingController();
  final TextEditingController _etnikController = TextEditingController();
  final TextEditingController _nationalController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
  String _emailErrorMessage = '';

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

  void _validateEmail(String value) {
    const pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
    final regExp = RegExp(pattern);

    if (!regExp.hasMatch(value)) {
      setState(() {
        _emailErrorMessage = 'Sila masukkan emel yang sah';
      });
    } else {
      setState(() {
        _emailErrorMessage = '';
      });
    }
  }

  bool _isPasswordVisible = false;

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future<void> signUp() async {
    try {
      // Validate text fields
      if (_nameController.text.trim().isEmpty ||
          _phoneController.text.trim().isEmpty ||
          _icController.text.trim().isEmpty ||
          _emailController.text.trim().isEmpty ||
          _passwordController.text.trim().isEmpty ||
          _etnikController.text.trim().isEmpty ||
          _nationalController.text.trim().isEmpty) {
        _showErrorDialog('Sila isikan semua ruangan');
        return;
      }

      // Create user in FirebaseAuth
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Get the user's uid
      String uid = userCredential.user!.uid;

      // Initialize Firestore
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Create a new user document
      final patient = <String, dynamic>{
        "uid": uid,
        "name": _nameController.text.trim(),
        "phone": _phoneController.text.trim(),
        "ic": _icController.text.trim(),
        "email": _emailController.text.trim(),
        "etnik": _etnikController.text.trim(),
        "national": _nationalController.text.trim(),
        "status": "tidak hamil",
      };

      // Add the user document to the "patient" collection
      await firestore.collection("patient").doc(uid).set(patient);

      print('User signed up successfully with UID: $uid');
    } catch (e) {
      if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
        _showErrorDialog('Email sudah digunakan. Sila gunakan email lain.');
      } else {
        print('Error signing up: $e');
        _showErrorDialog(
            'Tidak boleh mendaftar. Sila periksa setiap ruangan diisi dengan betul.');
      }
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
                    "Daftar Pengguna",
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

            //nama ibu
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
                      labelText: 'Nama Ibu',
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
                    errorText: _phoneErrorMessage.isNotEmpty ? _phoneErrorMessage : null,
                    contentPadding: EdgeInsets.all(10.0),
                  ),
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
                    errorText: _icErrorMessage.isNotEmpty ? _icErrorMessage : null,
                    contentPadding: EdgeInsets.all(10.0),
                  ),
                  onChanged: _validateIc,
                ),
              ),
            ),

            SizedBox(height: 10),

            //email
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: 'Emel',
                    errorText: _emailErrorMessage.isNotEmpty ? _emailErrorMessage : null,
                    contentPadding: EdgeInsets.all(10.0),
                  ),
                  onChanged: _validateEmail,
                ),
              ),
            ),

            SizedBox(height: 10),

            //password
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: 'Kata Laluan',
                    contentPadding: EdgeInsets.all(10.0),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                  ),
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
            Container(
              padding: EdgeInsets.only(left: 30, right: 30),
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(255, 53, 139, 1),
                  side: BorderSide(width: 1, color: Colors.white),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.all(10),
                ),
                onPressed: signUp,
                child: Text(
                  'Daftar Masuk',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            SizedBox(height: 30),

            // register
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Sudah mempunyai akaun?'),
                GestureDetector(
                  onTap: widget.showLoginScreen,
                  child: Text(
                    ' Log Masuk',
                    style: TextStyle(
                      color: Color.fromRGBO(255, 53, 139, 1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(' sekarang!'),
              ],
            ),
            SizedBox(height: 50),
          ]),
        ),
      ),
    );
  }
}
