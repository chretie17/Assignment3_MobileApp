import 'package:flutter/material.dart';
import 'package:navigation/Views/TeacherPage.dart';
import 'package:navigation/Views/add_questions.dart';
import 'package:navigation/services/database.dart';
import 'package:random_string/random_string.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const CreateQuiz());
  var uuid = Uuid();

  String randomUuid = uuid.v4();
  print('Random UUID: $randomUuid');
}

class CreateQuiz extends StatelessWidget {
  const CreateQuiz({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: const MyHomePage(title: 'Create Quiz'),
      color: Color.fromARGB(255, 7, 50, 85),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int myIndex = 0;

  DatabaseService databaseService = DatabaseService(uid: Uuid().v4());

  final _formKey = GlobalKey<FormState>();
  late String quizImgUrl, quizTitle, quizDesc;
  bool isLoading = false;
  late String quizId;

  Widget menuItem(IconData icon, String title) {
    return Material(
      child: InkWell(
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Icon(icon, size: 20, color: Colors.black),
              ),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  createQuiz() {
    quizId = randomAlphaNumeric(16);
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      Map<String, String> quizData = {
        "quizImgUrl": quizImgUrl,
        "quizTitle": quizTitle,
        "quizDesc": quizDesc
      };

      databaseService.addQuizData(quizData, quizId).then((value) {
        setState(() {
          isLoading = false;
        });
      }).catchError((error) {
        print(error);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AddQuestion(
              quizId: quizId,
              databaseService: databaseService,
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 7, 50, 85),
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => TeacherPage()),
            );
          },
        ),
      ),
      body: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              TextFormField(
                validator: (val) =>
                    val!.isEmpty ? "Enter Quiz Image Url" : null,
                decoration: InputDecoration(
                  hintText: "Quiz Image Url",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                onChanged: (val) {
                  setState(() {
                    quizImgUrl = val;
                  });
                },
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                validator: (val) => val!.isEmpty ? "Enter Subject Title" : null,
                decoration: InputDecoration(
                  hintText: "Quiz Title",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                onChanged: (val) {
                  setState(() {
                    quizTitle = val;
                  });
                },
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                validator: (val) =>
                    val!.isEmpty ? "Enter Subject Description" : null,
                decoration: InputDecoration(
                  hintText: "Quiz Description",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                onChanged: (val) {
                  setState(() {
                    quizDesc = val;
                  });
                },
              ),
              Spacer(),
              GestureDetector(
                onTap: createQuiz,
                child: Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 7, 50, 85),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    "Create Quiz",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 60,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
