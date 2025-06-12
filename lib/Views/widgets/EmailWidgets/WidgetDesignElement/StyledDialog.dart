import 'package:flutter/material.dart';

class StyledDialog extends StatelessWidget {
  final String title;
  final String content;
  const StyledDialog({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.email_outlined,
                  color: Color(0xFF7B3FE4), size: 46),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                content,
                style: const TextStyle(fontSize: 15.5, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7B3FE4),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11)),
                  ),
                  child: const Text("OK",
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15.5)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
