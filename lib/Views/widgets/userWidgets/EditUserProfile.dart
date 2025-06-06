import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/models/User.dart';

class EditProfileRoute extends StatefulWidget {
  final User user;
  const EditProfileRoute({super.key, required this.user});

  @override
  State<EditProfileRoute> createState() => _EditProfileRouteState();
}

class _EditProfileRouteState extends State<EditProfileRoute> {
  final IUserBLL _userBll = UserBll();

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _biographyController;
  late TextEditingController _linkedinController;
  final ScrollController _scrollController = ScrollController();

  Uint8List? _pickedProfilePicBytes;
  String? _pickedProfilePicExt;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _firstNameController =
        TextEditingController(text: widget.user.firstName ?? "");
    _lastNameController =
        TextEditingController(text: widget.user.lastName ?? "");
    _phoneNumberController =
        TextEditingController(text: widget.user.phoneNumber ?? "");
    _biographyController =
        TextEditingController(text: widget.user.biography ?? "");
    _linkedinController =
        TextEditingController(text: widget.user.linkedin ?? "");
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
      );
      await _userBll.updateUser(
        updatedUser,
        _pickedProfilePicBytes,
        _pickedProfilePicExt,
        updatedUser.id!,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated!")),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: Color(0xFF7B3FE4)) : null,
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
        title:
            const Text('Edit Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF7B3FE4),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 1,
      ),
      bottomNavigationBar: const MainBottomNavigationBar(),
      backgroundColor: Colors.white,
      body: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding:
              EdgeInsets.symmetric(horizontal: isMobile ? 10 : 0, vertical: 32),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 28),
              child: Card(
                elevation: 8,
                color: Colors.white.withOpacity(0.93),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
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
                                  : NetworkImage(
                                      widget.user.getProfilePicture()),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text("Change profile photo",
                            style: TextStyle(color: Colors.black54)),
                        const SizedBox(height: 25),

                        // Form fields
                        _buildTextField(
                            _firstNameController, "First Name", Icons.person,
                            required: true),
                        const SizedBox(height: 14),
                        _buildTextField(_lastNameController, "Last Name",
                            Icons.person_outline,
                            required: true),
                        const SizedBox(height: 14),
                        _buildTextField(_phoneNumberController, "Phone Number",
                            Icons.phone),
                        const SizedBox(height: 14),
                        _buildTextField(
                            _linkedinController, "LinkedIn", Icons.link),
                        const SizedBox(height: 14),
                        _buildTextField(_biographyController, "Biography",
                            Icons.description,
                            maxLines: 4),
                        const SizedBox(height: 18),

                        // Save button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _isSaving ? null : _submit,
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 3, color: Colors.white),
                                  )
                                : const Icon(Icons.save),
                            label: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                  _isSaving ? "Saving..." : "Save Profile"),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7B3FE4),
                              foregroundColor: Colors.white,
                              elevation: 2,
                              textStyle: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
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
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool required = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: _inputDecoration(label, icon: icon),
      validator: (value) {
        if (required && (value == null || value.trim().isEmpty)) {
          return 'Required';
        }
        return null;
      },
    );
  }
}
