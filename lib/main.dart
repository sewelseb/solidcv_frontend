import 'package:flutter/material.dart';
import 'package:solid_cv/Views/AddACompanyFormRoute.dart';
import 'package:solid_cv/Views/AddAnEducationInstitutionFormRoute.dart';
import 'package:solid_cv/Views/CheckMySkillsWithAIPage.dart';
import 'package:solid_cv/Views/HomeRoute.dart';
import 'package:solid_cv/Views/LoggedInHome.dart';
import 'package:solid_cv/Views/MyCompanyAdministration.dart';
import 'package:solid_cv/Views/MyCvRoute.dart';
import 'package:solid_cv/Views/MyEducationInstitutionAdministration.dart';
import 'package:solid_cv/Views/MyOrganisationRoute.dart';
import 'package:solid_cv/Views/RegisterRoute.dart';
import 'package:solid_cv/Views/UserPage.dart';
import 'package:solid_cv/Views/VerifyACvRoute.dart';
import 'package:solid_cv/Views/companyViews/AddAnEmployee.dart';
import 'package:solid_cv/Views/educationInstitutionViews/CreateACertificate.dart';
import 'package:solid_cv/Views/widgets/SessionValidatorToken.dart';

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
            elevation: 5),
      ),
      home: const SessionValidatorTokenPage(),
      initialRoute: '/',
      routes: {
        '/login': (context) => const HomeRoute(),
        '/register': (context) => const RegisterRoute(),
        '/loggedin/home': (context) => const LoggedInHome(),
        '/my-cv': (context) => const MyCvRoute(),
        '/my-organisation': (context) => const MyOrganisationsRoute(),
        '/my-educationInstitution-administration': (context) =>
            MyEducationInstitutionAdministration(),
        '/add-a-company-form': (context) => const AddACompanyFormRoute(),
        '/add-a-education-institution-form': (context) =>
            const AddanEducationInstitutionFormRoute(),
        '/verify-a-cv': (context) => const VerifyACvRoute(),
        '/my-company-administration': (context) =>
            const MyCompanyAdministration(),
        '/company/add-an-employee': (context) => const AddAnEmployee(),
        '/educationInstitution/add-a-certificate-to-user': (context) =>
            CreateACertificate(),
      },
      onGenerateRoute: (settings) {
        if (settings.name != null && settings.name!.startsWith('/user/')) {
          final id = settings.name!.substring('/user/'.length);
          return MaterialPageRoute(
            builder: (context) => UserPage(id: id),
          );
        }
        if (settings.name != null &&
            settings.name!.startsWith('/check-my-skill-with-ai/')) {
          final id =
              settings.name!.substring('/check-my-skill-with-ai/'.length);
          return MaterialPageRoute(
            builder: (context) => CheckMySkillsWithAIPage(id: id),
          );
        }
        return null; // Let `onUnknownRoute` handle this case.
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(
              child: Text('Page not found'),
            ),
          ),
        );
      },
    );
  }
}
