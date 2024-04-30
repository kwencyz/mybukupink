// ignore_for_file: prefer_interpolation_to_compose_strings, prefer_const_constructors, avoid_print, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverOverlapAbsorber(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: SliverAppBar(
                  expandedHeight: 300.0,
                  flexibleSpace: Stack(
                    children: [
                      Positioned.fill(
                        child: StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('article')
                              .doc(articleId)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Center(child: CircularProgressIndicator());
                            }

                            var articleData =
                                snapshot.data!.data() as Map<String, dynamic>;
                            var imageUrl = articleData['image'] as String?;

                            return imageUrl != null
                                ? Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                  )
                                : Placeholder();
                          },
                        ),
                      ),
                      Positioned(
                        top: 5,
                        left: 10,
                        child: Image.asset(
                          "assets/images/word.png",
                          width: 150,
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: ListView(
              children: [
                SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  alignment: Alignment.centerLeft,
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('article')
                        .doc(articleId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      var articleData =
                          snapshot.data!.data() as Map<String, dynamic>;
                      var articleTitle = articleData['title'] as String?;
                      var articleAuthor = articleData['author'] as String?;
                      var articleURL = articleData['url'] as String?;
                      final Uri url = Uri.parse(articleURL!);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Color.fromRGBO(255, 53, 139, 1),
                            ),
                            child: TextButton(
                              onPressed: () {
                                // Navigate to the articleURL when the button is pressed
                                launchUrl(url);
                              },
                              child: Text(
                                'Artikel Penuh',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            articleTitle ?? 'Article Title',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                            ),
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Text(
                                'oleh ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                articleAuthor ?? '-',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  alignment: Alignment.centerLeft,
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('article')
                        .doc(articleId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      var articleData =
                          snapshot.data!.data() as Map<String, dynamic>;
                      var articleText = articleData['text'] as String?;

                      return Text(
                        articleText ?? 'Article Text',
                        style: TextStyle(fontSize: 20),
                        textAlign: TextAlign.justify,
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
    );
  }
}
