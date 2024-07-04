import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:navigation/components/answer_quiz_widgets.dart';
import 'package:navigation/models/question_model.dart';
import 'package:navigation/Views/results.dart';
import 'package:navigation/services/database.dart';
import 'package:uuid/uuid.dart';

class QuizPlay extends StatefulWidget {
  final String quizId;
  QuizPlay(this.quizId, {required String id});

  @override
  _QuizPlayState createState() => _QuizPlayState();
}

int _correct = 0;
int _incorrect = 0;
int _notAttempted = 0;
int total = 0;

late StreamController<List<int>> infoStreamController;
late Stream<List<int>> infoStream;

class _QuizPlayState extends State<QuizPlay> {
  late QuerySnapshot questionSnaphot;
  late DatabaseService databaseService;
  late StreamController<List<int>> infoStreamController;
  late PageController _pageController;
  int _currentPageIndex = 0;

  bool isLoading = true;
  late List<Map<String, dynamic>> questionList;

  @override
  void initState() {
    _pageController = PageController();
    databaseService = DatabaseService(uid: Uuid().v4());
    infoStreamController = StreamController<List<int>>.broadcast();
    infoStream = infoStreamController.stream;
    databaseService.getQuestionData(widget.quizId).then((value) {
      questionSnaphot = value;
      _notAttempted = questionSnaphot.docs.length;
      _correct = 0;
      _incorrect = 0;
      isLoading = false;
      total = questionSnaphot.docs.length;
      setState(() {});
      print("init don $total ${widget.quizId} ");
    });
    super.initState();
  }

  QuestionModel getQuestionModelFromDatasnapshot(
      DocumentSnapshot questionSnapshot) {
    QuestionModel questionModel = QuestionModel();

    var data = questionSnapshot.data() as Map<String, dynamic>?;

    if (data != null) {
      questionModel.question = (data["question"] as String?)!;

      if (questionModel.question != null) {
        List<String> options = [
          data["option1"],
          data["option2"],
          data["option3"],
          data["option4"],
        ];
        options.shuffle();

        questionModel.option1 = options[0];
        questionModel.option2 = options[1];
        questionModel.option3 = options[2];
        questionModel.option4 = options[3];
        questionModel.correctOption = data["option1"];
        questionModel.answered = false;

        print(questionModel.correctOption.toLowerCase());
      }
    }

    return questionModel;
  }

  @override
  void dispose() {
    infoStreamController.close();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 7, 50, 85),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Answer Quiz",
          style: TextStyle(color: Color.fromARGB(255, 186, 229, 15)),
        ),
      ),
      body: isLoading
          ? Container(
              child: Center(child: CircularProgressIndicator()),
            )
          : PageView.builder(
              controller: _pageController,
              itemCount: questionSnaphot.docs.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return SingleChildScrollView(
                  child: Container(
                    child: Column(
                      children: [
                        InfoHeader(
                          length: questionSnaphot.docs.length,
                          correct: _correct,
                          incorrect: _incorrect,
                          notAttempted: _notAttempted,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        QuizPlayTile(
                          questionModel: getQuestionModelFromDatasnapshot(
                            questionSnaphot.docs[index],
                          ),
                          index: index,
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.check,
          color: Colors.white,
        ),
        onPressed: () {
          if (_currentPageIndex < questionSnaphot.docs.length - 1) {
            _pageController.nextPage(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          } else {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Quiz Completed'),
                content: Text('Do you want to see the results?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('No'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Results(
                            correct: _correct,
                            incorrect: _incorrect,
                            total: total,
                          ),
                        ),
                      );
                    },
                    child: Text('Yes'),
                  ),
                ],
              ),
            );
          }
        },
        backgroundColor: Color.fromARGB(255, 7, 50, 85),
        shape: CircleBorder(),
      ),
    );
  }
}

class InfoHeader extends StatefulWidget {
  final int length;
  final int correct;
  final int incorrect;
  final int notAttempted;

  InfoHeader({
    required this.length,
    required this.correct,
    required this.incorrect,
    required this.notAttempted,
  });

  @override
  _InfoHeaderState createState() => _InfoHeaderState();
}

