import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';

class CVCheckStep extends StatefulWidget {
  final Function({Map<String, dynamic>? data}) onNext;

  const CVCheckStep({super.key, required this.onNext});

  @override
  State<CVCheckStep> createState() => _CVCheckStepState();
}

class _CVCheckStepState extends State<CVCheckStep> {
  final IUserBLL _userBll = UserBll();
  bool _isChecking = true;
  bool _hasCv = false;
  String? _errorMessage;
  
  final Color _primaryColor = const Color(0xFF7B3FE4);

  @override
  void initState() {
    super.initState();
    _checkCvStatus();
  }

  Future<void> _checkCvStatus() async {
    try {
      final user = await _userBll.getCurrentUser();
      
      // Check if user has completed their CV
      // You'll need to implement this check based on your CV structure
      final hasCompletedCv = await _userBll.hasCompletedCV();
      
      setState(() {
        _hasCv = hasCompletedCv;
        _isChecking = false;
      });

      // If CV is complete, automatically proceed after a short delay
      if (hasCompletedCv) {
        await Future.delayed(const Duration(seconds: 2));
        widget.onNext(data: {'cvCompleted': true});
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error checking CV status: $e';
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isChecking) ...[
            CircularProgressIndicator(color: _primaryColor),
            const SizedBox(height: 24),
            Text(
              'Checking your CV status...',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ] else if (_errorMessage != null) ...[
            Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isChecking = true;
                  _errorMessage = null;
                });
                _checkCvStatus();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Try Again'),
            ),
          ] else if (_hasCv) ...[
            Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 24),
            Text(
              'Great! Your CV is ready',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'We found your completed CV. Let\'s continue with personalized career advice.',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.black54,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ] else ...[
            Icon(Icons.description_outlined, color: Colors.orange, size: 64),
            const SizedBox(height: 24),
            Text(
              'Complete Your CV First',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'To provide you with the best career advice, we need to analyze your CV first. Please complete your CV and then return to the career advisor.',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.black54,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/my-cv');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.edit_document),
                label: const Text('Complete My CV'),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _isChecking = true;
                });
                _checkCvStatus();
              },
              child: Text(
                'I\'ve completed my CV - Check again',
                style: TextStyle(color: _primaryColor),
              ),
            ),
          ],
        ],
      ),
    );
  }
}