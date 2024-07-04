import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:navigation/Views/TeacherPage.dart';
import 'package:navigation/services/database.dart';
import 'package:uuid/uuid.dart';

class AddQuestion extends StatefulWidget {
  final String quizId;
  final DatabaseService databaseService;

  AddQuestion({required this.quizId, required this.databaseService});

  @override
  _AddQuestionState createState() => _AddQuestionState();
}

class _AddQuestionState extends State<AddQuestion> {
  late DatabaseService databaseService;

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String question = "", option1 = "", option2 = "", option3 = "", option4 = "";

  void uploadQuizData() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      Map<String, String> questionMap = {
        "question": question,
        "option1": option1,
        "option2": option2,
        "option3": option3,
        "option4": option4
      };

      widget.databaseService
          .addQuestionData(questionMap, widget.quizId)
          .then((value) {
        setState(() {
          isLoading = false;
        });
      }).catchError((e) {
        print(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: BackButton(
          color: Colors.white,
        ),
        title: Text(
          "Add Questions",
          style: TextStyle(color: Color.fromARGB(255, 186, 229, 15)),
        ),
        elevation: 0.0,
        backgroundColor: Color.fromARGB(255, 7, 50, 85),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    TextFormField(
                      validator: (val) =>
                          val!.isEmpty ? "Enter Question" : null,
                      decoration: InputDecoration(
                        hintText: "Question",
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      onChanged: (val) {
                        question = val;
                      },
                    ),
                    SizedBox(height: 5),
                    TextFormField(
                      validator: (val) => val!.isEmpty ? "Option1 " : null,
                      decoration: InputDecoration(
                        hintText: "Option1 (Correct Answer)",
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      onChanged: (val) {
                        option1 = val;
                      },
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      validator: (val) => val!.isEmpty ? "Option2 " : null,
                      decoration: InputDecoration(
                        hintText: "Option2",
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      onChanged: (val) {
                        option2 = val;
                      },
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      validator: (val) => val!.isEmpty ? "Option3 " : null,
                      decoration: InputDecoration(
                        hintText: "Option3",
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      onChanged: (val) {
                        option3 = val;
                      },
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      validator: (val) => val!.isEmpty ? "Option4 " : null,
                      decoration: InputDecoration(
                        hintText: "Option4",
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      onChanged: (val) {
                        option4 = val;
                      },
                    ),
                    SizedBox(height: 8),
                    Spacer(),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TeacherPage()),
                            );
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width / 2 - 20,
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 20),
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 7, 50, 85),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              "Cancel",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        GestureDetector(
                          onTap: uploadQuizData,
                          child: Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width / 2 - 40,
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 20),
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 7, 50, 85),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              "Add Question",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 60),
                  ],
                ),
              ),
            ),
    );
  }
}
