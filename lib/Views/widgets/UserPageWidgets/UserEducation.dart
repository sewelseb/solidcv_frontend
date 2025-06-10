import 'package:flutter/material.dart';
import 'package:solid_cv/Views/widgets/UserPageWidgets/UserEducationCard.dart';
import 'package:solid_cv/business_layer/BlockchainWalletBll.dart';
import 'package:solid_cv/business_layer/EducationInstitutionBll.dart';
import 'package:solid_cv/business_layer/IBlockchainWalletBll.dart';
import 'package:solid_cv/business_layer/IEducationInstitutionBll.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/models/CertificatWrapper.dart';

class UserEducation extends StatefulWidget {
  final String userId;

  const UserEducation({super.key, required this.userId});

  @override
  State<UserEducation> createState() => _UserEducationState();
}

class _UserEducationState extends State<UserEducation> {
  final IUserBLL _userBLL = UserBll();
  final IBlockchainWalletBll _blockchainWalletBLL = BlockchainWalletBll();
  final IEducationInstitutionBll _institutionBLL = EducationInstitutionBll();

  late Future<List<CertificatWrapper>> _certificatesFuture;

  @override
  void initState() {
    super.initState();
    _certificatesFuture = _loadCertificates();
  }

  Future<List<CertificatWrapper>> _loadCertificates() async {
    final user = await _userBLL.getUser(widget.userId);
    final List<CertificatWrapper> result = [];

    if (user.ethereumAddress != null) {
      final blockchainCerts =
          await _blockchainWalletBLL.getCertificates(user.ethereumAddress!);
      for (var cert in blockchainCerts) {
        if (cert.issuerBlockCahinWalletAddress != null) {
          final institution =
              await _institutionBLL.getEducationInstitutionByWallet(
                  cert.issuerBlockCahinWalletAddress!);
          cert.logoUrl = institution?.getProfilePicture();
        }
        result.add(CertificatWrapper(cert, true));
      }
    }

    final manualCerts =
        await _userBLL.getUsersManuallyAddedCertificates(widget.userId);
    result.addAll(manualCerts.map((c) => CertificatWrapper(c, false)));

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Education',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<CertificatWrapper>>(
          future: _certificatesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('No certificates found.');
            }

            return Column(
              children: snapshot.data!
                  .map((c) => UserEducationCard(
                      certificate: c.cert, isValidated: c.isBlockchain))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

