import 'package:flutter/material.dart';
import 'package:solid_cv/Views/AddACompanyFormRoute.dart';
import 'package:solid_cv/Views/AddAnEducationInstitutionFormRoute.dart';
import 'package:solid_cv/Views/HomeRoute.dart';
import 'package:solid_cv/Views/LoggedInHome.dart';
import 'package:solid_cv/Views/MyCompanyAdministration.dart';
import 'package:solid_cv/Views/MyCvRoute.dart';
import 'package:solid_cv/Views/MyOrganisationRoute.dart';
import 'package:solid_cv/Views/RegisterRoute.dart';
import 'package:solid_cv/Views/VerifyACvRoute.dart';
import 'package:solid_cv/Views/companyViews/AddAnEmployee.dart';

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
        '/': (context) => const HomeRoute(),
        '/register': (context) => const RegisterRoute(),
        '/loggedin/home': (context) => const LoggedInHome(),
        '/my-cv': (context) => const MyCvRoute(),
        '/my-organisation': (context) => const MyOrganisationsRoute(),
        '/add-a-company-form': (context) => const AddACompanyFormRoute(),
        '/add-a-education-institution-form': (context) => AddanEducationInstitutionFormRoute(),
        '/verify-a-cv': (context) => const VerifyACvRoute(),
        '/my-company-administration': (context) => MyCompanyAdministration(),
        '/company/add-an-employee': (context) => AddAnEmployee(),
      },
    );
  }
}



