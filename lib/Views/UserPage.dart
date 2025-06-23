import 'package:flutter/material.dart';
import 'package:solid_cv/Views/widgets/UserPageWidgets/DesktopView/UserVerifyCvDesktop.dart';
import 'package:solid_cv/Views/widgets/UserPageWidgets/MobileView/UserVerifyCvMobile.dart';

class UserPage extends StatefulWidget {
  final String userId;
  const UserPage({super.key, required this.userId});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return isMobile
        ? UserVerifyCvMobile(userId: widget.userId)
        : UserVerifyCvDesktop(userId: widget.userId);
  }
}
