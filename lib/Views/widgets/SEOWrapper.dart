import 'package:flutter/material.dart';
import 'package:solid_cv/business_layer/ISEOBll.dart';
import 'package:solid_cv/business_layer/SEOBll.dart';

class SEOWrapper extends StatefulWidget {
  final Widget child;
  final String title;
  final String description;
  final String canonicalUrl;
  final Map<String, dynamic>? structuredData;
  final String? imageUrl;
  final String? keywords;

  const SEOWrapper({
    super.key,
    required this.child,
    required this.title,
    required this.description,
    required this.canonicalUrl,
    this.structuredData,
    this.imageUrl,
    this.keywords,
  });

  @override
  State<SEOWrapper> createState() => _SEOWrapperState();
}

class _SEOWrapperState extends State<SEOWrapper> {
  final ISEOBll _seoBll = SEOBll();

  @override
  void initState() {
    super.initState();
    _initializeSEO();
  }

  void _initializeSEO() {
    // Update basic SEO meta tags
    _seoBll.updatePageTitle(widget.title);
    _seoBll.updateMetaDescription(widget.description);
    _seoBll.updateCanonicalUrl(widget.canonicalUrl);

    // Update Open Graph data
    _seoBll.updateOpenGraphData(
      widget.title,
      widget.description,
      widget.canonicalUrl,
      widget.imageUrl,
    );

    // Update Twitter Card data
    _seoBll.updateTwitterCardData(
      widget.title,
      widget.description,
      widget.canonicalUrl,
      widget.imageUrl,
    );

    // Update structured data if provided
    if (widget.structuredData != null) {
      _seoBll.updateStructuredData(widget.structuredData!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

// Pre-configured SEO wrappers for common page types following SolidCV patterns
class SEOHomePage extends SEOWrapper {
  const SEOHomePage({
    super.key,
    required super.child,
  }) : super(
          title: 'SolidCV - Blockchain-Powered Professional CV Platform',
          description: 'Create, verify, and showcase your professional credentials with blockchain technology. AI-powered career advice, NFT certificates, and secure CV management.',
          canonicalUrl: 'https://solidcv.com/',
          structuredData: const {
            '@context': 'https://schema.org',
            '@type': 'WebApplication',
            'name': 'SolidCV',
            'description': 'Blockchain-powered professional CV platform with AI career guidance',
            'url': 'https://solidcv.com',
            'applicationCategory': 'BusinessApplication',
            'operatingSystem': 'Web Browser',
            'offers': {
              '@type': 'Offer',
              'price': '0',
              'priceCurrency': 'USD'
            }
          },
        );
}

class SEOJobsPage extends SEOWrapper {
  const SEOJobsPage({
    super.key,
    required super.child,
  }) : super(
          title: 'Browse Jobs - Blockchain-Verified Opportunities | SolidCV',
          description: 'Discover verified job opportunities from trusted companies. Apply with your blockchain-verified CV and get matched with AI-powered recommendations.',
          canonicalUrl: 'https://solidcv.com/jobs',
          structuredData: const {
            '@context': 'https://schema.org',
            '@type': 'WebPage',
            'name': 'Job Opportunities',
            'description': 'Browse blockchain-verified job opportunities',
            'url': 'https://solidcv.com/jobs',
            'mainEntity': {
              '@type': 'JobPosting',
              'name': 'Various Job Opportunities',
              'description': 'Blockchain-verified job opportunities from trusted companies'
            }
          },
        );
}

class SEOCompaniesPage extends SEOWrapper {
  const SEOCompaniesPage({
    super.key,
    required super.child,
  }) : super(
          title: 'Verified Companies - Trusted Employers | SolidCV',
          description: 'Explore verified company profiles and their job opportunities. Connect with trusted employers using blockchain-verified credentials.',
          canonicalUrl: 'https://solidcv.com/companies',
          structuredData: const {
            '@context': 'https://schema.org',
            '@type': 'WebPage',
            'name': 'Company Directory',
            'description': 'Directory of verified companies and employers',
            'url': 'https://solidcv.com/companies'
          },
        );
}

class SEOCareerAdvicePage extends SEOWrapper {
  const SEOCareerAdvicePage({
    super.key,
    required super.child,
  }) : super(
          title: 'AI-Powered Career Advice - Personalized Guidance | SolidCV',
          description: 'Get personalized career advice powered by AI. Analyze your skills, set goals, and receive tailored recommendations for career growth.',
          canonicalUrl: 'https://solidcv.com/career-advice',
          structuredData: const {
            '@context': 'https://schema.org',
            '@type': 'WebPage',
            'name': 'Career Advice',
            'description': 'AI-powered personalized career guidance and recommendations',
            'url': 'https://solidcv.com/career-advice',
            'mainEntity': {
              '@type': 'Service',
              'name': 'AI Career Advice',
              'description': 'Personalized career guidance using artificial intelligence'
            }
          },
        );
}

class SEOEducationInstitutionsPage extends SEOWrapper {
  const SEOEducationInstitutionsPage({
    super.key,
    required super.child,
  }) : super(
          title: 'Education Institutions - Blockchain Credentials | SolidCV',
          description: 'Partner education institutions offering blockchain-verified certificates and credentials. Join our network of trusted educational providers.',
          canonicalUrl: 'https://solidcv.com/education-institutions',
          structuredData: const {
            '@context': 'https://schema.org',
            '@type': 'WebPage',
            'name': 'Education Institutions',
            'description': 'Network of trusted education institutions providing blockchain-verified credentials',
            'url': 'https://solidcv.com/education-institutions'
          },
        );
}

// Dynamic SEO wrapper for user profiles
class SEOUserProfile extends SEOWrapper {
  SEOUserProfile({
    super.key,
    required super.child,
    required String userName,
    required String userId,
    String? userBio,
  }) : super(
          title: '$userName - Professional CV Profile | SolidCV',
          description: '$userName\'s blockchain-verified professional CV and credentials on SolidCV. ${userBio ?? 'View verified work experience, education, and skills.'}',
          canonicalUrl: 'https://solidcv.com/user/$userId',
          structuredData: {
            '@context': 'https://schema.org',
            '@type': 'Person',
            'name': userName,
            'description': userBio ?? '$userName\'s professional profile',
            'url': 'https://solidcv.com/user/$userId',
            'knowsAbout': 'Professional Development',
            'alumniOf': 'Various Educational Institutions',
            'worksFor': {
              '@type': 'Organization',
              'name': 'Various Companies'
            }
          },
        );
}

// Dynamic SEO wrapper for job details
class SEOJobDetails extends SEOWrapper {
  SEOJobDetails({
    super.key,
    required super.child,
    required String jobTitle,
    required String jobId,
    String? companyName,
    String? jobDescription,
    String? salary,
    String? location,
  }) : super(
          title: '$jobTitle${companyName != null ? ' at $companyName' : ''} | SolidCV Jobs',
          description: jobDescription?.substring(0, jobDescription.length > 150 ? 150 : jobDescription.length) ?? 'Explore this job opportunity on SolidCV - blockchain-verified job listings from trusted employers.',
          canonicalUrl: 'https://solidcv.com/job-details/$jobId',
          structuredData: {
            '@context': 'https://schema.org',
            '@type': 'JobPosting',
            'title': jobTitle,
            'description': jobDescription ?? 'Job opportunity available on SolidCV',
            'url': 'https://solidcv.com/job-details/$jobId',
            'hiringOrganization': {
              '@type': 'Organization',
              'name': companyName ?? 'Company'
            },
            'jobLocation': {
              '@type': 'Place',
              'address': location ?? 'Location TBD'
            },
            if (salary != null) 'baseSalary': {
              '@type': 'MonetaryAmount',
              'currency': 'USD',
              'value': {
                '@type': 'QuantitativeValue',
                'value': salary
              }
            }
          },
        );
}
