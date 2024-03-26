// ignore_for_file: prefer_interpolation_to_compose_strings, prefer_const_constructors, avoid_print, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ArticleScreen extends StatefulWidget {
  final String data;

  const ArticleScreen({super.key, required this.data});

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  final user = FirebaseAuth.instance.currentUser!;

  late String articleId;

  @override
  void initState() {
    super.initState();
    articleId = widget.data;
  }

/*   @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args != null) {
        setState(() {
          articleId = args as String;
        });
      }
    });
  } */

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
                    margin: const EdgeInsets.only(left: 10, right: 20),
                    alignment: Alignment.centerLeft,
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('article')
                          .doc(articleId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return CircularProgressIndicator();
                        }

                        var articleData =
                            snapshot.data!.data() as Map<String, dynamic>;
                        var articleTitle = articleData['title'] as String?;

                        return Text(
                          articleTitle ?? 'Article Title',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 22),
                        );
                      },
                    ),
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
