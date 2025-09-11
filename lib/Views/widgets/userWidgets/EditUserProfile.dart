import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/models/User.dart';
import 'package:solid_cv/providers/LanguageProvider.dart';

class EditProfileRoute extends StatefulWidget {
  final User user;
  const EditProfileRoute({super.key, required this.user});

  @override
  State<EditProfileRoute> createState() => _EditProfileRouteState();
}

class _EditProfileRouteState extends State<EditProfileRoute> {
  final IUserBLL _userBll = UserBll();

  // Following SolidCV's async data loading pattern
  late Future<User> _currentUserFuture;

  final _formKey = GlobalKey<FormState>();
  // Initialize controllers with empty values to prevent LateInitializationError
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _biographyController = TextEditingController();
  TextEditingController _linkedinController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Uint8List? _pickedProfilePicBytes;
  String? _pickedProfilePicExt;
  bool _isSaving = false;

  // Configuration attribute
  bool _receiveWeeklyRecommendationEmails = true; // Initialize with default value
  bool _controllersInitialized = false;

  @override
  void initState() {
    super.initState();
    // Load fresh user data from backend following SolidCV patterns
    _currentUserFuture = _userBll.getCurrentUser();
    // Initialize controllers with fallback data from widget.user
    _initializeControllersWithFallback();
  }

  void _initializeControllersWithFallback() {
    // Initialize with fallback data to prevent LateInitializationError
    _firstNameController.text = widget.user.firstName ?? "";
    _lastNameController.text = widget.user.lastName ?? "";
    _phoneNumberController.text = widget.user.phoneNumber ?? "";
    _biographyController.text = widget.user.biography ?? "";
    _linkedinController.text = widget.user.linkedin ?? "";
    _receiveWeeklyRecommendationEmails = widget.user.receiveWeeklyRecommendationEmails ?? true;
  }

  void _updateControllersWithFreshData(User freshUser) {
    if (!mounted) return;
    
    setState(() {
      _firstNameController.text = freshUser.firstName ?? "";
      _lastNameController.text = freshUser.lastName ?? "";
      _phoneNumberController.text = freshUser.phoneNumber ?? "";
      _biographyController.text = freshUser.biography ?? "";
      _linkedinController.text = freshUser.linkedin ?? "";
      _receiveWeeklyRecommendationEmails = freshUser.receiveWeeklyRecommendationEmails ?? true;
      _controllersInitialized = true;
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _biographyController.dispose();
    _linkedinController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickProfilePicture() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
      allowMultiple: false,
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _pickedProfilePicBytes = result.files.single.bytes!;
        _pickedProfilePicExt = result.files.single.extension;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      User updatedUser = User(
        id: widget.user.id,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        phoneNumber: _phoneNumberController.text,
        biography: _biographyController.text,
        linkedin: _linkedinController.text,
        email: widget.user.email,
        receiveWeeklyRecommendationEmails: _receiveWeeklyRecommendationEmails,
      );
      
      await _userBll.updateUser(
        updatedUser,
        _pickedProfilePicBytes,
        _pickedProfilePicExt,
        updatedUser.id!,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.editProfileUpdated),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.editProfileError(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String _getLanguageDisplayName(BuildContext context) {
    final languageProvider = LanguageProvider();
    final currentLocale = languageProvider.locale ?? const Locale('en', '');
    final localizations = AppLocalizations.of(context)!;
    
    switch (currentLocale.languageCode) {
      case 'en':
        return localizations.english;
      case 'es':
        return localizations.spanish;
      case 'fr':
        return localizations.french;
      default:
        return localizations.english;
    }
  }

  Future<void> _handleLanguageChange(Locale locale) async {
    final languageProvider = LanguageProvider();
    
    // Update language locally first
    languageProvider.setLocale(locale);
    
    // Send language preference to backend
    try {
      await _userBll.updateLanguagePreference(locale.languageCode);
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.editProfileLanguageUpdated),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      // Show error but don't revert local change
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.editProfileLanguageError),
          backgroundColor: Colors.orange,
        ),
      );
      debugPrint('Failed to update language preference on backend: $e');
    }
    
    setState(() {}); // Refresh to show new language
  }

