import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:solid_cv/Views/utils/RegexValidator.dart';
import 'package:solid_cv/business_layer/EducationInstitutionBll.dart';
import 'package:solid_cv/business_layer/IEducationInstitutionBll.dart';
import 'package:solid_cv/models/EducationInstitution.dart';

class AddanEducationInstitutionFormRoute extends StatefulWidget {
  const AddanEducationInstitutionFormRoute({super.key});

  @override
  State<AddanEducationInstitutionFormRoute> createState() =>
      _AddanEducationInstitutionFormRouteState();
}

class _AddanEducationInstitutionFormRouteState
    extends State<AddanEducationInstitutionFormRoute> {
  final IEducationInstitutionBll _educationInstitutionBll =
      EducationInstitutionBll();
  final _formKey = GlobalKey<FormState>();
  final _educationInstitutionNameController = TextEditingController();
  final _addressNumberController = TextEditingController();
  final _addressStreetController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  Uint8List? _pickedImageBytes;
  String? _pickedImageExt;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _educationInstitutionNameController.dispose();
    _addressNumberController.dispose();
    _addressStreetController.dispose();
    _cityController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
      allowMultiple: false,
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _pickedImageBytes = result.files.single.bytes!;
        _pickedImageExt = result.files.single.extension;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      var educationInstitution = EducationInstitution(
        name: _educationInstitutionNameController.text,
        addressNumber: _addressNumberController.text,
        addressStreet: _addressStreetController.text,
        addressCity: _cityController.text,
        addressZipCode: _zipCodeController.text,
        addressCountry: _countryController.text,
        phoneNumber: _phoneNumberController.text,
        email: _emailController.text,
      );
      _educationInstitutionBll.addEducationInstitution(
          educationInstitution, _pickedImageBytes, _pickedImageExt);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.educationInstitutionAdded)),
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/my-organisation',
        (route) => false,
        arguments: {'tabIndex': 1},
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool required = false,
    bool isEmail = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      decoration: _inputDecoration(label, icon: icon),
      validator: (value) {
        final trimmedValue = value?.trim() ?? '';

        if (required && trimmedValue.isEmpty) {
          return AppLocalizations.of(context)!.required;
        }
        if (isEmail &&
            trimmedValue.isNotEmpty &&
            !RegexValidator.isEmailValid(trimmedValue)) {
          return AppLocalizations.of(context)!.invalidEmail;
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 650;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.addAnEducationInstitution),
        elevation: 1,
        backgroundColor: const Color(0xFF7B3FE4),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 700),
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 18),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Profile Picture Picker
                      Center(
                        child: InkWell(
                          onTap: _pickImage,
                          borderRadius: BorderRadius.circular(50),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.deepPurple.shade50,
                            backgroundImage: _pickedImageBytes != null
                                ? MemoryImage(_pickedImageBytes!)
                                : null,
                            child: _pickedImageBytes == null
                                ? const Icon(Icons.camera_alt_outlined,
                                    size: 38, color: Colors.deepPurple)
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppLocalizations.of(context)!.chooseLogoOrImage,
                        style: const TextStyle(color: Colors.black54, fontSize: 15),
                      ),
                      const SizedBox(height: 30),
                      isWide
                          ? Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      _buildTextField(
                                          _educationInstitutionNameController,
                                          AppLocalizations.of(context)!.institutionName,
                                          Icons.account_balance,
                                          required: true),
                                      const SizedBox(height: 18),
                                      _buildTextField(_addressNumberController,
                                          AppLocalizations.of(context)!.addressNumber, Icons.location_on),
                                      const SizedBox(height: 18),
                                      _buildTextField(_addressStreetController,
                                          AppLocalizations.of(context)!.addressStreet, Icons.location_on),
                                      const SizedBox(height: 18),
                                      _buildTextField(_cityController, AppLocalizations.of(context)!.city,
                                          Icons.location_city),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: Column(
                                    children: [
                                      _buildTextField(_zipCodeController,
                                          AppLocalizations.of(context)!.zipCode, Icons.local_post_office),
                                      const SizedBox(height: 18),
                                      _buildTextField(_countryController,
                                          AppLocalizations.of(context)!.country, Icons.flag),
                                      const SizedBox(height: 18),
                                      _buildTextField(_phoneNumberController,
                                          AppLocalizations.of(context)!.phoneNumber, Icons.phone),
                                      const SizedBox(height: 18),
                                      _buildTextField(_emailController, AppLocalizations.of(context)!.email,
                                          Icons.email,
                                          isEmail: true), // not required!
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                _buildTextField(
                                    _educationInstitutionNameController,
                                    AppLocalizations.of(context)!.institutionName,
                                    Icons.account_balance,
                                    required: true),
                                const SizedBox(height: 18),
                                _buildTextField(_addressNumberController,
                                    AppLocalizations.of(context)!.addressNumber, Icons.location_on),
                                const SizedBox(height: 18),
                                _buildTextField(_addressStreetController,
                                    AppLocalizations.of(context)!.addressStreet, Icons.location_on),
                                const SizedBox(height: 18),
                                _buildTextField(_cityController, AppLocalizations.of(context)!.city,
                                    Icons.location_city),
                                const SizedBox(height: 18),
                                _buildTextField(_zipCodeController, AppLocalizations.of(context)!.zipCode,
                                    Icons.local_post_office),
                                const SizedBox(height: 18),
                                _buildTextField(
                                    _countryController, AppLocalizations.of(context)!.country, Icons.flag),
                                const SizedBox(height: 18),
                                _buildTextField(_phoneNumberController,
                                    AppLocalizations.of(context)!.phoneNumber, Icons.phone),
                                const SizedBox(height: 18),
                                _buildTextField(
                                    _emailController, AppLocalizations.of(context)!.email, Icons.email,
                                    isEmail: true), // not required!
                              ],
                            ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _isSubmitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7B3FE4),
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 3, color: Colors.white),
                                )
                              : const Icon(Icons.save),
                          label: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 6.0),
                            child: Text(_isSubmitting
                                ? AppLocalizations.of(context)!.submitting
                                : AppLocalizations.of(context)!.addEducationInstitution),
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
}
