import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Import FlutterLocalNotificationsPlugin
import 'package:navigation/Provider/provider.dart';
import 'package:navigation/Views/answer_quiz.dart';
import 'package:navigation/Views/calculator_screen.dart';
import 'package:navigation/Views/contact_page.dart';
import 'package:navigation/Views/google_location.dart';
import 'package:navigation/Views/google_signin_api.dart';
import 'package:navigation/services/database.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'Views/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'Views/camera.dart';
import 'package:navigation/Views/settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => UiProvider()..init(),
      child: Consumer<UiProvider>(
        builder: (context, UiProvider notifier, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode: notifier.isDark ? ThemeMode.dark : ThemeMode.light,
            darkTheme:
                notifier.isDark ? notifier.darkTheme : notifier.lightTheme,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                  seedColor: Color.fromARGB(255, 27, 18, 93)),
              useMaterial3: true,
            ),
            home: LoginPage(),
          );
        },
      ),
    );
  }
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  final AndroidInitializationSettings initializationSettingsAndroid =
      const AndroidInitializationSettings(
          '@mipmap/ic_launcher'); // Use the default launcher icon

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: (String? payload) async {
      // Handle notification tap
    },
  );
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Add a constructor to initialize NotificationService
  NotificationService() {
    initialize();
  }

  // Initialize notification service
  static Future<void> initialize() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('notification_icon');
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Display notification
  static Future<void> displayNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
      // Set the small icon resource
      icon: 'notification_icon',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}

class Widget197 extends StatefulWidget {
  Widget197({Key? key}) : super(key: key);

  @override
  _Widget197State createState() => _Widget197State();
}

class _Widget197State extends State<Widget197> {
  int _selectedIndex = 0;
  File? _selectedImage; // Change this variable name to _selectedImage

  late List<Widget> _widgetOptions;
  late Widget _aboutContentWidget; // Add this line

  late String userName;
  late File? _image;
  // late Stream quizStream; // Declare the stream variable as late
  late Stream<QuerySnapshot<Map<String, dynamic>>>
      quizStream; // Specify the correct type
  late DatabaseService databaseService; // Declare the database service

  @override
  void initState() {
    super.initState();
    // Initialize databaseService
    databaseService = DatabaseService(uid: Uuid().v4());

    // Load user information during initialization
    loadUserInfo();

    // Load quiz data
    loadQuizData();

    // Initialize quizStream
    quizStream = Stream.empty();

    // Get quiz data and update quizStream
    databaseService.getQuizData2().then((value) {
      setState(() {
        quizStream = value;
      });
    });
  }

  // Load quiz data
  void loadQuizData() {
    databaseService.getQuizData2().then((value) {
      setState(() {
        quizStream = value;
      });
      displayNewQuizNotification(); // Call the displayNewQuizNotification method here
    });
  }

  // Display new quiz notification
  void displayNewQuizNotification() {
    NotificationService.displayNotification(
      'New Quiz Added!',
      'Check out the latest quiz available.',
    );
  }

