import '../models/User.dart';
import '../models/Company.dart';
import '../models/JobOffer.dart';

abstract class ISitemapBll {
  /// Generates XML sitemap content for the website
  Future<String> generateSitemap();
  
  /// Gets all public user profiles for sitemap inclusion
  Future<List<User>> getPublicUsers();
  
  /// Gets all public company profiles for sitemap inclusion
  Future<List<Company>> getPublicCompanies();
  
  /// Gets all active job offers for sitemap inclusion
  Future<List<JobOffer>> getActiveJobOffers();
  
  /// Gets all public URLs for sitemap generation
  Future<List<String>> getPublicUrls();
  
  /// Updates the sitemap file
  Future<void> updateSitemap();
  
  /// Generates sitemap index for large sitemaps
  Future<String> generateSitemapIndex();
  
  /// Gets the last modification date for sitemap
  String getLastModified();
}
