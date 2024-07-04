import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UiProvider extends ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;

  final darkTheme = ThemeData(
    primaryColor: Colors.black12,
    brightness: Brightness.dark,
  );

  final lightTheme = ThemeData(
    primaryColor: Colors.white,
    brightness: Brightness.light,
  );

  void changeTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }

  Future<void> init() async {
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  // Initialize provider state

  runApp(ChangeNotifierProvider<UiProvider>(
    create: (context) => UiProvider()..init(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Consumer<UiProvider>(
        builder: (context, provider, child) {
          return Scaffold(
          );
        },
      ),
    );
  }
}