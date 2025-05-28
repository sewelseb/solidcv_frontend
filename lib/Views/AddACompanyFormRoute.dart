import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';
import 'package:solid_cv/business_layer/CompanyBll.dart';
import 'package:solid_cv/business_layer/ICompanyBll.dart';
import 'package:solid_cv/models/Company.dart';

class AddACompanyFormRoute extends StatefulWidget {
  const AddACompanyFormRoute({super.key});

  @override
  State<AddACompanyFormRoute> createState() => _AddACompanyFormRouteState();
}

class _AddACompanyFormRouteState extends State<AddACompanyFormRoute> {
  final ICompanyBll _companyBll = CompanyBll();
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _addressNumberController = TextEditingController();
  final _addressStreetController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  XFile? _pickedImage;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _companyNameController.dispose();
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
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      setState(() => _pickedImage = image);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      var company = Company(
        id: null,
        name: _companyNameController.text,
        addressNumber: _addressNumberController.text,
        addressStreet: _addressStreetController.text,
        addressCity: _cityController.text,
        addressZipCode: _zipCodeController.text,
        addressCountry: _countryController.text,
        phoneNumber: _phoneNumberController.text,
        email: _emailController.text,
      );

      await _companyBll.createCompany(company, _pickedImage);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Company created!')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
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
      fillColor: Colors.grey.shade100,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 650;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a Company'),
        elevation: 1,
        backgroundColor: const Color(0xFF7B3FE4),
      ),
      bottomNavigationBar: const MainBottomNavigationBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 700),
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 18),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
                            backgroundImage: _pickedImage != null
                                ? FileImage(File(_pickedImage!.path))
                                : null,
                            child: _pickedImage == null
                                ? Icon(Icons.camera_alt_outlined, size: 38, color: Colors.deepPurple)
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Choose a company logo or image",
                        style: TextStyle(color: Colors.black54, fontSize: 15),
                      ),
                      const SizedBox(height: 30),
                      // Responsive grid
                      isWide
                          ? Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      _buildTextField(_companyNameController, "Company Name", Icons.business, required: true),
                                      const SizedBox(height: 18),
                                      _buildTextField(_addressNumberController, "Address number", Icons.location_on),
                                      const SizedBox(height: 18),
                                      _buildTextField(_addressStreetController, "Address street", Icons.location_on),
                                      const SizedBox(height: 18),
                                      _buildTextField(_cityController, "City", Icons.location_city),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: Column(
                                    children: [
                                      _buildTextField(_zipCodeController, "Zip code", Icons.local_post_office),
                                      const SizedBox(height: 18),
                                      _buildTextField(_countryController, "Country", Icons.flag),
                                      const SizedBox(height: 18),
                                      _buildTextField(_phoneNumberController, "Phone Number", Icons.phone),
                                      const SizedBox(height: 18),
                                      _buildTextField(_emailController, "Email", Icons.email, required: true, isEmail: true),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                _buildTextField(_companyNameController, "Company Name", Icons.business, required: true),
                                const SizedBox(height: 18),
                                _buildTextField(_addressNumberController, "Address number", Icons.location_on),
                                const SizedBox(height: 18),
                                _buildTextField(_addressStreetController, "Address street", Icons.location_on),
                                const SizedBox(height: 18),
                                _buildTextField(_cityController, "City", Icons.location_city),
                                const SizedBox(height: 18),
                                _buildTextField(_zipCodeController, "Zip code", Icons.local_post_office),
                                const SizedBox(height: 18),
                                _buildTextField(_countryController, "Country", Icons.flag),
                                const SizedBox(height: 18),
                                _buildTextField(_phoneNumberController, "Phone Number", Icons.phone),
                                const SizedBox(height: 18),
                                _buildTextField(_emailController, "Email", Icons.email, required: false, isEmail: true),
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
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                                )
                              : const Icon(Icons.save),
                          label: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6.0),
                            child: Text(_isSubmitting ? "Submitting..." : "Create Company"),
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
      if (required && (value == null || value.trim().isEmpty)) {
        return 'Required';
      }
      if (isEmail && value != null && value.trim().isNotEmpty) {
        final emailRegex = RegExp(r"^[\w\.-]+@[\w\.-]+\.\w{2,}$");
        if (!emailRegex.hasMatch(value.trim())) {
          return 'Invalid email';
        }
      }
      return null;
    },
  );
}
}
