import 'package:flutter/material.dart';
import '../business_layer/ISEOBll.dart';
import '../business_layer/SEOBll.dart';
import '../business_layer/ISitemapBll.dart';
import '../business_layer/SitemapBll.dart';

class SEOTestPage extends StatefulWidget {
  const SEOTestPage({Key? key}) : super(key: key);

  @override
  State<SEOTestPage> createState() => _SEOTestPageState();
}

class _SEOTestPageState extends State<SEOTestPage> {
  final ISEOBll _seoBll = SEOBll();
  final ISitemapBll _sitemapBll = SitemapBll();
  String _sitemapContent = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeSEO();
  }

  void _initializeSEO() {
    _seoBll.updatePageTitle('SEO Test Page - SolidCV');
    _seoBll.updateMetaDescription(
      'Test page for SEO implementation on SolidCV platform. Demonstrating dynamic meta tags and structured data.',
    );
    _seoBll.updateCanonicalUrl('https://solidcv.com/seo-test');
  }

  Future<void> _generateSitemap() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final sitemap = await _sitemapBll.generateSitemap();
      setState(() {
        _sitemapContent = sitemap;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating sitemap: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SEO Test Page'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SEO Implementation Test',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'This page demonstrates the SEO implementation for SolidCV:',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    const Text('✅ Dynamic meta tags'),
                    const Text('✅ Structured data (JSON-LD)'),
                    const Text('✅ Canonical URLs'),
                    const Text('✅ Open Graph tags'),
                    const Text('✅ Twitter Card tags'),
                    const Text('✅ SEO wrapper components'),
                    const Text('✅ Sitemap generation'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sitemap Generation',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _generateSitemap,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Generate Sitemap'),
                    ),
                    if (_sitemapContent.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Generated Sitemap:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            _sitemapContent,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SEO Features Implemented',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      'Dynamic Meta Tags',
                      'Page titles, descriptions, and canonical URLs are updated dynamically based on content.',
                    ),
                    _buildFeatureItem(
                      'Structured Data',
                      'JSON-LD structured data for better search engine understanding.',
                    ),
                    _buildFeatureItem(
                      'Social Media Optimization',
                      'Open Graph and Twitter Card tags for rich social media previews.',
                    ),
                    _buildFeatureItem(
                      'SEO Wrapper Components',
                      'Reusable SEO components following SolidCV architecture patterns.',
                    ),
                    _buildFeatureItem(
                      'Sitemap Generation',
                      'Automatic sitemap generation with public URLs, user profiles, and job listings.',
                    ),
                    _buildFeatureItem(
                      'Performance Optimization',
                      'Preconnect hints, DNS prefetch, and optimized loading for better Core Web Vitals.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
