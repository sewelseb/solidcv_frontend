import 'package:flutter/material.dart';
import 'package:solid_cv/Views/widgets/MyCvWidgets/DesktopView/MyCVDesktop.dart';
import 'package:solid_cv/Views/widgets/MyCvWidgets/MobileView/MyCvMobile.dart';

class MyCvRoute extends StatefulWidget {
  const MyCvRoute({super.key});

  @override
  State<MyCvRoute> createState() => _MyCvRouteState();
}

class _MyCvRouteState extends State<MyCvRoute> {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return isMobile ? const MyCvMobile() : const MyCvDesktop();
  }
}
