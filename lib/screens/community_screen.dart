// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final user = FirebaseAuth.instance.currentUser!;

  final Map<String, TextEditingController> _commentControllers = {};

  final TextEditingController _forumController = TextEditingController();

  Future<void> uploadForum(forum) {
    // Add the comment to the Firestore 'forum' collection
    FirebaseFirestore.instance.collection('forum').add({
      'uid': user.uid,
      'forumText': forum,
      'timestamp': DateTime.now(),
    });
    _forumController.clear();
    Navigator.of(context).pop();
    return Future.value();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: SizedBox(
        width: 80,
        height: 80,
        child: FloatingActionButton(
          backgroundColor: Colors.white,
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text(
                    'Forum',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Container(
                    padding: EdgeInsets.all(5),
                    width: 400,
                    child: TextField(
                      controller: _forumController,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Apa di fikiran anda?',
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        uploadForum(_forumController.text);
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                      child: Text('Muat Naik'),
                    ),
                  ],
                );
              },
            );
          },
          child: SvgPicture.asset(
            'assets/icons/community.svg',
            // ignore: deprecated_member_use
            color: Color.fromRGBO(255, 53, 139, 1),
            width: 40,
            height: 40,
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/gradient2.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 20),
                    alignment: Alignment.centerRight,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30)),
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
                    margin:
                        const EdgeInsets.only(left: 30, right: 20, bottom: 10),
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      "Komuniti Ibu Hamil",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Colors.black),
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('forum')
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        final List<DocumentSnapshot> documents =
                            snapshot.data!.docs;

                        return ListView.builder(
                          itemCount: documents.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot document =
                                snapshot.data!.docs[index];
                            Map<String, dynamic> data =
                                document.data() as Map<String, dynamic>;
                            String uid = data['uid'];

                            final timestamp =
                                document['timestamp'] as Timestamp;

                            final formattedDate = DateFormat('dd/MM/yyyy')
                                .format(timestamp.toDate());

                            return FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('patient')
                                  .doc(uid)
                                  .get(),
                              builder: (context, userSnapshot) {
                                if (userSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                }

                                if (userSnapshot.hasError) {
                                  return Text('Error: ${userSnapshot.error}');
                                }

                                String username =
                                    userSnapshot.data?['name'] ?? 'Unknown';

                                return Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Container(
                                            padding:
                                                EdgeInsets.only(bottom: 10),
                                            decoration: BoxDecoration(
                                              color: Color.fromRGBO(
                                                  232, 223, 245, 1),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: ListTile(
                                              title: Row(
                                                children: [
                                                  Text(
                                                    username,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Spacer(),
                                                  Text(
                                                    formattedDate,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                              subtitle: Text(
                                                data['forumText'],
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        StreamBuilder<QuerySnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection('comment')
                                              .where('forumId',
                                                  isEqualTo: document.id)
                                              .snapshots(),
                                          builder: (context, commentSnapshot) {
                                            if (commentSnapshot.hasError) {
                                              return Text(
                                                  'Error: ${commentSnapshot.error}');
                                            }

                                            if (commentSnapshot
                                                    .connectionState ==
                                                ConnectionState.waiting) {
                                              return Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            }

                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                ...commentSnapshot.data!.docs
                                                    .map((commentDoc) {
                                                  Map<String, dynamic>
                                                      commentData =
                                                      commentDoc.data() as Map<
                                                          String, dynamic>;
                                                  String uid =
                                                      commentData['uid'];

                                                  return FutureBuilder<
                                                      DocumentSnapshot>(
                                                    future: FirebaseFirestore
                                                        .instance
                                                        .collection('patient')
                                                        .doc(uid)
                                                        .get(),
                                                    builder: (context,
                                                        userSnapshot) {
                                                      if (userSnapshot
                                                              .connectionState ==
                                                          ConnectionState
                                                              .waiting) {
                                                        return Text(
                                                            'Loading...');
                                                      }

                                                      if (userSnapshot
                                                          .hasError) {
                                                        return Text(
                                                            'Error: ${userSnapshot.error}');
                                                      }

                                                      String username =
                                                          userSnapshot.data?[
                                                                  'name'] ??
                                                              'Unknown';

                                                      return Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                          left: 10,
                                                          right: 10,
                                                        ),
                                                        child: Container(
                                                          width: 400,
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 20,
                                                                  right: 10,
                                                                  bottom: 10),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(username,
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold)),
                                                              Text(
                                                                commentData[
                                                                    'commentText'],
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                }).toList(),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 20,
                                                      right: 20,
                                                      bottom: 20),
                                                  child: TextField(
                                                    controller:
                                                        _commentControllers
                                                            .putIfAbsent(
                                                      document.id,
                                                      () =>
                                                          TextEditingController(),
                                                    ),
                                                    decoration: InputDecoration(
                                                      hintStyle: TextStyle(
                                                          fontSize: 14),
                                                      hintText:
                                                          'Add a comment...',
                                                      contentPadding:
                                                          EdgeInsets.only(
                                                              left: 10),
                                                    ),
                                                    onSubmitted: (comment) {
                                                      // Add the comment to the Firestore 'comment' collection
                                                      FirebaseFirestore.instance
                                                          .collection('comment')
                                                          .add({
                                                        'forumId': document.id,
                                                        'uid': user.uid,
                                                        'commentText': comment,
                                                        'timestamp':
                                                            DateTime.now(),
                                                      });
                                                      _commentControllers[
                                                              document.id]!
                                                          .clear();
                                                    },
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
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
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Dispose all TextEditingController instances
    _commentControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }
}
