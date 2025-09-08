import 'package:flutter/material.dart';
import 'package:solid_cv/Views/AddACompanyFormRoute.dart';
import 'package:solid_cv/Views/AddAnEducationInstitutionFormRoute.dart';
import 'package:solid_cv/Views/CheckMySkillsWithAIPage.dart';
import 'package:solid_cv/Views/CompaniesLandingPage.dart';
import 'package:solid_cv/Views/CourseViewerPage.dart';
import 'package:solid_cv/Views/EducationInstitutionsLandingPage.dart';
import 'package:solid_cv/Views/HomeRoute.dart';
import 'package:solid_cv/Views/JobDetails.dart';
import 'package:solid_cv/Views/LoggedInHome.dart';
import 'package:solid_cv/Views/MyCompanyAdministration.dart';
import 'package:solid_cv/Views/MyCvRoute.dart';
import 'package:solid_cv/Views/MyEducationInstitutionAdministration.dart';
import 'package:solid_cv/Views/MyOrganisationRoute.dart';
import 'package:solid_cv/Views/PrivacyPolicyPage.dart';
import 'package:solid_cv/Views/TermsAndConditionsPage.dart';
import 'package:solid_cv/Views/PublicJobOffers.dart';
import 'package:solid_cv/Views/RegisterRoute.dart';
import 'package:solid_cv/Views/UserPage.dart';
import 'package:solid_cv/Views/VerifyACvRoute.dart';
import 'package:solid_cv/Views/admin-views/AdminCompaniesListPage.dart';
import 'package:solid_cv/Views/admin-views/AdminDashboardPage.dart';
import 'package:solid_cv/Views/admin-views/AdminEducationInstitutionListPage.dart';
import 'package:solid_cv/Views/admin-views/AdminUserListPage.dart';
import 'package:solid_cv/Views/career-advice/CareerAdviceMain.dart';
import 'package:solid_cv/Views/companyViews/AddAnEmployee.dart';
import 'package:solid_cv/Views/companyViews/ApplicantAIFeedbackView.dart';
import 'package:solid_cv/Views/companyViews/CreateJobOffer.dart';
import 'package:solid_cv/Views/companyViews/EditJobOffer.dart';
import 'package:solid_cv/Views/companyViews/JobApplications.dart';
import 'package:solid_cv/Views/companyViews/ManageJobOffers.dart';
import 'package:solid_cv/Views/educationInstitutionViews/CreateACertificate.dart';
import 'package:solid_cv/Views/widgets/AuthGuard.dart';
import 'package:solid_cv/Views/widgets/EmailWidgets/EmailVerificationResultPage.dart';
import 'package:solid_cv/Views/widgets/EmailWidgets/ForgotPasswordPage.dart';
import 'package:solid_cv/Views/widgets/EmailWidgets/ResetPasswordPage.dart';
import 'package:solid_cv/Views/widgets/EmailWidgets/VerifyEmailPage.dart';
import 'package:solid_cv/Views/widgets/userWidgets/EditUserProfile.dart';
import 'package:solid_cv/Views/PublicCompanyJobsPage.dart';
import 'package:solid_cv/Views/PublicCompanyProfilePage.dart';
import 'package:solid_cv/Views/WeeklyRecommendationsPage.dart';
import 'package:solid_cv/models/User.dart';
import 'package:solid_cv/models/WeeklyRecommendation.dart';
import 'package:solid_cv/Views/FirstConfiguration.dart';
import 'package:solid_cv/business_layer/ISEOBll.dart';
import 'package:solid_cv/business_layer/SEOBll.dart';

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
            backgroundColor: Color(0xFF7B3FE4),
            foregroundColor: Colors.white,
            shadowColor: Colors.black,
            elevation: 5),
      ),
      routes: {
        '/': (context) => const HomeRoute(),
        '/login': (context) => const HomeRoute(),
        '/register': (context) => const RegisterRoute(),
        '/loggedin/home': (context) => const AuthGuard(child: LoggedInHome()),
        '/my-cv': (context) => const AuthGuard(child: MyCvRoute()),
        '/my-organisation': (context) =>
            const AuthGuard(child: MyOrganisationsRoute()),
        '/my-educationInstitution-administration': (context) =>
            const AuthGuard(child: MyEducationInstitutionAdministration()),
        '/privacy-policy': (context) => const PrivacyPolicyPage(),
        '/terms-and-conditions': (context) => const TermsAndConditionsPage(),
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
        '/company/manage-job-offers': (context) {
          return const AuthGuard(
            child: ManageJobOffers(),
          );
        },
        '/company/create-job-offer': (context) {
          return const AuthGuard(
            child: CreateJobOffer(),
          );
        },
        '/company/edit-job-offer': (context) {
           return const AuthGuard(
            child: EditJobOffer(),
          );
        },
        '/company/job-applications': (context) {
          return const AuthGuard(
            child: JobApplications(),
          );
        },
        '/company/applicant-ai-feedback': (context) {
          return const AuthGuard(
            child: ApplicantAIFeedbackView(),
          );
        },
        '/user/first-configuration': (context) {
          return const AuthGuard(
            child: FirstConfiguration(),
          );
        },
        '/jobs': (context) => const PublicJobOffers(),
        '/career-advice': (context) => const AuthGuard(child: CareerAdviceMain()),
        '/weekly-recommendations': (context) => AuthGuard(child: WeeklyRecommendationsPage()),
        '/education-institutions': (context) => const EducationInstitutionsLandingPage(),
        '/companies': (context) => const CompaniesLandingPage(),
      },
      onGenerateRoute: (settings) {
        final seoBll = SEOBll();
        
        if (settings.name != null && settings.name!.startsWith('/user/')) {
          final id = settings.name!.substring('/user/'.length);
          
          // SEO optimization for user profiles
          seoBll.updateCanonicalUrl('https://solidcv.com/user/$id');
          seoBll.updatePageTitle('Professional CV Profile | SolidCV');
          seoBll.updateMetaDescription('View blockchain-verified professional CV and credentials on SolidCV platform.');
          
          return MaterialPageRoute(
            settings: settings, // Pass the route settings to maintain URL
            builder: (context) => AuthGuard(child: UserPage(userId: id)),
          );
        }

        if (settings.name != null &&
            settings.name!.startsWith('/verify-email/')) {
          final token = settings.name!.substring('/verify-email/'.length);
          
          // SEO optimization for email verification
          seoBll.updatePageTitle('Email Verification | SolidCV');
          seoBll.updateCanonicalUrl('https://solidcv.com/verify-email/$token');
          
          return MaterialPageRoute(
            settings: settings, // Pass the route settings to maintain URL
            builder: (context) => EmailVerificationResultPage(token: token),
          );
        }

        if (settings.name != null &&
            settings.name!.startsWith('/reset-password/')) {
          final token = settings.name!.substring('/reset-password/'.length);
          
          // SEO optimization for password reset
          seoBll.updatePageTitle('Reset Password | SolidCV');
          seoBll.updateCanonicalUrl('https://solidcv.com/reset-password/$token');
          
          return MaterialPageRoute(
            settings: settings, // Pass the route settings to maintain URL
            builder: (context) => ResetPasswordPage(token: token),
          );
        }

        if (settings.name != null &&
            settings.name!.startsWith('/check-my-skill-with-ai/')) {
          final id =
              settings.name!.substring('/check-my-skill-with-ai/'.length);
              
          // SEO optimization for AI skill check
          seoBll.updatePageTitle('AI Skill Assessment | SolidCV');
          seoBll.updateMetaDescription('Test and validate your professional skills with AI-powered assessments on SolidCV.');
          seoBll.updateCanonicalUrl('https://solidcv.com/check-my-skill-with-ai/$id');
          
          return MaterialPageRoute(
            settings: settings, // Pass the route settings to maintain URL
            builder: (context) =>
                AuthGuard(child: CheckMySkillsWithAIPage(id: id)),
          );
        }

        if (settings.name != null &&
            settings.name!.startsWith('/job-details/')) {
          final id =
              settings.name!.substring('/job-details/'.length);
              
          // SEO optimization for job details
          seoBll.updatePageTitle('Job Opportunity Details | SolidCV');
          seoBll.updateMetaDescription('Explore blockchain-verified job opportunities with detailed requirements and company information.');
          seoBll.updateCanonicalUrl('https://solidcv.com/job-details/$id');
          
          return MaterialPageRoute(
            settings: settings, // Pass the route settings to maintain URL
            builder: (context) =>
                JobDetails(jobOfferId: id),
          );
        }

        if (settings.name != null &&
            settings.name!.startsWith('/company/jobs/')) {
          final companyId =
              settings.name!.substring('/company/jobs/'.length);
              
          // SEO optimization for company jobs
          seoBll.updatePageTitle('Company Job Listings | SolidCV');
          seoBll.updateMetaDescription('Browse verified job opportunities from trusted companies on SolidCV platform.');
          seoBll.updateCanonicalUrl('https://solidcv.com/company/jobs/$companyId');
          
          return MaterialPageRoute(
            settings: settings, // Pass the route settings to maintain URL
            builder: (context) =>
                PublicCompanyJobsPage(companyId: companyId),
          );
        }

        if (settings.name != null &&
            settings.name!.startsWith('/company/profile/')) {
          final companyId =
              settings.name!.substring('/company/profile/'.length);
              
          // SEO optimization for company profiles
          seoBll.updatePageTitle('Company Profile | SolidCV');
          seoBll.updateMetaDescription('Discover verified company profiles and their blockchain-verified job opportunities.');
          seoBll.updateCanonicalUrl('https://solidcv.com/company/profile/$companyId');
          
          return MaterialPageRoute(
            settings: settings, // Pass the route settings to maintain URL
            builder: (context) =>
                PublicCompanyProfilePage(companyId: companyId),
          );
        }

        if (settings.name == '/course-viewer') {
          final course = settings.arguments as RecommendedCourse?;
          if (course != null) {
            // SEO optimization for course viewer
            seoBll.updatePageTitle('${course.title ?? 'Course'} | SolidCV Learning');
            seoBll.updateMetaDescription('Enhance your skills with ${course.title ?? 'this course'} recommended by SolidCV AI.');
            
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => AuthGuard(child: CourseViewerPage(course: course)),
            );
          }
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
