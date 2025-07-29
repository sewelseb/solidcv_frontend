import 'package:flutter/material.dart';

// Concept 1: Certificate Style
class SolidCVLogoCertificate extends StatelessWidget {
  final double size;
  final bool showText;

  const SolidCVLogoCertificate({
    Key? key,
    this.size = 100.0,
    this.showText = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9C6AFF), Color(0xFF7B3FE4)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: size * 0.1,
            offset: Offset(0, size * 0.05),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Certificate
          Container(
            width: size * 0.5,
            height: size * 0.4,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(size * 0.025),
              border: Border.all(color: const Color(0xFF7B3FE4), width: size * 0.01),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: size * 0.35,
                  height: size * 0.015,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7B3FE4),
                    borderRadius: BorderRadius.circular(size * 0.005),
                  ),
                ),
                SizedBox(height: size * 0.02),
                // Gold seal with checkmark
                Container(
                  width: size * 0.15,
                  height: size * 0.15,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD700),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: const Color(0xFF7B3FE4),
                    size: size * 0.08,
                  ),
                ),
              ],
            ),
          ),
          if (showText)
            Positioned(
              bottom: size * 0.08,
              child: Column(
                children: [
                  Text(
                    'SOLID',
                    style: TextStyle(
                      fontSize: size * 0.08,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'CV',
                    style: TextStyle(
                      fontSize: size * 0.07,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// Concept 2: Badge Style
class SolidCVLogoBadge extends StatelessWidget {
  final double size;
  final bool showText;

  const SolidCVLogoBadge({
    Key? key,
    this.size = 100.0,
    this.showText = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9C6AFF), Color(0xFF7B3FE4)],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Badge circle
          Container(
            width: size * 0.84,
            height: size * 0.84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.white, width: size * 0.02),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // CV document
                Container(
                  width: size * 0.15,
                  height: size * 0.2,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7B3FE4),
                    borderRadius: BorderRadius.circular(size * 0.015),
                  ),
                ),
                // Verified stamp effect
                Container(
                  width: size * 0.7,
                  height: size * 0.7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF4CAF50),
                      width: size * 0.015,
                      style: BorderStyle.solid,
                    ),
                  ),
                ),
                // Checkmark
                Icon(
                  Icons.check,
                  color: const Color(0xFF4CAF50),
                  size: size * 0.2,
                ),
                // "VERIFIED" text
                Positioned(
                  bottom: size * 0.12,
                  child: Text(
                    'VERIFIED',
                    style: TextStyle(
                      fontSize: size * 0.05,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4CAF50),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (showText)
            Positioned(
              bottom: size * 0.08,
              child: Column(
                children: [
                  Text(
                    'SOLID',
                    style: TextStyle(
                      fontSize: size * 0.08,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'CV',
                    style: TextStyle(
                      fontSize: size * 0.07,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// Concept 3: Minimal Modern
class SolidCVLogoMinimal extends StatelessWidget {
  final double size;
  final bool showText;

  const SolidCVLogoMinimal({
    Key? key,
    this.size = 100.0,
    this.showText = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9C6AFF), Color(0xFF7B3FE4)],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Stylized document with integrated checkmark
          Container(
            width: size * 0.35,
            height: size * 0.35,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(0),
              ),
            ),
            child: Stack(
              children: [
                // Document lines
                Positioned(
                  top: size * 0.08,
                  left: size * 0.05,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: size * 0.2,
                        height: size * 0.015,
                        decoration: BoxDecoration(
                          color: const Color(0xFF7B3FE4),
                          borderRadius: BorderRadius.circular(size * 0.005),
                        ),
                      ),
                      SizedBox(height: size * 0.01),
                      Container(
                        width: size * 0.15,
                        height: size * 0.01,
                        color: const Color(0xFFB19CD9),
                      ),
                      SizedBox(height: size * 0.007),
                      Container(
                        width: size * 0.18,
                        height: size * 0.01,
                        color: const Color(0xFFB19CD9),
                      ),
                    ],
                  ),
                ),
                // Integrated checkmark
                Positioned(
                  right: size * 0.02,
                  top: size * 0.08,
                  child: Container(
                    width: size * 0.12,
                    height: size * 0.12,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: size * 0.08,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (showText)
            Positioned(
              bottom: size * 0.1,
              child: Column(
                children: [
                  Text(
                    'SOLID CV',
                    style: TextStyle(
                      fontSize: size * 0.09,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'VERIFIED PROFILES',
                    style: TextStyle(
                      fontSize: size * 0.05,
                      color: const Color(0xFFE0E0FF),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// Concept 4: Tech/Blockchain
class SolidCVLogoTech extends StatelessWidget {
  final double size;
  final bool showText;

  const SolidCVLogoTech({
    Key? key,
    this.size = 100.0,
    this.showText = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9C6AFF), Color(0xFF7B3FE4)],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Hexagonal frame
          Container(
            width: size * 0.5,
            height: size * 0.5,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(size * 0.1),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // CV document
                Container(
                  width: size * 0.15,
                  height: size * 0.18,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7B3FE4),
                    borderRadius: BorderRadius.circular(size * 0.01),
                  ),
                ),
                // Circuit connection points
                Positioned(
                  left: 0,
                  top: size * 0.08,
                  child: Container(
                    width: size * 0.04,
                    height: size * 0.04,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00BCD4),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: size * 0.08,
                  child: Container(
                    width: size * 0.04,
                    height: size * 0.04,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00BCD4),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Verification badge
          Positioned(
            bottom: size * 0.25,
            child: Container(
              width: size * 0.15,
              height: size * 0.15,
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: size * 0.1,
              ),
            ),
          ),
          if (showText)
            Positioned(
              bottom: size * 0.08,
              child: Column(
                children: [
                  Text(
                    'SOLID',
                    style: TextStyle(
                      fontSize: size * 0.08,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'CV',
                    style: TextStyle(
                      fontSize: size * 0.07,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// Concept 5: Professional Shield
class SolidCVLogoShield extends StatelessWidget {
  final double size;
  final bool showText;

  const SolidCVLogoShield({
    Key? key,
    this.size = 100.0,
    this.showText = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9C6AFF), Color(0xFF7B3FE4)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: size * 0.1,
            offset: Offset(0, size * 0.05),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Shield shape
          Container(
            width: size * 0.4,
            height: size * 0.48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(size * 0.2),
                topRight: Radius.circular(size * 0.2),
                bottomLeft: Radius.circular(size * 0.05),
                bottomRight: Radius.circular(size * 0.05),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: size * 0.02,
                  offset: Offset(size * 0.01, size * 0.01),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // CV document inside shield
                Container(
                  width: size * 0.15,
                  height: size * 0.2,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7B3FE4),
                    borderRadius: BorderRadius.circular(size * 0.015),
                  ),
                ),
                // Verification checkmark
                Positioned(
                  right: size * 0.08,
                  bottom: size * 0.12,
                  child: Container(
                    width: size * 0.1,
                    height: size * 0.1,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: size * 0.06,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (showText)
            Positioned(
              bottom: size * 0.08,
              child: Column(
                children: [
                  Text(
                    'SOLID',
                    style: TextStyle(
                      fontSize: size * 0.08,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'CV',
                    style: TextStyle(
                      fontSize: size * 0.07,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
