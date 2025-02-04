// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.


import 'package:flutter_test/flutter_test.dart';
import 'package:solid_cv/data_access_layer/BlockChain/EtheriumWalletService.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSService.dart';
import 'package:solid_cv/data_access_layer/BlockChain/NearWalletService.dart';
import 'package:solid_cv/models/Company.dart';
import 'package:solid_cv/models/ExperienceRecord.dart';


void main() {
  // testWidgets('Counter increments smoke test', (WidgetTester tester) async {
  //   // Build our app and trigger a frame.
  //   await tester.pumpWidget(const MyApp());

  //   // Verify that our counter starts at 0.
  //   expect(find.text('0'), findsOneWidget);
  //   expect(find.text('1'), findsNothing);

  //   // Tap the '+' icon and trigger a frame.
  //   await tester.tap(find.byIcon(Icons.add));
  //   await tester.pump();

  //   // Verify that our counter has incremented.
  //   expect(find.text('0'), findsNothing);
  //   expect(find.text('1'), findsOneWidget);
  // });


  test('get balance is working', () async {
    final walletService = EtheriumWalletService();
    
    final result = await walletService.getBalanceInWei('0xF746A29543d46a85e44E8ba59ECc5Ef8295247DA');
    //console log the result
    print(result);

    expect(result, isNotNull);
  });

  test('create work experience', () async {
    final walletService = EtheriumWalletService();

    final result = await walletService.mintWorkExperienceToken(
      "0xa910f8b8391780abee534751c639711efb39cac3343abcd8ce4c79c4f27bbef0", //private key
      "0xEFe0D522aacbCd0149A34f00542Bf53dFf185d19",
      "0xEFe0D522aacbCd0149A34f00542Bf53dFf185d19",
      "https://ipfs.io/ipfs/test"
    );

    print(result);
    expect(result, isNotNull);
  });

  test('counter', () async {
    final walletService = EtheriumWalletService();

    final result = await walletService.count(
      "" //private key
    );

    print(result);
    expect(result, isNotNull);
  });

  test('send IPFS file', () async {
    final IPFSService ipfsService = IPFSService();
    var workExperience = ExperienceRecord();
    workExperience.company = "Test Company";
    workExperience.title = "Test Title";
    workExperience.location = "Test Location";
    workExperience.startDate = "11-11-2021";
    workExperience.endDate = "11-12-2021";

    final result = await ipfsService.saveWorkExperience(workExperience, new Company(name: "name", addressNumber: "addressNumber", addressStreet: "addressStreet", addressCity: "addressCity", addressZipCode: "addressZipCode", addressCountry: "addressCountry", phoneNumber: "phoneNumber", email: "email")); 

    print(result);

    expect(result, isNotNull);
  });
}
