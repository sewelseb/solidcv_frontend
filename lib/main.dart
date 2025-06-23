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
import 'package:solid_cv/Views/PrivacyPolicyPage.dart';
import 'package:solid_cv/Views/RegisterRoute.dart';
import 'package:solid_cv/Views/UserPage.dart';
import 'package:solid_cv/Views/VerifyACvRoute.dart';
import 'package:solid_cv/Views/admin-views/AdminCompaniesListPage.dart';
import 'package:solid_cv/Views/admin-views/AdminDashboardPage.dart';
import 'package:solid_cv/Views/admin-views/AdminEducationInstitutionListPage.dart';
import 'package:solid_cv/Views/admin-views/AdminUserListPage.dart';
import 'package:solid_cv/Views/companyViews/AddAnEmployee.dart';
import 'package:solid_cv/Views/educationInstitutionViews/CreateACertificate.dart';
import 'package:solid_cv/Views/widgets/AuthGuard.dart';
import 'package:solid_cv/Views/widgets/EmailWidgets/EmailVerificationResultPage.dart';
import 'package:solid_cv/Views/widgets/EmailWidgets/ForgotPasswordPage.dart';
import 'package:solid_cv/Views/widgets/EmailWidgets/ResetPasswordPage.dart';
import 'package:solid_cv/Views/widgets/EmailWidgets/VerifyEmailPage.dart';
import 'package:solid_cv/Views/widgets/userWidgets/EditUserProfile.dart';
import 'package:solid_cv/models/User.dart';

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
        backgroundColor: const Color(0xFF7B3FE4),
            foregroundColor: Colors.white,
            shadowColor: Colors.black,
            elevation: 5),
      ),
      routes: {
        '/': (context) => const HomeRoute(),
        '/register': (context) => const RegisterRoute(),
        '/loggedin/home': (context) => const AuthGuard(child: LoggedInHome()),
        '/my-cv': (context) => const AuthGuard(child: MyCvRoute()),
        '/my-organisation': (context) =>
            const AuthGuard(child: MyOrganisationsRoute()),
        '/my-educationInstitution-administration': (context) =>
            const AuthGuard(child: MyEducationInstitutionAdministration()),
        '/privacy-policy': (context) => const PrivacyPolicyPage(),

        '/user/edit-profile': (context) {
          final user = ModalRoute.of(context)?.settings.arguments as User;
          return AuthGuard(child: EditProfileRoute(user: user));
        },
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/reset-password': (context) {
          final uri = Uri.base;
          final token = uri.queryParameters['token'];
          return ResetPasswordPage(token: token ?? '');
        },
        '/sent-verification-email': (context) {
          final email = ModalRoute.of(context)?.settings.arguments as String?;
          return VerifyEmailPage(email: email ?? '');
        },
        '/add-a-company-form': (context) =>
            const AuthGuard(child: AddACompanyFormRoute()),
        '/add-a-education-institution-form': (context) =>
            const AuthGuard(child: AddanEducationInstitutionFormRoute()),
        '/verify-a-cv': (context) => const AuthGuard(child: VerifyACvRoute()),
        '/my-company-administration': (context) =>
            const AuthGuard(child: MyCompanyAdministration()),
        '/company/add-an-employee': (context) =>
            const AuthGuard(child: AddAnEmployee()),
        '/educationInstitution/add-a-certificate-to-user': (context) =>
            AuthGuard(child: CreateACertificate()),
        '/admin/dashboard': (context) =>
            const AuthGuard(child: AdminDashboardPage()),
        '/admin/users': (context) => AuthGuard(child: AdminUsersPage()),
        '/admin/companies': (context) =>
            const AuthGuard(child: AdminCompaniesPage()),
        '/admin/institutions': (context) =>
            const AuthGuard(child: AdminInstitutionsPage()),
      },
      onGenerateRoute: (settings) {
        if (settings.name != null && settings.name!.startsWith('/user/')) {
          final id = settings.name!.substring('/user/'.length);
          return MaterialPageRoute(

            builder: (context) => AuthGuard(child: UserPage(userId: id)),
          );
        }

        if (settings.name != null &&
            settings.name!.startsWith('/verify-email/')) {
          final token = settings.name!.substring('/verify-email/'.length);
          return MaterialPageRoute(
            builder: (context) => EmailVerificationResultPage(token: token),
          );
        }

        if (settings.name != null &&
            settings.name!.startsWith('/reset-password/')) {
          final token = settings.name!.substring('/reset-password/'.length);
          return MaterialPageRoute(
            builder: (context) => ResetPasswordPage(token: token),
          );
        }

        if (settings.name != null &&
            settings.name!.startsWith('/check-my-skill-with-ai/')) {
          final id =
              settings.name!.substring('/check-my-skill-with-ai/'.length);
          return MaterialPageRoute(
            builder: (context) =>
                AuthGuard(child: CheckMySkillsWithAIPage(id: id)),
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