  // Define a function to handle the selected image
  void _handleImageSelected(File? image) {
    setState(() {
      _selectedImage = image;
    });
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Use the picked image, for example, display it in an Image widget
      // You can also save the image to a file, upload it to a server, etc.
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    } else {
      // User canceled the image picking
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0:
          // Handle Home
          break;
        case 1:
          // Handle Calculator
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CalculatorScreen()),
          );
          break;
        case 2:
          // Handle About
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    AboutContentWidget(onImageSelected: (File? image) {})),
          );
          break;
        case 3:
          // Handle Contact
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ContactPage()),
          );
          break;
        case 4:
          // Handle Settings
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SettingsPage()),
          );
          break;
        case 5:
          // Handle Google Map
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MapPage()),
          );
          break;
        default:
          // Handle other cases or do nothing
          break;
      }
    });
  }

  // Function to handle logout
  Future<void> logout() async {
    // Perform logout actions
    await GoogleSignInApi.logout();

    // Navigate to the login page and replace the current screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  String userEmail = ''; // Declare userEmail as non-final

  Future<void> loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserName = prefs.getString('userName');
    userEmail = prefs.getString('userEmail') ??
        "ericbuturo1@gmail.com"; // Assign value directly
    final base64String = prefs.getString('profilePicture');

    if (base64String != null) {
      final imageBytes = base64Decode(base64String);

      setState(() {
        _image = File.fromRawPath(imageBytes);
        userName = savedUserName ?? "Eric Buturo";
        // userEmail = userEmail ?? "example@example.com"; // No need to assign here
      });
    } else {
      setState(() {
        _image = null;
        userName = savedUserName ?? "Eric Buturo";
        // userEmail = userEmail ?? "example@example.com"; // No need to assign here
      });
    }
  }

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
                                .primaryColor, // Use the color of your theme
                            thickness: 2.0, // Adjust the thickness as needed
                            height: 2, // Use 0 to get a full line
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Flutter Navigation App',
          style: TextStyle(
            color: Color.fromARGB(255, 186, 229, 15),
          ),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 7, 50, 85),
        iconTheme: IconThemeData(color: Colors.white),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          // Add logout button to AppBar
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: logout, // Call logout function when pressed
          ),
        ],
      ),
      body: quizList(),
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
                            as ImageProvider, // Provide a default profile picture asset
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
                    userEmail, // Display the user's email address
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.calculate),
              title: Text('Calculator'),
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('About'),
              onTap: () {
                _onItemTapped(2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.contact_emergency_rounded),
              title: Text('Contact'),
              onTap: () {
                _onItemTapped(
                    3); // Navigate to ContactPage, which corresponds to index 4
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                _onItemTapped(
                    4); // Navigate to Settings, which corresponds to index 5
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.map),
              title: Text('Google Map'),
              onTap: () {
                _onItemTapped(
                    5); // Navigate to Google Map, which corresponds to index 6
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: logout,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Calculator',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'About',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_page),
            label: 'Contact',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            // Add BottomNavigationBarItem for Google Map
            icon: Icon(Icons.map),
            label: 'Google Map',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color.fromARGB(143, 17, 127, 94),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizPlay(
                id ?? "",
                id: '',
              ),
            ));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24),
        height: 150,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Image.network(
                imageUrl ?? "", // Use a default value if imageUrl is null
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
                        title ?? "", // Use a default value if title is null
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
                            "", // Use a default value if description is null
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

class AboutContentWidget extends StatefulWidget {
  final Function(File?) onImageSelected;

  const AboutContentWidget({Key? key, required this.onImageSelected})
      : super(key: key);

  @override
  _AboutContentWidgetState createState() => _AboutContentWidgetState();
}

class _AboutContentWidgetState extends State<AboutContentWidget> {
  File? _image;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 200, // Adjust the width and height as needed
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: ClipOval(
            child: _image != null
                ? Image.file(_image!, fit: BoxFit.cover)
                : Icon(Icons.person,
                    size: 50), // Placeholder icon if no image selected
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            final picker = ImagePicker();
            final pickedFile =
                await picker.getImage(source: ImageSource.gallery);

            if (pickedFile != null) {
              final image = File(pickedFile.path);
              setState(() {
                _image = image;
              });
              widget.onImageSelected(
                  _image); // Notify parent widget about the selected image
            } else {
              print('Image picking canceled');
            }
          },
          child: Text('Pick Image'),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            final picker = ImagePicker();
            final pickedFile =
                await picker.pickImage(source: ImageSource.camera);

            if (pickedFile != null) {
              final image = File(pickedFile.path);
              setState(() {
                _image = image;
              });
              widget.onImageSelected(
                  _image); // Notify parent widget about the selected image
            } else {
              print('User canceled opening the camera');
            }
          },
          child: Text('Open Camera'),
        ),
      ],
    );
  }
}
