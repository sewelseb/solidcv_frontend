import 'package:flutter/material.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';
import 'package:solid_cv/business_layer/BlockchainWalletBll.dart';
import 'package:solid_cv/business_layer/IBlockchainWalletBll.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/data_access_layer/IUserService.dart';
import 'package:solid_cv/data_access_layer/UserService.dart';
import 'package:solid_cv/models/User.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

class LoggedInHome extends StatefulWidget {
  const LoggedInHome({super.key});

  @override
  State<LoggedInHome> createState() => _LoggedInHomeState();
}

class _LoggedInHomeState extends State<LoggedInHome> {
  final IBlockchainWalletBll _blockchainWalletBll = BlockchainWalletBll();
  TextEditingController walletAddressController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final IUserBLL _userBll = UserBll();
  late Future<User> _currentUser;
  Wallet? wallet;

  @override
  Widget build(BuildContext context) {
    _currentUser = _userBll.getCurrentUser();

    return Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
        ),
        bottomNavigationBar: const MainBottomNavigationBar(),
        body:
            //add a form to connect your etherium wallet
            ListView(
              shrinkWrap: true,
              children: [
                FutureBuilder(
                          future: _currentUser,
                          builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.ethereumAddress != null && wallet == null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Your Ethereum Wallet',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const Text(
                              "Your wallet is connected and ready to use. You can start using the app's features.",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Wallet Address: ${snapshot.data!.ethereumAddress}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Connect your Ethereum Wallet',
                                  style: TextStyle(
                                      fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                                const Text(
                                  "Connect your wallet to start using the app's features. The wallet will be used to store your credentials (work experiences and diplomas) and other important information as NFTs.",
                                  textAlign: TextAlign.center,
                                  style:
                                      TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                                const SizedBox(height: 20),
                                TextField(
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Wallet Address',
                                  ),
                                  controller: walletAddressController,
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () async {
                                    var success = await _blockchainWalletBll
                                        .saveWalletAddressForCurrentUser(
                                            walletAddressController.text);
                                    if (success) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Wallet address saved successfully'),
                                        ),
                                      );
                                      //reload the page
                                      setState(() {
                                        walletAddressController.clear();
                                      });
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Failed to save wallet address, probably the address is invalid'),
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text('Connect'),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  "Or create a new wallet",
                                  style: TextStyle(
                                      fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 20),
                                TextField(
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText:
                                        'Password (to encrypt the private key, make sure to remember it, there is no way to recover it)',
                                  ),
                                  controller: passwordController,
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () async {
                                    wallet = await _blockchainWalletBll
                                        .createANewWalletAddressForCurrentUser(
                                            passwordController.text);
                                    if (wallet != null) {
                                      setState(() {
                                        passwordController.clear();
                                      });
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Failed to create wallet'),
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text('Create a new wallet'),
                                ),
                                const SizedBox(height: 20),
                                if (wallet != null) ...[
                                  const Text(
                                    'Wallet created successfully',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SelectableText(
                                      'Public Key: ${wallet!.privateKey.address.hex}'),
                                  const SizedBox(height: 10),
                                    SelectableText(
                                      'Private Key: 0x${bytesToHex(wallet!.privateKey.privateKey)}'),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Make sure to save the private key in a safe place, it will not be shown again and you can\'t recover it.',
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.red,
                                    ),
                                  )
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                          },
                        ),
              ],
            ));
  }
}
