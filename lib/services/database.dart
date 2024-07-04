import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  final String uid;
  late DatabaseHelper dbHelper;

  DatabaseService({required this.uid}) {
    dbHelper = DatabaseHelper();
  }

  Future<void> addData(Map<String, dynamic> userData) async {
    await FirebaseFirestore.instance
        .collection("users")
        .add(userData)
        .catchError((e) {
      print(e);
    });
  }

  getData() async {
    return await FirebaseFirestore.instance.collection("users").snapshots();
  }

  Future<void> addQuizData(Map<String, dynamic> quizData, String quizId) async {
    await FirebaseFirestore.instance
        .collection("Quiz")
        .doc(quizId)
        .set(quizData)
        .catchError((e) {
      print(e);
    });

    await dbHelper.insertQuiz(quizData);
  }

  Future<void> addQuestionData(
      Map<String, dynamic> questionData, String quizId) async {
    await FirebaseFirestore.instance
        .collection("Quiz")
        .doc(quizId)
        .collection("QNA")
        .add(questionData)
        .catchError((e) {
      print(e);
    });
    await dbHelper.insertQuestion(questionData);
  }

  getQuizDataById(String quizId) async {
    return await FirebaseFirestore.instance
        .collection("Quiz")
        .doc(quizId)
        .get();
  }

  getQuizData() async {
    return await FirebaseFirestore.instance.collection("Quiz").snapshots();
  }

  getQuizData2() async {
    return await FirebaseFirestore.instance.collection("Quiz").snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getQuizData3(String quizId) {
    return FirebaseFirestore.instance
        .collection("Quiz")
        .doc(quizId)
        .snapshots();
  }

  getQuestionData(String quizId) async {
    return await FirebaseFirestore.instance
        .collection("Quiz")
        .doc(quizId)
        .collection("QNA")
        .get();
  }

  Stream<QuerySnapshot> getQuestionData2(String quizId) {
    return FirebaseFirestore.instance
        .collection("Quiz")
        .doc(quizId)
        .collection("QNA")
        .snapshots();
  }

  Future<void> updateQuizData(
      String quizId, Map<String, dynamic> updatedData) async {
    await FirebaseFirestore.instance
        .collection("Quiz")
        .doc(quizId)
        .update(updatedData)
        .catchError((e) {
      print(e);
    });
    await dbHelper.updateQuiz(quizId, updatedData);
  }

  Future<void> updateQuestionData(String quizId, String questionId,
      Map<String, dynamic> updatedData) async {
    await FirebaseFirestore.instance
        .collection("Quiz")
        .doc(quizId)
        .collection("QNA")
        .doc(questionId)
        .update(updatedData)
        .catchError((e) {
      print(e);
    });
    await dbHelper.updateQuestion(questionId, updatedData, quizId);
  }

  Future<void> deleteQuestion(String quizId, String questionId) async {
    await FirebaseFirestore.instance
        .collection("Quiz")
        .doc(quizId)
        .collection("QNA")
        .doc(questionId)
        .delete()
        .catchError((e) {
      print(e);
    });
    await dbHelper.deleteQuestion(questionId, quizId);
  }

  Future<void> deleteQuiz(String quizId) async {
    await FirebaseFirestore.instance
        .collection("Quiz")
        .doc(quizId)
        .delete()
        .catchError((e) {
      print(e);
    });
    await dbHelper.deleteQuiz(quizId);
  }
}

class DatabaseHelper {
  static Database? _database;
  static final _databaseName = 'quiz.db';
  static final _databaseVersion = 1;

  static final tableQuiz = 'quiz';
  static final tableQuestion = 'question';

  static final columnId = 'id';
  static final columnTitle = 'title';
  static final columnDescription = 'description';
  static final columnImgUrl = 'imageUrl';
  static final columnOption1 = 'option1';
  static final columnOption2 = 'option2';
  static final columnOption3 = 'option3';
  static final columnOption4 = 'option4';
  static final columnQuestion = 'question';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initializeDatabase();
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $tableQuiz (
      $columnId TEXT PRIMARY KEY,
      $columnTitle TEXT NOT NULL,
      $columnDescription TEXT NOT NULL,
      $columnImgUrl TEXT NOT NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE $tableQuestion (
      $columnId TEXT PRIMARY KEY,
      $columnQuestion TEXT NOT NULL,
      $columnOption1 TEXT NOT NULL,
      $columnOption2 TEXT NOT NULL,
      $columnOption3 TEXT NOT NULL,
      $columnOption4 TEXT NOT NULL,
      FOREIGN KEY ($columnId) REFERENCES $tableQuiz($columnId) ON DELETE CASCADE
    )
  ''');
  }

  Future<int> insertQuiz(Map<String, dynamic> quizData) async {
    Database db = await database;
    return await db.insert(tableQuiz, quizData);
  }

  Future<int> insertQuestion(Map<String, dynamic> questionData) async {
    Database db = await database;
    return await db.insert(tableQuestion, questionData);
  }

  Future<int> updateQuiz(
      String quizId, Map<String, dynamic> updatedData) async {
    Database db = await database;
    return await db.update(
      tableQuiz,
      updatedData,
      where: '$columnId = ?',
      whereArgs: [quizId],
    );
  }

  Future<int> updateQuestion(String questionId,
      Map<String, dynamic> updatedData, String quizId) async {
    Database db = await database;
    // Update question with quizId
    return await db.update(
      tableQuestion,
      updatedData,
      where: '$columnId = ? AND quizId = ?',
      whereArgs: [questionId, quizId],
    );
  }

  Future<int> deleteQuiz(String quizId) async {
    Database db = await database;
    return await db.delete(
      tableQuiz,
      where: '$columnId = ?',
      whereArgs: [quizId],
    );
  }

  Future<int> deleteQuestion(String questionId, String quizId) async {
    Database db = await database;
    // Delete question with quizId
    return await db.delete(
      tableQuestion,
      where: '$columnId = ? AND quizId = ?',
      whereArgs: [questionId, quizId],
    );
  }

  // In DatabaseHelper class
  Future<int> insertOrUpdateQuiz(Map<String, dynamic> quizData) async {
    Database db = await database;
    return await db.insert(tableQuiz, quizData,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getQuizData() async {
    Database db = await database;
    return await db.query(tableQuiz);
  }
}

class SyncService {
  final DatabaseService databaseService;

  SyncService({required this.databaseService});

  // Synchronize data from Firebase Firestore to SQLite
  void syncFromFirestoreToSQLite() {
    databaseService.getQuizData().listen((querySnapshot) {
      querySnapshot.docs.forEach((doc) async {
        Map<String, dynamic> quizData = doc.data() as Map<String, dynamic>;
        await databaseService.dbHelper.insertOrUpdateQuiz(quizData);
      });
    });
  }

  // Synchronize data from SQLite to Firebase Firestore
  void syncFromSQLiteToFirestore() {
    databaseService.dbHelper.getQuizData().then((quizDataList) {
      quizDataList.forEach((quizData) {
        // Here, you need to provide both quizData and quizId arguments
        String quizId = quizData['id'];
        databaseService.addQuizData(quizData, quizId);
      });
    });
  }
}
