import 'package:flutter/material.dart';
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

class UserVerifyCvEducationMobile extends StatefulWidget {
  final String userId;
  const UserVerifyCvEducationMobile({super.key, required this.userId});

  @override
  _UserVerifyCvEducationMobileState createState() =>
      _UserVerifyCvEducationMobileState();
}

class _UserVerifyCvEducationMobileState
    extends State<UserVerifyCvEducationMobile> {
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
    _userFuture = _userBll.getUser(widget.userId);
    _allCertificates = _loadAllCertificates();
  }

  Future<List<CertificatWrapper>> _loadAllCertificates() async {
    final user = await _userFuture;

    if (user.ethereumAddress == null) {
      return [];
    }
    final results = await Future.wait([
      _blockchainWalletBll.getCertificates(user.ethereumAddress!),
      _userBll.getUsersManuallyAddedCertificates(widget.userId),
    ]);

    final certificateFromBlockchainList = results[0];
    final manuallyAddedCertificate = results[1];

    final List<CertificatWrapper> allCertificates = [];
    for (final cert in certificateFromBlockchainList) {
      if (cert.issuerBlockCahinWalletAddress != null) {
        final institution =
            await _educationInstitutionBll.getEducationInstitutionByWallet(
                cert.issuerBlockCahinWalletAddress!);
        cert.logoUrl = institution?.getProfilePicture();
      }
      allCertificates.add(CertificatWrapper(cert, true));
    }

    for (final cert in manuallyAddedCertificate) {
      allCertificates.add(CertificatWrapper(cert, false));
    }

    return allCertificates;
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
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return const Row(
      children: [
        Text(
          'Education',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Spacer(),
      ],
    );
  }

  BoxDecoration glassCardDecoration() => BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF7B3FE4).withOpacity(0.18),
          width: 1.4,
        ),
      );
}
