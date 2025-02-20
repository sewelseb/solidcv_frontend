import 'package:flutter/material.dart';
import 'package:solid_cv/business_layer/BlockchainWalletBll.dart';
import 'package:solid_cv/business_layer/IBlockchainWalletBll.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/models/Certificate.dart';

class MyEducation extends StatefulWidget {
  @override
  _MyEducationState createState() => _MyEducationState();
}

class _MyEducationState extends State<MyEducation> {
  IBlockchainWalletBll _blockchainWalletBll = BlockchainWalletBll();
  late Future<List<Certificate>> _certificates;

  @override
  Widget build(BuildContext context) {
    _certificates = _blockchainWalletBll.getCertificatesForCurrentUser();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Text(
                'Education',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/addACertification');
                },
                child: const Text('+ Add manually a new certification'),
              ),
            ],
          ),
        ),
        FutureBuilder(
          future: _certificates,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No certificates found.'));
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...snapshot.data!.map((certificate) {
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              certificate.title!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: Colors.blueAccent,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              certificate.description!,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Text(
                                //   'Issued by: ${certificate.}',
                                //   style: const TextStyle(
                                //   fontSize: 14,
                                //   fontStyle: FontStyle.italic,
                                //   ),
                                // ),
                                Text(
                                  'Date: ${certificate.publicationDate}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              );
            }
          },
        )
      ],
    );
  }
}