  void _showLanguageSelectionDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final languageProvider = LanguageProvider();
    final currentLocale = languageProvider.locale ?? const Locale('en', '');
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.changeLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Text('🇺🇸'),
                title: Text(localizations.english),
                trailing: currentLocale.languageCode == 'en'
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () async {
                  Navigator.of(context).pop();
                  await _handleLanguageChange(const Locale('en', ''));
                },
              ),
              ListTile(
                leading: const Text('🇪🇸'),
                title: Text(localizations.spanish),
                trailing: currentLocale.languageCode == 'es'
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () async {
                  Navigator.of(context).pop();
                  await _handleLanguageChange(const Locale('es', ''));
                },
              ),
              ListTile(
                leading: const Text('🇫🇷'),
                title: Text(localizations.french),
                trailing: currentLocale.languageCode == 'fr'
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () async {
                  Navigator.of(context).pop();
                  await _handleLanguageChange(const Locale('fr', ''));
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localizations.cancel),
            ),
          ],
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF7B3FE4)) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF7B3FE4), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      labelStyle: GoogleFonts.inter(color: Colors.black87),
      hintStyle: GoogleFonts.inter(color: Colors.black26),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.editProfileTitle, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF7B3FE4),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 1,
      ),
      bottomNavigationBar: const MainBottomNavigationBar(),
      backgroundColor: Colors.white,
      body: FutureBuilder<User>(
        future: _currentUserFuture,
        builder: (context, snapshot) {
          // Following SolidCV's async state handling pattern
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(AppLocalizations.of(context)!.editProfileErrorLoading(snapshot.error.toString())),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _controllersInitialized = false;
                        _currentUserFuture = _userBll.getCurrentUser();
                      });
                    },
                    child: Text(AppLocalizations.of(context)!.editProfileRetry),
                  ),
                ],
              ),
            );
          }
          
          if (!snapshot.hasData) {
            return Center(child: Text(AppLocalizations.of(context)!.editProfileUserNotFound));
          }

          // Update controllers with fresh data from backend
          final freshUser = snapshot.data!;
          
          // Update controllers after the first frame to prevent setState during build
          if (!_controllersInitialized) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _updateControllersWithFreshData(freshUser);
            });
          }

          return _buildEditForm(isMobile, freshUser);
        },
      ),
    );
  }

  Widget _buildEditForm(bool isMobile, User user) {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 0, vertical: 32),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 28),
            child: Card(
              elevation: 8,
              color: Colors.white.withOpacity(0.93),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Profile Picture
                      Center(
                        child: InkWell(
                          onTap: _pickProfilePicture,
                          borderRadius: BorderRadius.circular(60),
                          child: CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.deepPurple.shade50,
                            backgroundImage: _pickedProfilePicBytes != null
                                ? MemoryImage(_pickedProfilePicBytes!)
                                : NetworkImage(user.getProfilePicture()),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(AppLocalizations.of(context)!.editProfileChangePhoto, style: const TextStyle(color: Colors.black54)),
                      const SizedBox(height: 25),

                      // Form fields
                      _buildTextField(_firstNameController, AppLocalizations.of(context)!.editProfileFirstName, Icons.person, required: true),
                      const SizedBox(height: 14),
                      _buildTextField(_lastNameController, AppLocalizations.of(context)!.editProfileLastName, Icons.person_outline, required: true),
                      const SizedBox(height: 14),
                      _buildTextField(_phoneNumberController, AppLocalizations.of(context)!.editProfilePhoneNumber, Icons.phone),
                      const SizedBox(height: 14),
                      _buildTextField(_linkedinController, AppLocalizations.of(context)!.editProfileLinkedIn, Icons.link),
                      const SizedBox(height: 14),
                      _buildTextField(_biographyController, AppLocalizations.of(context)!.editProfileBiography, Icons.description, maxLines: 4),
                      const SizedBox(height: 18),

                      // Configuration section following SolidCV patterns
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppLocalizations.of(context)!.settings,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF7B3FE4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      // Weekly recommendations email switch
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SwitchListTile(
                          title: Text(
                            AppLocalizations.of(context)!.receiveWeeklyEmails,
                            style: const TextStyle(fontSize: 16),
                          ),
                          subtitle: Text(
                            AppLocalizations.of(context)!.editProfileEmailSubtitle,
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          value: _receiveWeeklyRecommendationEmails,
                          onChanged: (val) {
                            setState(() {
                              _receiveWeeklyRecommendationEmails = val;
                            });
                          },
                          activeColor: const Color(0xFF7B3FE4),
                        ),
                      ),
                      const SizedBox(height: 14),
                      
                      // Language selector
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.language, color: Color(0xFF7B3FE4)),
                          title: Text(
                            AppLocalizations.of(context)!.changeLanguage,
                            style: const TextStyle(fontSize: 16),
                          ),
                          subtitle: Text(
                            _getLanguageDisplayName(context),
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _showLanguageSelectionDialog(context),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Save button following SolidCV styling patterns
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _submit,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                                )
                              : const Icon(Icons.save),
                          label: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(_isSaving ? AppLocalizations.of(context)!.editProfileSaving : AppLocalizations.of(context)!.editProfileSave),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7B3FE4),
                            foregroundColor: Colors.white,
                            elevation: 2,
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {bool required = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: _inputDecoration(label, icon: icon),
      validator: (value) {
        if (required && (value == null || value.trim().isEmpty)) {
          return AppLocalizations.of(context)!.editProfileRequired;
        }
        return null;
      },
    );
  }
}
