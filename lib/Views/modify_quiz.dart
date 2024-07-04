import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:navigation/Views/TeacherPage.dart';
import 'package:navigation/Views/add_questions.dart';
import 'package:navigation/services/database.dart';

class ModifyQuizPage extends StatefulWidget {
  final String quizId;

  ModifyQuizPage({required this.quizId});

  @override
  _ModifyQuizPageState createState() => _ModifyQuizPageState();
}

class _ModifyQuizPageState extends State<ModifyQuizPage> {
  late Stream<DocumentSnapshot> quizDataStream;
  late Stream<QuerySnapshot> questionDataStream;
  late DatabaseService databaseService;

  @override
  void initState() {
    super.initState();
    databaseService = DatabaseService(uid: widget.quizId);
    // Get the quiz data directly
    quizDataStream = databaseService.getQuizData3(widget.quizId);
    // Get the question data directly
    questionDataStream = databaseService.getQuestionData2(widget.quizId);
  }

  Future<void> deleteQuestion(String questionId) async {
    try {
      await databaseService.deleteQuestion(widget.quizId, questionId);
    } catch (e) {
      print('Error deleting question: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 7, 50, 85),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Modify Quiz",
          style: TextStyle(color: Color.fromARGB(255, 186, 229, 15)),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Quiz Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: quizDataStream
                as Stream<DocumentSnapshot<Map<String, dynamic>>>?,
            builder: (context,
                AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                    snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              if (!snapshot.hasData ||
                  snapshot.data == null ||
                  snapshot.data!.data() == null) {
                return Text('No quiz data found.');
              }
              var quizData = snapshot.data!.data()! as Map<String, dynamic>;
              return ListTile(
                title: Text('Title: ${quizData['quizTitle']}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Description: ${quizData['quizDesc']}'),
                    Text('Image URL: ${quizData['quizImgUrl'] ?? ''}'),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    // Navigate to a page to edit quiz
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditQuizPage(
                          quizId: widget.quizId,
                          currentTitle: quizData['quizTitle'],
                          currentDesc: quizData['quizDesc'],
                          currentImage: quizData['quizImgUrl'],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Questions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: questionDataStream
                  as Stream<QuerySnapshot<Map<String, dynamic>>>?,
              builder: (context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (!snapshot.hasData) {
                  return Text('No questions found.');
                }
                var questions = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    var questionData =
                        questions[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(
                          'Question ${index + 1}: ${questionData['question']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              // Navigate to page to edit  question
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditQuestionPage(
                                    quizId: widget.quizId,
                                    questionId: questions[index].id,
                                    currentQuestion: questionData['question'],
                                    currentOptions: [
                                      questionData['option1'],
                                      questionData['option2'],
                                      questionData['option3'],
                                      questionData['option4'],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              // Show a dialog to confirm deleting
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Delete Question'),
                                  content: Text(
                                      'Are you sure you want to delete this question?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(
                                            context);
                                      },
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(
                                            color:
                                                Color.fromARGB(255, 7, 50, 85)),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // Delete  question
                                        deleteQuestion(questions[index].id);
                                        Navigator.pop(
                                            context); // Pop the dialog
                                        // Pop ModifyQuizPage and return to TeacherPage
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  TeacherPage()), // Navigate to ContactPage when Contact button is clicked
                                        );
                                      },
                                      child: Text(
                                        'Delete',
                                        style: TextStyle(
                                            color:
                                                Color.fromARGB(255, 7, 50, 85)),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SizedBox(height: 16),
          Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddQuestion(
                          quizId: widget
                              .quizId,
                          databaseService: databaseService,
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.add_circle_outline_sharp),
                  label: Text('Add Question'),
                  style: ElevatedButton.styleFrom(
                    primary:
                        Color.fromARGB(255, 7, 50, 85), 
                    onPrimary: Colors.white, 
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Delete Quiz'),
                        content:
                            Text('Are you sure you want to delete this quiz?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              databaseService.deleteQuiz(widget.quizId);
                              Navigator.pop(context);
                            },
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: Icon(Icons.delete),
                  label: Text('Delete Quiz'),
                  style: ElevatedButton.styleFrom(
                    primary:
                        Color.fromARGB(255, 7, 50, 85), 
                    onPrimary: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EditQuizPage extends StatefulWidget {
  final String quizId;
  final String currentTitle;
  final String currentDesc;
  final String currentImage;

  EditQuizPage(
      {required this.quizId,
      required this.currentTitle,
      required this.currentDesc,
      required this.currentImage});

  @override
  _EditQuizPageState createState() => _EditQuizPageState();
}

class _EditQuizPageState extends State<EditQuizPage> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _imageUrlController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.currentTitle);
    _descController = TextEditingController(text: widget.currentDesc);
    _imageUrlController = TextEditingController(text: widget.currentImage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Quiz'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title'),
            TextFormField(
              controller: _titleController,
            ),
            SizedBox(height: 16),
            Text('Description'),
            TextFormField(
              controller: _descController,
            ),
            SizedBox(height: 16),
            Text('Image URL'), 
            TextFormField(
              controller: _imageUrlController,
            ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Update quiz details
                  DatabaseService(uid: widget.quizId).updateQuizData(
                    widget.quizId,
                    {
                      'quizTitle': _titleController.text,
                      'quizDesc': _descController.text,
                      'quizImgUrl': _imageUrlController
                          .text,
                    },
                  );
                  Navigator.pop(context);
                },
                child: Text('Save'),
                style: ElevatedButton.styleFrom(
                  primary:
                      Color.fromARGB(255, 7, 50, 85), 
                  onPrimary: Colors.white, // Set text color
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditQuestionPage extends StatefulWidget {
  final String quizId;
  final String questionId;
  final String currentQuestion;
  final List<String> currentOptions;

  EditQuestionPage(
      {required this.quizId,
      required this.questionId,
      required this.currentQuestion,
      required this.currentOptions});

  @override
  _EditQuestionPageState createState() => _EditQuestionPageState();
}

class _EditQuestionPageState extends State<EditQuestionPage> {
  late TextEditingController _questionController;
  late List<TextEditingController> _optionControllers;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.currentQuestion);
    _optionControllers = List.generate(
      widget.currentOptions.length,
      (index) => TextEditingController(text: widget.currentOptions[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 7, 50, 85),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Edit Question",
          style: TextStyle(color: Color.fromARGB(255, 186, 229, 15)),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Question'),
            TextFormField(
              controller: _questionController,
            ),
            SizedBox(height: 16),
            Text('Options'),
            for (int i = 0; i < _optionControllers.length; i++)
              TextFormField(
                controller: _optionControllers[i],
              ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Update question details in the db
                  DatabaseService(uid: widget.quizId).updateQuestionData(
                    widget.quizId,
                    widget.questionId,
                    {
                      'question': _questionController.text,
                      'option1': _optionControllers[0].text,
                      'option2': _optionControllers[1].text,
                      'option3': _optionControllers[2].text,
                      'option4': _optionControllers[3].text,
                    },
                  );
                  Navigator.pop(context);
                },
                child: Text('Save'),
                style: ElevatedButton.styleFrom(
                  primary:
                      Color.fromARGB(255, 7, 50, 85), // Set background color
                  onPrimary: Colors.white, // Set text color
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
