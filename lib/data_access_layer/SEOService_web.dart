import 'dart:html' as html;
import 'dart:convert';
import 'package:solid_cv/data_access_layer/ISEOService.dart';

ISEOService createSEOService() => SEOServiceWeb();

class SEOServiceWeb extends ISEOService {
  @override
  void updatePageTitle(String title) {
    html.document.title = title;
  }

  @override
  void updateMetaDescription(String description) {
    _updateMetaTag('name', 'description', description);
  }

  @override
  void updateCanonicalUrl(String url) {
    final canonicalLink = html.document.querySelector('link[rel="canonical"]');
    if (canonicalLink != null) {
      canonicalLink.setAttribute('href', url);
    } else {
      final newCanonical = html.LinkElement()
        ..rel = 'canonical'
        ..href = url;
      html.document.head!.append(newCanonical);
    }
  }

  @override
  void updateStructuredData(Map<String, dynamic> data) {
    final existingScript = html.document.querySelector('script[type="application/ld+json"]');
    existingScript?.remove();
    
    final script = html.ScriptElement()
      ..type = 'application/ld+json'
      ..text = jsonEncode(data);
    html.document.head!.append(script);
  }

  @override
  void updateOpenGraphData(String title, String description, String url, String? imageUrl) {
    _updateMetaTag('property', 'og:title', title);
    _updateMetaTag('property', 'og:description', description);
    _updateMetaTag('property', 'og:url', url);
    if (imageUrl != null) {
      _updateMetaTag('property', 'og:image', imageUrl);
    }
  }

  @override
  void updateTwitterCardData(String title, String description, String url, String? imageUrl) {
    _updateMetaTag('property', 'twitter:title', title);
    _updateMetaTag('property', 'twitter:description', description);
    _updateMetaTag('property', 'twitter:url', url);
    if (imageUrl != null) {
      _updateMetaTag('property', 'twitter:image', imageUrl);
    }
  }

  void _updateMetaTag(String attribute, String name, String content) {
    final existingTag = html.document.querySelector('meta[$attribute="$name"]');
    if (existingTag != null) {
      existingTag.setAttribute('content', content);
    } else {
      final newTag = html.MetaElement()
        ..setAttribute(attribute, name)
        ..content = content;
      html.document.head!.append(newTag);
    }
  }
}
