import 'package:flutter/material.dart';
import 'package:solid_cv/business_layer/ISEOBll.dart';
import 'package:solid_cv/business_layer/SEOBll.dart';

// Mixin to add SEO functionality to any route following SolidCV architecture
mixin SEOEnhanced<T extends StatefulWidget> on State<T> {
  final ISEOBll _seoBll = SEOBll();

  void initializeSEO({
    required String title,
    required String description,
    required String canonicalUrl,
    Map<String, dynamic>? structuredData,
    String? imageUrl,
  }) {
    _seoBll.updatePageTitle(title);
    _seoBll.updateMetaDescription(description);
    _seoBll.updateCanonicalUrl(canonicalUrl);
    
    if (structuredData != null) {
      _seoBll.updateStructuredData(structuredData);
    }
    
    _seoBll.updateOpenGraphData(title, description, canonicalUrl, imageUrl);
    _seoBll.updateTwitterCardData(title, description, canonicalUrl, imageUrl);
  }

  void updateSEOForDynamicContent({
    required String title,
    required String description,
    String? imageUrl,
  }) {
    _seoBll.updatePageTitle(title);
    _seoBll.updateMetaDescription(description);
    _seoBll.updateOpenGraphData(title, description, '', imageUrl);
    _seoBll.updateTwitterCardData(title, description, '', imageUrl);
  }
}
