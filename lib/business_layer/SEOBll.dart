import 'package:solid_cv/business_layer/ISEOBll.dart';
import 'package:solid_cv/data_access_layer/ISEOService.dart';
import 'package:solid_cv/data_access_layer/SEOService.dart';

class SEOBll extends ISEOBll {
  final ISEOService _seoService = SEOService();

  @override
  void updatePageTitle(String title) {
    _seoService.updatePageTitle(title);
  }

  @override
  void updateMetaDescription(String description) {
    _seoService.updateMetaDescription(description);
  }

  @override
  void updateCanonicalUrl(String url) {
    _seoService.updateCanonicalUrl(url);
  }

  @override
  void updateStructuredData(Map<String, dynamic> data) {
    _seoService.updateStructuredData(data);
  }

  @override
  void updateOpenGraphData(String title, String description, String url, String? imageUrl) {
    _seoService.updateOpenGraphData(title, description, url, imageUrl);
  }

  @override
  void updateTwitterCardData(String title, String description, String url, String? imageUrl) {
    _seoService.updateTwitterCardData(title, description, url, imageUrl);
  }
}
