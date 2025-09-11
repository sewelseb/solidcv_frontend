import 'package:solid_cv/data_access_layer/ISEOService.dart';
import 'SEOService_stub.dart'
    if (dart.library.html) 'SEOService_web.dart';

class SEOService extends ISEOService {
  late final ISEOService _platformService;
  
  SEOService() {
    _platformService = createSEOService();
  }

  @override
  void updatePageTitle(String title) {
    _platformService.updatePageTitle(title);
  }

  @override
  void updateMetaDescription(String description) {
    _platformService.updateMetaDescription(description);
  }

  @override
  void updateCanonicalUrl(String url) {
    _platformService.updateCanonicalUrl(url);
  }

  @override
  void updateStructuredData(Map<String, dynamic> data) {
    _platformService.updateStructuredData(data);
  }

  @override
  void updateOpenGraphData(String title, String description, String url, String? imageUrl) {
    _platformService.updateOpenGraphData(title, description, url, imageUrl);
  }

  @override
  void updateTwitterCardData(String title, String description, String url, String? imageUrl) {
    _platformService.updateTwitterCardData(title, description, url, imageUrl);
  }
}
