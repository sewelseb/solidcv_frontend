import 'package:solid_cv/business_layer/ISitemapBll.dart';
import '../models/User.dart';
import '../models/Company.dart';
import '../models/JobOffer.dart';

class SitemapBll extends ISitemapBll {

  @override
  Future<String> generateSitemap() async {
    final urls = await getPublicUrls();
    final sitemap = StringBuffer();
    
    sitemap.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    sitemap.writeln('<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">');
    
    for (final url in urls) {
      sitemap.writeln('  <url>');
      sitemap.writeln('    <loc>$url</loc>');
      sitemap.writeln('    <lastmod>${DateTime.now().toIso8601String()}</lastmod>');
      sitemap.writeln('    <changefreq>weekly</changefreq>');
      sitemap.writeln('    <priority>0.8</priority>');
      sitemap.writeln('  </url>');
    }
    
    sitemap.writeln('</urlset>');
    return sitemap.toString();
  }

  @override
  Future<List<String>> getPublicUrls() async {
    final urls = <String>[
      'https://solidcv.com/',
      'https://solidcv.com/jobs',
      'https://solidcv.com/companies',
      'https://solidcv.com/education-institutions',
      'https://solidcv.com/career-advice',
      'https://solidcv.com/privacy-policy',
      'https://solidcv.com/terms-and-conditions',
    ];

    try {
      // Add public user profiles
      final users = await getPublicUsers();
      for (final user in users) {
        urls.add('https://solidcv.com/user/${user.id}');
      }

      // Add public company profiles
      final companies = await getPublicCompanies();
      for (final company in companies) {
        urls.add('https://solidcv.com/company/profile/${company.id}');
      }

      // Add active job listings
      final jobOffers = await getActiveJobOffers();
      for (final job in jobOffers) {
        urls.add('https://solidcv.com/job-details/${job.id}');
      }
    } catch (e) {
      print('Error generating sitemap URLs: $e');
    }

    return urls;
  }

  @override
  Future<void> updateSitemap() async {
    try {
      await generateSitemap();
      // In a real implementation, you would save this to a file or send to server
      print('Generated sitemap with ${(await getPublicUrls()).length} URLs');
      print('Sitemap content generated successfully');
    } catch (e) {
      print('Error updating sitemap: $e');
    }
  }

  @override
  Future<List<User>> getPublicUsers() async {
    try {
      // For now, return empty list since the method doesn't exist in UserBLL
      // This should be implemented when the UserBLL interface is updated
      return <User>[];
    } catch (e) {
      print('Error getting public users: $e');
      return <User>[];
    }
  }

  @override
  Future<List<Company>> getPublicCompanies() async {
    try {
      // For now, return empty list since the method doesn't exist in CompanyBll
      // This should be implemented when the CompanyBll interface is updated
      return <Company>[];
    } catch (e) {
      print('Error getting public companies: $e');
      return <Company>[];
    }
  }

  @override
  Future<List<JobOffer>> getActiveJobOffers() async {
    try {
      // For now, return empty list since the method doesn't exist in CompanyBll
      // This should be implemented when the CompanyBll interface is updated
      return <JobOffer>[];
    } catch (e) {
      print('Error getting active job offers: $e');
      return <JobOffer>[];
    }
  }

  @override
  Future<String> generateSitemapIndex() async {
    final sitemap = StringBuffer();
    
    sitemap.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    sitemap.writeln('<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">');
    
    // Main sitemap
    sitemap.writeln('  <sitemap>');
    sitemap.writeln('    <loc>https://solidcv.com/sitemap.xml</loc>');
    sitemap.writeln('    <lastmod>${getLastModified()}</lastmod>');
    sitemap.writeln('  </sitemap>');
    
    sitemap.writeln('</sitemapindex>');
    return sitemap.toString();
  }

  @override
  String getLastModified() {
    return DateTime.now().toIso8601String();
  }
}
