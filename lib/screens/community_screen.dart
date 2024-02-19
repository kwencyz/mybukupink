// ignore_for_file: prefer_interpolation_to_compose_strings, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class ListItemView extends StatelessWidget {
  final String forumName;
  final String forumText;
  final String commentName;
  final String commentText;

  const ListItemView({
    Key? key,
    required this.forumName,
    required this.forumText,
    required this.commentName,
    required this.commentText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          //forum
          Container(
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color.fromRGBO(232, 223, 245, 1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              title: Text(
                forumName,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(forumText),
            ),
          ),
          //comment
          Container(
            margin: EdgeInsets.only(left: 10, right: 10),
            child: ListTile(
              title: Text(
                commentName,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(commentText),
            ),
          ),
          //add comment
          Container(
            width: 350,
            height: 40,
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Masukkan Komen Anda',
                  contentPadding: EdgeInsets.all(10.0)),
            ),
          )
        ],
      ),
    );
  }
}

class _CommunityScreenState extends State<CommunityScreen> {
  final user = FirebaseAuth.instance.currentUser!;

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
                    margin: const EdgeInsets.only(left: 30, right: 20),
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      "Komuniti Ibu Hamil",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                  ),
                  SizedBox(height: 5),
                  Container(
                    margin: EdgeInsets.only(left: 10, right: 10),
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('forum')
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                              snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }

                        List<DocumentSnapshot<Map<String, dynamic>>> documents =
                            snapshot.data!.docs;

                        return SizedBox(
                          width: 500,
                          height: 500,
                          child: Column(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  itemCount: documents.length,
                                  itemBuilder: (context, index) {
                                    var document = documents[index];
                                    var usernameStream = FirebaseFirestore
                                        .instance
                                        .collection('patient')
                                        .doc(document['uid'])
                                        .snapshots();

                                    return StreamBuilder<
                                        DocumentSnapshot<Map<String, dynamic>>>(
                                      stream: usernameStream,
                                      builder: (BuildContext context,
                                          AsyncSnapshot<
                                                  DocumentSnapshot<
                                                      Map<String, dynamic>>>
                                              usernameSnapshot) {
                                        if (usernameSnapshot.hasError) {
                                          return Text(
                                              'Error: ${usernameSnapshot.error}');
                                        }

                                        if (usernameSnapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return CircularProgressIndicator();
                                        }

                                        var usernameData =
                                            usernameSnapshot.data!.data()!;
                                        var username = usernameData['name'];

                                        var forumText = document['forumText'];

                                        var forumId =
                                            document.id; // Get the document ID

                                        var commentsStream = FirebaseFirestore
                                            .instance
                                            .collection('comment')
                                            .where('forumId',
                                                isEqualTo: forumId)
                                            .snapshots();

                                        return StreamBuilder<
                                            QuerySnapshot<
                                                Map<String, dynamic>>>(
                                          stream: commentsStream,
                                          builder: (BuildContext context,
                                              AsyncSnapshot<
                                                      QuerySnapshot<
                                                          Map<String, dynamic>>>
                                                  commentsSnapshot) {
                                            if (commentsSnapshot.hasError) {
                                              return Text(
                                                  'Error: ${commentsSnapshot.error}');
                                            }

                                            if (commentsSnapshot
                                                    .connectionState ==
                                                ConnectionState.waiting) {
                                              return CircularProgressIndicator();
                                            }

                                            List<
                                                    DocumentSnapshot<
                                                        Map<String, dynamic>>>
                                                commentsDocuments =
                                                commentsSnapshot.data!.docs;

                                            return Column(
                                              children: [
                                                ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      commentsDocuments.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    var commentDocument =
                                                        commentsDocuments[
                                                            index];
                                                    var commentUid =
                                                        commentDocument['uid'];
                                                    var commentText =
                                                        commentDocument[
                                                            'commentText'];

                                                    var usernameStream =
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'patient')
                                                            .doc(commentUid)
                                                            .snapshots();

                                                    return StreamBuilder<
                                                        DocumentSnapshot<
                                                            Map<String,
                                                                dynamic>>>(
                                                      stream: usernameStream,
                                                      builder: (BuildContext
                                                              context,
                                                          AsyncSnapshot<
                                                                  DocumentSnapshot<
                                                                      Map<String,
                                                                          dynamic>>>
                                                              usernameSnapshot) {
                                                        if (usernameSnapshot
                                                            .hasError) {
                                                          return Text(
                                                              'Error: ${usernameSnapshot.error}');
                                                        }

                                                        if (usernameSnapshot
                                                                .connectionState ==
                                                            ConnectionState
                                                                .waiting) {
                                                          return CircularProgressIndicator();
                                                        }

                                                        var usernameData =
                                                            usernameSnapshot
                                                                .data!
                                                                .data()!;
                                                        var commentName =
                                                            usernameData[
                                                                'name'];

                                                        return ListItemView(
                                                          forumName: username,
                                                          forumText: forumText,
                                                          commentName: commentName,
                                                          commentText: commentText,
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
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
