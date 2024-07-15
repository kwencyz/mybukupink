// ignore_for_file: prefer_interpolation_to_compose_strings, prefer_const_constructors, sized_box_for_whitespace, avoid_print, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mybukupink/screens/article_screen.dart';

class LifestyleScreen extends StatefulWidget {
  const LifestyleScreen({super.key});

  @override
  State<LifestyleScreen> createState() => _LifestyleScreenState();
}

class _LifestyleScreenState extends State<LifestyleScreen> {
  final user = FirebaseAuth.instance.currentUser!;

  String articleData = '';

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
                      child: Container(
                        padding: EdgeInsets.only(left: 15, right: 15),
                        child: Image.asset(
                          "assets/images/word.png",
                          width: 150,
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      margin: const EdgeInsets.only(left: 10, right: 20),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        "Carian Popular",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      margin: const EdgeInsets.only(left: 10),
                      height: 200,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('article')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          List<DocumentSnapshot>? articles =
                              snapshot.data?.docs;

                          if (articles == null || articles.isEmpty) {
                            return Center(
                              child: Text('Tiada artikel ditemui'),
                            );
                          }

                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount:
                                articles.length > 5 ? 5 : articles.length,
                            itemBuilder: (context, index) {
                              var article = articles[index].data();
                              var articleMap = article as Map<String, dynamic>;

                              return InkWell(
                                onTap: () async {
                                  var articleDoc = snapshot.data!.docs[index];
                                  var articleId = articleDoc.id;

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ArticleScreen(data: articleId),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20)),
                                  width: 160,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: Image.network(
                                            articleMap['image'] ?? '',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomLeft,
                                          child: Container(
                                            margin: EdgeInsets.all(10),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SizedBox(height: 8),
                                                Text(
                                                  articleMap['title'] ?? '',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
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
                              );
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      margin: const EdgeInsets.only(left: 10, right: 20),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        "Aktiviti Senaman",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      margin: const EdgeInsets.only(left: 10),
                      height: 200,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('article')
                            .where('category',
                                isEqualTo: 'exercise')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          List<DocumentSnapshot>? articles =
                              snapshot.data?.docs;

                          if (articles == null || articles.isEmpty) {
                            return Center(
                              child: Text('No articles found'),
                            );
                          }

                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: articles.length,
                            itemBuilder: (context, index) {
                              var article = articles[index].data();
                              var articleMap = article as Map<String, dynamic>;

                              return InkWell(
                                onTap: () async {
                                  var articleDoc = snapshot.data!.docs[index];
                                  var articleId = articleDoc.id;

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ArticleScreen(data: articleId),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20)),
                                  width: 160,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: Image.network(
                                            articleMap['image'] ?? '',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomLeft,
                                          child: Container(
                                            margin: EdgeInsets.all(10),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SizedBox(height: 8),
                                                Text(
                                                  articleMap['title'] ?? '',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
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
                              );
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      margin: const EdgeInsets.only(left: 10, right: 20),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        "Gaya Pemakanan",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      margin: const EdgeInsets.only(left: 10),
                      height: 200,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('article')
                            .where('category',
                                isEqualTo: 'diet') // Filter by category
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          List<DocumentSnapshot>? articles =
                              snapshot.data?.docs;

                          if (articles == null || articles.isEmpty) {
                            return Center(
                              child: Text('No articles found'),
                            );
                          }

                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: articles.length,
                            itemBuilder: (context, index) {
                              var article = articles[index].data();
                              var articleMap = article as Map<String, dynamic>;
                              return InkWell(
                                onTap: () async {
                                  var articleDoc = snapshot.data!.docs[index];
                                  var articleId = articleDoc.id;

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ArticleScreen(data: articleId),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20)),
                                  width: 160,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: Image.network(
                                            articleMap['image'] ?? '',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomLeft,
                                          child: Container(
                                            margin: EdgeInsets.all(10),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SizedBox(height: 8),
                                                Text(
                                                  articleMap['title'] ?? '',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
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
                              );
                            },
                          );
                        },
                      ),
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
