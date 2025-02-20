import 'package:flutter/material.dart';
import 'package:solid_cv/Views/widgets/userWidgets/CertificateFromBlockchain.dart';
import 'package:solid_cv/business_layer/BlockchainWalletBll.dart';
import 'package:solid_cv/business_layer/IBlockchainWalletBll.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/models/Certificate.dart';
import 'package:solid_cv/models/User.dart';

class EducationWidget extends StatefulWidget {
  final String userId;

  const EducationWidget({Key? key, required this.userId}) : super(key: key);

  @override
  _EducationWidgetState createState() => _EducationWidgetState();
}

class _EducationWidgetState extends State<EducationWidget> {
  IUserBLL _userBLL = UserBll();
  late Future<User> _user;
  IBlockchainWalletBll _blockchainWalletBll = BlockchainWalletBll();
  late Future<List<Certificate>> _certificates;

  @override
  Widget build(BuildContext context) {
    _user = _userBLL.getUser(widget.userId).then((value) {
      if (value.ethereumAddress != null) _certificates = Future.value([]);

      _certificates =
          _blockchainWalletBll.getCertificates(value.ethereumAddress!);
      return value;
    });

    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Education',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          FutureBuilder<User>(
            future: _user,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                return FutureBuilder<List<Certificate>>(
                  future: _certificates,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text('No certificates found.'));
                    } else {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...snapshot.data!.map((certificate) {
                            return CertificateFromBlockchain(
                                certificate: certificate);
                          }).toList(),
                        ],
                      );
                    }
                  },
                );
              } else {
                return const Center(child: Text('No user found.'));
              }
            },
          ),
        ],
      ),
    );
  }
}
