import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VerificationBadge extends StatelessWidget {
  final bool isVerified;
  final double size;
  final bool showLabel;
  final String? entityType; // 'company' or 'institution'

  const VerificationBadge({
    super.key,
    required this.isVerified,
    this.size = 20,
    this.showLabel = false,
    this.entityType,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVerified) return const SizedBox.shrink();

    if (showLabel) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.verified,
              color: Colors.blue.shade600,
              size: size,
            ),
            const SizedBox(width: 4),
            Text(
              'Verified',
              style: GoogleFonts.inter(
                fontSize: size * 0.6,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade700,
              ),
            ),
          ],
        ),
      );
    }

    return Tooltip(
      message: 'Verified ${entityType ?? 'organization'} ✓',
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.shade600,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade200,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.check,
          color: Colors.white,
          size: size,
        ),
      ),
    );
  }
}

class VerificationBadgeInline extends StatelessWidget {
  final bool isVerified;
  final double iconSize;
  final double fontSize;
  final String? entityName;

  const VerificationBadgeInline({
    super.key,
    required this.isVerified,
    this.iconSize = 16,
    this.fontSize = 14,
    this.entityName,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVerified) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Tooltip(
        message: '${entityName ?? 'Organization'} is verified by administrators',
        child: Icon(
          Icons.verified,
          color: Colors.blue.shade600,
          size: iconSize,
        ),
      ),
    );
  }
}
