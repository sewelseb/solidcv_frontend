import 'package:flutter/material.dart';
import 'package:solid_cv/models/Certificate.dart';

class CertificateFromBlockchain extends StatelessWidget {
  final Certificate certificate;

  const CertificateFromBlockchain({Key? key, required this.certificate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    certificate.title ?? 'No title',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent),
                  ),
                  SizedBox(height: 8),
                  // Text(
                  //   'Issued by: ${certificate.issuer ?? 'Unknown'}',
                  //   style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  // ),
                  // SizedBox(height: 8),
                  // Text(
                  //   'Date Issued: ${certificate.dateIssued?.toShortDateString() ?? 'Unknown'}',
                  //   style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  // ),
                  SizedBox(height: 16),
                  Text(
                    certificate.description ?? 'No description available.',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
            Positioned(
        top: 10,
        right: 10,
        child: Row(
          children: [
            const Icon(Icons.verified, color: Colors.green, size: 24),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
              'Verified on the Blockchain',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        ),
          ],
        ),
      ),
    );
  }
}

extension DateTimeExtension on DateTime {
  String toShortDateString() {
    return '${this.day}/${this.month}/${this.year}';
  }
}