class _InfoHeaderState extends State<InfoHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      margin: EdgeInsets.only(left: 14),
      child: ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        children: <Widget>[
          NoOfQuestionTile(
            text: "Total",
            number: widget.length,
          ),
          NoOfQuestionTile(
            text: "Correct",
            number: widget.correct,
          ),
          NoOfQuestionTile(
            text: "Incorrect",
            number: widget.incorrect,
          ),
          NoOfQuestionTile(
            text: "NotAttempted",
            number: widget.notAttempted,
          ),
        ],
      ),
    );
  }
}

class QuizPlayTile extends StatefulWidget {
  final QuestionModel questionModel;
  final int index;

  QuizPlayTile({required this.questionModel, required this.index});

  @override
  _QuizPlayTileState createState() => _QuizPlayTileState();
}

class _QuizPlayTileState extends State<QuizPlayTile> {
  String optionSelected = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Q${widget.index + 1} ${widget.questionModel.question}",
              style:
                  TextStyle(fontSize: 18, color: Colors.black.withOpacity(0.8)),
            ),
          ),
          SizedBox(
            height: 12,
          ),
          GestureDetector(
            onTap: () {
              if (!widget.questionModel.answered) {
                setState(() {
                  if (widget.questionModel.option1 ==
                      widget.questionModel.correctOption) {
                    optionSelected = widget.questionModel.option1;
                    _correct = _correct + 1;
                  } else {
                    optionSelected = widget.questionModel.option1;
                    _incorrect = _incorrect + 1;
                  }
                  widget.questionModel.answered = true;
                  _notAttempted = _notAttempted - 1;
                });
                infoStreamController.add([_correct, _incorrect, _notAttempted]);
              }
            },
            child: OptionTile(
              option: "A",
              description: "${widget.questionModel.option1}",
              correctAnswer: widget.questionModel.correctOption,
              optionSelected: optionSelected,
            ),
          ),
          SizedBox(
            height: 4,
          ),
          GestureDetector(
            onTap: () {
              if (!widget.questionModel.answered) {
                if (widget.questionModel.option2 ==
                    widget.questionModel.correctOption) {
                  setState(() {
                    optionSelected = widget.questionModel.option2;
                    widget.questionModel.answered = true;
                    _correct = _correct + 1;
                  });
                } else {
                  setState(() {
                    optionSelected = widget.questionModel.option2;
                    widget.questionModel.answered = true;
                    _incorrect = _incorrect + 1;
                  });
                }
                setState(() {
                  _notAttempted = _notAttempted - 1;
                });
              }
            },
            child: OptionTile(
              option: "B",
              description: "${widget.questionModel.option2}",
              correctAnswer: widget.questionModel.correctOption,
              optionSelected: optionSelected,
            ),
          ),
          SizedBox(
            height: 4,
          ),
          GestureDetector(
            onTap: () {
              if (!widget.questionModel.answered) {
                if (widget.questionModel.option3 ==
                    widget.questionModel.correctOption) {
                  setState(() {
                    optionSelected = widget.questionModel.option3;
                    widget.questionModel.answered = true;
                    _correct = _correct + 1;
                  });
                } else {
                  setState(() {
                    optionSelected = widget.questionModel.option3;
                    widget.questionModel.answered = true;
                    _incorrect = _incorrect + 1;
                  });
                }
                setState(() {
                  _notAttempted = _notAttempted - 1;
                });
              }
            },
            child: OptionTile(
              option: "C",
              description: "${widget.questionModel.option3}",
              correctAnswer: widget.questionModel.correctOption,
              optionSelected: optionSelected,
            ),
          ),
          SizedBox(
            height: 4,
          ),
          GestureDetector(
            onTap: () {
              if (!widget.questionModel.answered) {
                if (widget.questionModel.option4 ==
                    widget.questionModel.correctOption) {
                  setState(() {
                    optionSelected = widget.questionModel.option4;
                    widget.questionModel.answered = true;
                    _correct = _correct + 1;
                  });
                } else {
                  setState(() {
                    optionSelected = widget.questionModel.option4;
                    widget.questionModel.answered = true;
                    _incorrect = _incorrect + 1;
                  });
                }
                setState(() {
                  _notAttempted = _notAttempted - 1;
                });
              }
            },
            child: OptionTile(
              option: "D",
              description: "${widget.questionModel.option4}",
              correctAnswer: widget.questionModel.correctOption,
              optionSelected: optionSelected,
            ),
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
