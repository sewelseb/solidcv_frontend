import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/models/Skill.dart';
// Import your Skill model here - adjust the path as needed
// import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/Skill/ManualSkill.dart';

class SkillsEditStep extends StatefulWidget {
  final Function(List<Skill>) onComplete; // Changed to ManualSkill
  final bool isActive;

  const SkillsEditStep({
    super.key,
    required this.onComplete,
    required this.isActive,
  });

  @override
  State<SkillsEditStep> createState() => _SkillsEditStepState();
}

class _SkillsEditStepState extends State<SkillsEditStep>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  IUserBLL _userBll = UserBll();
  
  // Keep the future for loading
  late Future<List<Skill>> _skillsFuture;
  // Use a regular list for editing
  List<Skill> _skills = [];
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _skillsFuture = _userBll.getMySkills(); // Assuming this method exists
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    if (widget.isActive) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _animationController.forward();
      });
    }
  }

  void _removeSkill(int id) {
    _userBll.deleteSkill(id);
    setState(() {
      _skills.removeWhere((skill) => skill.id == id);
    });
  }

  void _submitSkills() {
    widget.onComplete(_skills);
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bot avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7B3FE4), Color(0xFFB57AED)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.star,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            
            // Message bubble
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: FutureBuilder<List<Skill>>(
                  future: _skillsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Column(
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            'Loading your skills...',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      );
                    }
                    
                    if (snapshot.hasError) {
                      // Initialize empty list on error
                      if (!_isInitialized) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          setState(() {
                            _skills = [];
                            _isInitialized = true;
                          });
                        });
                      }
                      
                      return Column(
                        children: [
                          Icon(Icons.error, color: Colors.red.shade400, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            'Error loading skills',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.red.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Continue without skills for now',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      );
                    }
                    
                    // Initialize the editable list once when data loads
                    if (snapshot.hasData && !_isInitialized) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {
                          _skills = List.from(snapshot.data!);
                          _isInitialized = true;
                        });
                      });
                    }
                    
                    return _buildSkillsContent();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review Your Skills',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'You have ${_skills.length} skill${_skills.length != 1 ? 's' : ''}. You can remove any that aren\'t relevant.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey.shade700,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        
        // Skills list
        if (_skills.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.psychology_outlined, color: Colors.grey.shade400, size: 32),
                const SizedBox(height: 8),
                Text(
                  'No skills found',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Continue to complete your profile setup',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // Skills grid
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.purple.shade600, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Tap × to remove skills you don\'t want to include',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.purple.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _skills.asMap().entries.map((entry) {
                    final index = entry.key;
                    final skill = entry.value;
                    return _buildSkillChip(index, skill);
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
        
        const SizedBox(height: 16),
        
        // Summary
        if (_skills.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.blue.shade600, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_skills.length} skills will be included in your profile',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Continue button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _submitSkills,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7B3FE4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.check_circle, size: 16),
            label: const Text('Complete Profile Setup'),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillChip(int index, Skill skill) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Skill icon
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: _getSkillColor(skill.name).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getSkillIcon(skill.name),
                size: 12,
                color: _getSkillColor(skill.name),
              ),
            ),
            const SizedBox(width: 8),
            
            // Skill name
            Flexible(
              child: Text(
                skill.name ?? 'Skill',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            
            // Remove button
            GestureDetector(
              onTap: () => _removeSkill(skill.id!),
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  Icons.close,
                  size: 12,
                  color: Colors.red.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSkillColor(String? skillName) {
    if (skillName == null) return Colors.grey.shade600;
    
    final name = skillName.toLowerCase();
    
    // Programming languages
    if (['javascript', 'python', 'java', 'c++', 'c#', 'php', 'ruby', 'go', 'rust', 'swift', 'kotlin'].any((lang) => name.contains(lang))) {
      return Colors.blue.shade600;
    }
    // Frameworks
    if (['react', 'angular', 'vue', 'flutter', 'django', 'spring', 'laravel', 'express'].any((fw) => name.contains(fw))) {
      return Colors.green.shade600;
    }
    // Cloud/DevOps
    if (['aws', 'azure', 'gcp', 'docker', 'kubernetes', 'jenkins', 'terraform'].any((cloud) => name.contains(cloud))) {
      return Colors.cyan.shade600;
    }
    // Databases
    if (['mysql', 'postgresql', 'mongodb', 'redis', 'elasticsearch', 'oracle'].any((db) => name.contains(db))) {
      return Colors.red.shade600;
    }
    
    return Colors.purple.shade600;
  }

  IconData _getSkillIcon(String? skillName) {
    if (skillName == null) return Icons.star;
    
    final name = skillName.toLowerCase();
    
    if (['javascript', 'python', 'java', 'c++', 'c#', 'php', 'ruby', 'go', 'rust', 'swift', 'kotlin'].any((lang) => name.contains(lang))) {
      return Icons.code;
    }
    if (['react', 'angular', 'vue', 'flutter', 'django', 'spring', 'laravel', 'express'].any((fw) => name.contains(fw))) {
      return Icons.layers;
    }
    if (['aws', 'azure', 'gcp', 'docker', 'kubernetes', 'jenkins', 'terraform'].any((cloud) => name.contains(cloud))) {
      return Icons.cloud;
    }
    if (['mysql', 'postgresql', 'mongodb', 'redis', 'elasticsearch', 'oracle'].any((db) => name.contains(db))) {
      return Icons.storage;
    }
    
    return Icons.star;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}