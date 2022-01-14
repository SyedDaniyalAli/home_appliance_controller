import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'authentication_screen/authentication_screen.dart';
import 'machine_detail_screen/machine_detail_screen.dart';
import 'main_screen/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Set default `_initialized` and `_error` state to false
  bool _initialized = false;
  bool _error = false;

  static String HIVE_DATABASE_NAME='loginCredentials';

  @override
  void initState() {
    super.initState();
    initializeFlutterFire();
    initHiveDB();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home Appliance Controller',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        canvasColor: Colors.white,
        cardColor: Colors.white,
        cardTheme: const CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(8.0),
            ),
          ),
          elevation: 0,
          shadowColor: Colors.blue,
        ),
        appBarTheme: AppBarTheme(color: Colors.blueAccent),
        primarySwatch: Colors.blue,
        primaryColor: Colors.blueAccent,
      ),

      //Initializing EasyLoading for better on screen notification
      builder: EasyLoading.init(),

      routes: {
        '/': (ctx) => FutureBuilder(
          // Initialize FlutterFire
          future: Firebase.initializeApp(),
          builder: (ctx, snapshot) {
            // Check for errors
            if (snapshot.hasError) {
              return const Center(
                child: Text("No Internet Connection"),
              );
            }
            // Once complete, show your application
            if (snapshot.connectionState == ConnectionState.done) {
              if (getCurrentUser()) {
                print('Opening MainScreen');
                return MainScreen();
              } else {
                print('Opening AuthenticationScreen');
                return AuthenticationScreen();
              }
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Loading...',
                  ),
                ],
              ),
            );
          },
        ),
        MainScreen.routeName: (ctx) => MainScreen(),
        MachineDetailsScreen.routeName: (ctx) => MachineDetailsScreen(),
        AuthenticationScreen.routeName: (ctx) => AuthenticationScreen(),
      },
    );
  }

  Widget getMainScreen() {
    // Show error message if initialization failed
    if (_error) {
      return const Center(
        child: Text("No Internet Connection"),
      );
    }

    // Show a loader until FlutterFire is initialized
    if (!_initialized) {
      return Center(
        child: CircularProgressIndicator(
          backgroundColor: Theme.of(context).primaryColor,
        ),
      );
    }

    return MainScreen();
  }

  bool getCurrentUser() {
    var _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      print('Main Screen-> Email: ${_user.email}');
      return true;
    } else {
      return false;
    }
  }

  void initHiveDB() async {
    //local Database name~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    await Hive.initFlutter();
    // var dir = await getApplicationDocumentsDirectory();
    // Hive.init(dir.path);
    await Hive.openBox(HIVE_DATABASE_NAME);
  }

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
      });
    }
  }
}
