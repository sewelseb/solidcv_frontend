import 'package:flutter/material.dart';
import 'package:solid_cv/Views/HomeRoute.dart';
import 'package:solid_cv/Views/LoggedInHome.dart';
import 'package:solid_cv/Views/RegisterRoute.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solid CV',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ).copyWith(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          shadowColor: Colors.black,
          elevation: 5
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeRoute(),
        '/register': (context) => RegisterRoute(),
        '/loggedin/home': (context) => LoggedInHome(),
      },
    );
  }
}



