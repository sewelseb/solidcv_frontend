import 'package:solid_cv/data_access_layer/ISEOService.dart';

ISEOService createSEOService() => SEOServiceStub();

/// Stub implementation of SEO service for non-web platforms
/// SEO functionality is only meaningful on web platforms
class SEOServiceStub extends ISEOService {
  @override
  void updatePageTitle(String title) {
    // No-op for non-web platforms
    // SEO functionality is not applicable
  }

  @override
  void updateMetaDescription(String description) {
    // No-op for non-web platforms
    // SEO functionality is not applicable
  }

  @override
  void updateCanonicalUrl(String url) {
    // No-op for non-web platforms
    // SEO functionality is not applicable
  }

  @override
  void updateStructuredData(Map<String, dynamic> data) {
    // No-op for non-web platforms
    // SEO functionality is not applicable
  }

  @override
  void updateOpenGraphData(String title, String description, String url, String? imageUrl) {
    // No-op for non-web platforms
    // SEO functionality is not applicable
  }

  @override
  void updateTwitterCardData(String title, String description, String url, String? imageUrl) {
    // No-op for non-web platforms
    // SEO functionality is not applicable
  }
}
