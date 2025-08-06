import 'package:flutter/material.dart';
import 'package:solid_cv/Views/widgets/AddManuallyCertificateDialog.dart';
import 'package:solid_cv/Views/widgets/MyCvWidgets/MobileView/MyEducationMobileCard.dart';
import 'package:solid_cv/business_layer/EducationInstitutionBll.dart';
import 'package:solid_cv/business_layer/IEducationInstitutionBll.dart';
import 'package:solid_cv/models/CertificatWrapper.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/business_layer/IBlockchainWalletBll.dart';
import 'package:solid_cv/business_layer/BlockchainWalletBll.dart';
import 'dart:io';

import 'package:solid_cv/models/User.dart';

class MyEducationMobileView extends StatefulWidget {
  const MyEducationMobileView({super.key});

  @override
  _MyEducationMobileViewState createState() => _MyEducationMobileViewState();
}

class _MyEducationMobileViewState extends State<MyEducationMobileView> {
  final IBlockchainWalletBll _blockchainWalletBll = BlockchainWalletBll();
  final IUserBLL _userBll = UserBll();
  final IEducationInstitutionBll _educationInstitutionBll =
      EducationInstitutionBll();
  late Future<User> _userFuture;

  late TextEditingController _publicationDateController;
  File? file;
  late Future<List<CertificatWrapper>> _allCertificates;

  @override
  void initState() {
    super.initState();
    _publicationDateController = TextEditingController();
    _userFuture = _userBll.getCurrentUser();

    _allCertificates = _loadAllCertificates();
  }

  Future<List<CertificatWrapper>> _loadAllCertificates() async {
    final user = await _userFuture;
    if (user.ethereumAddress == null) {
      return [];
    }
    final blockchain =
        await _blockchainWalletBll.getCertificatesForCurrentUser();
    for (final cert in blockchain) {
      if (cert.issuerBlockCahinWalletAddress != null) {
        final institution =
            await _educationInstitutionBll.getEducationInstitutionByWallet(
                cert.issuerBlockCahinWalletAddress!);
        cert.logoUrl = institution?.getProfilePicture();
      }
    }

    final manual = await _userBll.getMyManuallyAddedCertificates();

    return [
      ...blockchain.map((e) => CertificatWrapper(e, true)),
      ...manual.map((e) => CertificatWrapper(e, false)),
    ];
  }

  @override
  void dispose() {
    _publicationDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: 16),
        FutureBuilder<List<CertificatWrapper>>(
          future: _allCertificates,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No education certificate yet."));
            }

            final certs = snapshot.data ?? [];

            return Column(
              children: certs
                  .map((c) => EducationMobileCard(
                        certificate: c.cert,
                        isValidated: c.isBlockchain,
                         onCertificateDeleted: () {
                          setState(() {
                            _allCertificates = _loadAllCertificates();
                          });
                        },
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Education',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () async {
            await AddManuallyCertificateDialog.show(
              context,
              onAdd: (certificate) async {
                await _userBll.addMyCertificateManually(certificate);
                setState(() {
                  _allCertificates = _loadAllCertificates();
                });
              },
            );
          },
          icon: const Icon(Icons.add_circle_outline),
          tooltip: 'Add education',
        ),
      ],
    );
  }
}
