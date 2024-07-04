import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:navigation/Provider/provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    // Start listening to connectivity changes
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        // Trigger a rebuild when connectivity changes
      });
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Column(
        children: [
          Consumer<UiProvider>(
            builder: (context, UiProvider notifier, child) {
              return ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text("Dark theme"),
                trailing: Switch(
                  value: notifier.isDark,
                  onChanged: (value) => notifier.changeTheme(),
                ),
              );
            },
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              width: double.infinity,
              height: double.infinity,
              child: _buildConnectivityWidget(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectivityWidget() {
    return StreamBuilder<ConnectivityResult>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          ConnectivityResult result = snapshot.data!;
          if (result == ConnectivityResult.mobile) {
            return _connected('Mobile');
          } else if (result == ConnectivityResult.wifi) {
            return _connected('Wi-Fi');
          } else {
            return _noInternet();
          }
        } else {
          // If no data, show loading indicator
          return _loading();
        }
      },
    );
  }

  Widget _loading() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
      ),
    );
  }

  Widget _connected(String type) {
    return Center(
      child: Text(
        "$type Connected",
        style: const TextStyle(
          color: Colors.green,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _noInternet() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'lib/images/no_internet.jpg',
          height: 100,
        ),
        Container(
          margin: const EdgeInsets.only(top: 20, bottom: 10),
          child: const Text(
            "No Internet connection",
            style: TextStyle(
              fontSize: 22,
              color: Colors.red,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: const Text(
            "No Connection, please Check your connection to proceed.",
            style: TextStyle(
              fontSize: 13,
              color: Colors.red,
            ),
          ),
        ),
        // ElevatedButton(
        //   style: ButtonStyle(
        //     backgroundColor: MaterialStateProperty.all(Colors.green),
        //   ),
        //   onPressed: () async {
        //     ConnectivityResult result =
        //         await Connectivity().checkConnectivity();
        //     print(result.toString());
        //   },
        //   child: const Text("Refresh"),
        // ),
      ],
    );
  }
}
