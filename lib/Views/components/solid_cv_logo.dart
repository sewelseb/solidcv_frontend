import 'package:flutter/material.dart';

class SolidCVLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const SolidCVLogo({
    super.key,
    this.size = 100.0,
    this.showText = true,
  });

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
          colors: [
            Color(0xFF9C6AFF),
            Color(0xFF7B3FE4),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF5A2FB8),
          width: size * 0.015,
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
          // Document icon
          Container(
            width: size * 0.4,
            height: size * 0.5,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(size * 0.04),
              border: Border.all(
                color: const Color(0xFFE0E0E0),
                width: size * 0.01,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: size * 0.02,
                  offset: Offset(size * 0.01, size * 0.01),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(size * 0.025),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header line
                  Container(
                    height: size * 0.02,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7B3FE4),
                      borderRadius: BorderRadius.circular(size * 0.01),
                    ),
                  ),
                  SizedBox(height: size * 0.01),
                  // Content lines
                  ...List.generate(3, (index) => Padding(
                    padding: EdgeInsets.only(bottom: size * 0.008),
                    child: Container(
                      height: size * 0.01,
                      width: (0.8 - index * 0.1) * size * 0.35,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB19CD9),
                        borderRadius: BorderRadius.circular(size * 0.005),
                      ),
                    ),
                  )),
                  SizedBox(height: size * 0.015),
                  // Second section
                  Container(
                    height: size * 0.02,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7B3FE4),
                      borderRadius: BorderRadius.circular(size * 0.01),
                    ),
                  ),
                  SizedBox(height: size * 0.01),
                  ...List.generate(2, (index) => Padding(
                    padding: EdgeInsets.only(bottom: size * 0.008),
                    child: Container(
                      height: size * 0.01,
                      width: (0.9 - index * 0.15) * size * 0.35,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB19CD9),
                        borderRadius: BorderRadius.circular(size * 0.005),
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),
          
          // Large validation checkmark - MAIN FEATURE
          Positioned(
            right: size * 0.15,
            bottom: size * 0.35,
            child: Container(
              width: size * 0.18,
              height: size * 0.18,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF2E7D32),
                  width: size * 0.01,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: size * 0.02,
                    offset: Offset(size * 0.005, size * 0.005),
                  ),
                ],
              ),
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: size * 0.12,
              ),
            ),
          ),
          
          // Shield for additional security indication
          Positioned(
            left: size * 0.2,
            bottom: size * 0.28,
            child: Container(
              width: size * 0.12,
              height: size * 0.15,
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800),
                borderRadius: BorderRadius.circular(size * 0.02),
                border: Border.all(
                  color: const Color(0xFFF57C00),
                  width: size * 0.005,
                ),
              ),
              child: Icon(
                Icons.verified_user,
                color: Colors.white,
                size: size * 0.08,
              ),
            ),
          ),
          
          // Text overlay
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
                      shadows: [
                        Shadow(
                          offset: Offset(0, size * 0.002),
                          blurRadius: size * 0.01,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'CV',  
                    style: TextStyle(
                      fontSize: size * 0.07,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFE8E0FF),
                      shadows: [
                        Shadow(
                          offset: Offset(0, size * 0.002),
                          blurRadius: size * 0.01,
                          color: Colors.black26,
                        ),
                      ],
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

// Alternative validation-focused icon
class SolidCVIcon extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final bool showValidation;

  const SolidCVIcon({
    super.key,
    this.size = 40.0,
    this.backgroundColor,
    this.showValidation = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? const Color(0xFF7B3FE4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: size * 0.1,
            offset: Offset(0, size * 0.05),
          ),
        ],
      ),
      child: showValidation 
          ? Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.description,
                  size: size * 0.5,
                  color: Colors.white,
                ),
                Positioned(
                  right: size * 0.05,
                  bottom: size * 0.05,
                  child: Container(
                    width: size * 0.3,
                    height: size * 0.3,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: size * 0.2,
                    ),
                  ),
                ),
              ],
            )
          : Icon(
              Icons.description,
              size: size * 0.6,
              color: Colors.white,
            ),
    );
  }
}
