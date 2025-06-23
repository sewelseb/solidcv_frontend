import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedbackDialog extends StatelessWidget {
  final String feedbacks;

  const FeedbackDialog({super.key, required this.feedbacks});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      backgroundColor: Colors.white,
      title: Text(
        'Feedbacks',
        style: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: const Color(0xFF7B3FE4),
        ),
        textAlign: TextAlign.center,
      ),
      content: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        constraints: const BoxConstraints(maxWidth: 340),
        child: SingleChildScrollView(
          child: Text(
            feedbacks,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, right: 10),
          child: SizedBox(
            width: 120,
            height: 45,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7B3FE4),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Text(
                'Fermer',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
