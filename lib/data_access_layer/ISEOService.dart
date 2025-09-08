abstract class ISEOService {
  void updatePageTitle(String title);
  void updateMetaDescription(String description);
  void updateCanonicalUrl(String url);
  void updateStructuredData(Map<String, dynamic> data);
  void updateOpenGraphData(String title, String description, String url, String? imageUrl);
  void updateTwitterCardData(String title, String description, String url, String? imageUrl);
}
