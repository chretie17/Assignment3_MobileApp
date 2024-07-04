import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:navigation/Views/camera.dart';
import 'package:navigation/Views/contact_page.dart';
import 'package:navigation/Views/create_quiz.dart';
import 'package:navigation/Views/google_signin_api.dart';
import 'package:navigation/Views/login_page.dart';
import 'package:navigation/Views/modify_quiz.dart';
import 'package:navigation/services/database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class TeacherPage extends StatefulWidget {
  const TeacherPage({Key? key}) : super(key: key);

  @override
  _TeacherPageState createState() => _TeacherPageState();
}

late final String title;

class _TeacherPageState extends State<TeacherPage> {
  int myIndex = 0;
  bool isOnline = false;
  bool isBluetoothEnabled = false;
  late String userName;
  late File? _image;
  int _selectedIndex = 0;
  String userEmail = ''; 

  bool showStatusIndicators = true;
  late Stream<QuerySnapshot<Map<String, dynamic>>>
      quizStream; 
  late DatabaseService databaseService; // Declare database service

  Widget quizList() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: StreamBuilder(
          stream: quizStream,
          builder: (context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            return snapshot.data == null
                ? Container()
                : ListView.builder(
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    itemExtent: 180,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 16.0),
                            child: QuizTile(
                              noOfQuestions: snapshot.data!.docs.length,
                              imageUrl: snapshot.data!.docs[index]
                                  .data()['quizImgUrl'],
                              title: snapshot.data!.docs[index]
                                  .data()['quizTitle'],
                              description:
                                  snapshot.data!.docs[index].data()['quizDesc'],
                              id: snapshot.data!.docs[index].id,
                            ),
                          ),
                          Divider(
                            color: Theme.of(context)
                                .primaryColor, 
                            thickness: 2.0, 
                            height: 2,
                          ),
                        ],
                      );
                    },
                  );
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loadUserInfo(); // Call loadUserInfo in initState
    databaseService = DatabaseService(uid: Uuid().v4());
    quizStream = Stream.empty();
    databaseService.getQuizData2().then((value) {
      setState(() {
        quizStream = value;
      });
    });
  }

  Future<void> loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserName = prefs.getString('userName');
    userEmail = prefs.getString('userEmail') ??
        "admin@gmail.com"; 
    final base64String = prefs.getString('profilePicture');

    if (base64String != null) {
      final imageBytes = base64Decode(base64String);

      setState(() {
        _image = File.fromRawPath(imageBytes);
        userName = savedUserName ?? "Admin";
      });
    } else {
      setState(() {
        _image = null;
        userName = savedUserName ?? "Admin";
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      if (index < 4) {
        _selectedIndex = index;
      } else {
        switch (index) {
          case 2:
            // Call pickImage function when the "About" button is pressed
            // pickImage();
            break;
          case 3: // Assuming 3 is the index for the "About" button
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CameraScreen()),
            );
            break;

          case 4:
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ContactPage()), // Navigate to ContactPage when the "Contact" button is pressed
            );
            break;
          case 5:
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => Settings()),
            // );
            break;
        }
      }
    });
  }

  // Function to handle logout
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.remove('userName');
      prefs.remove('userEmail');
      prefs.remove('profilePicture');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Page',
            style: TextStyle(color: Color.fromARGB(255, 186, 229, 15))),
        backgroundColor:
            Color.fromARGB(255, 7, 50, 85), // Change the app bar color
      ),
      body: quizList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateQuiz()),
          );
        },
        backgroundColor: Color.fromARGB(255, 7, 50, 85), 
        foregroundColor: Colors.white, 
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 7, 50, 85),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: _image != null
                        ? FileImage(_image!)
                        : AssetImage('images/default_profile.png')
                            as ImageProvider,
                  ),
                  SizedBox(height: 10),
                  Text(
                    userName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    userEmail,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: logout,
            ),
          ],
        ),
      ),
    );
  }
}

class QuizTile extends StatelessWidget {
  final String? imageUrl, title, id, description;
  final int noOfQuestions;

  QuizTile({
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.id,
    required this.noOfQuestions,
  });

  @override
  Widget build(BuildContext context) {
    // Store the quizId
    String quizId = id ?? ""; 

    return GestureDetector(
      onTap: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ModifyQuizPage(quizId: quizId),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24),
        height: 150,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Image.network(
                imageUrl ?? "", 
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width,
              ),
              Container(
                color: Colors.black26,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title ?? "", 
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        description ??
                            "", 
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
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
  }
}
