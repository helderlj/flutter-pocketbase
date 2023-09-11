import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:startertemplate/main_page.dart';
import 'package:startertemplate/pages/login_page.dart';
import 'package:startertemplate/providers/auth.dart';

/*

S T A R T

This is the starting point for all apps. 
Everything starts at the main function

*/
void main() {
  // lets run our app
  runApp(
    ChangeNotifierProvider(create: (context) => Auth(), child: const MyApp()),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final storage = const FlutterSecureStorage();
  bool isLoading = true;

  void _attemptAuth() async {
    String? token = await storage.read(key: 'pb_auth');

    print("Main.dart _attemptAuth(): ${token}");
    print('Main.dart _attemptAuth(): tipo do token ${token.runtimeType}');

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    _attemptAuth();
    super.initState();
    // Provider.of<Auth>(context, listen: false).attempt();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // this is bringing us to the LoginPage first
      home: Consumer<Auth>(builder: (context, auth, child) {
        print('main.dart - build() - isAuthenticated: ${auth.isAuthenticated}');
        if (!isLoading) {
          return (auth.isAuthenticated) ? MainPage() : LoginPage();
        }
        return LoadingScreen();
      }),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
