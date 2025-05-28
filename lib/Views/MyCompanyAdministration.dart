import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:solid_cv/Views/Parameters/CompanyParameter.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';
import 'package:solid_cv/business_layer/CompanyBll.dart';
import 'package:solid_cv/business_layer/ICompanyBll.dart';
import 'package:solid_cv/models/Company.dart';

class MyCompanyAdministration extends StatefulWidget {
  const MyCompanyAdministration({super.key});

  @override
  State<MyCompanyAdministration> createState() =>
      _MyCompanyAdministrationState();
}

class _MyCompanyAdministrationState extends State<MyCompanyAdministration> {
  final ICompanyBll _companyBll = CompanyBll();
  Future<Company>? _companyFuture;
  Company? _company;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressNumberController = TextEditingController();
  final _addressStreetController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _ethereumAddressController = TextEditingController();
  final _ethereumPrivateKeyController = TextEditingController();
  final _passwordController = TextEditingController();
  XFile? _pickedImage;

  bool _isSubmitting = false;

  final Color _primaryColor = const Color(0xFF7B3FE4);
  final Color _gradientStart = const Color(0xFF7B3FE4);
  final Color _gradientEnd = const Color(0xFFB57AED);
  final Color _glassBackground = Colors.white.withOpacity(0.85);
  final Color _shadowColor = Colors.deepPurple.shade50;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_companyFuture == null) {
      final CompanyParameter args =
          ModalRoute.of(context)!.settings.arguments as CompanyParameter;
      _companyFuture = _companyBll.getCompany(args.id).then((company) {
        _company = company;
        _nameController.text = company.name ?? '';
        _addressNumberController.text = company.addressNumber ?? '';
        _addressStreetController.text = company.addressStreet ?? '';
        _cityController.text = company.addressCity ?? '';
        _zipCodeController.text = company.addressZipCode ?? '';
        _countryController.text = company.addressCountry ?? '';
        _phoneNumberController.text = company.phoneNumber ?? '';
        _emailController.text = company.email ?? '';
        _ethereumAddressController.text = company.ethereumAddress ?? '';
        return company;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressNumberController.dispose();
    _addressStreetController.dispose();
    _cityController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _ethereumAddressController.dispose();
    _ethereumPrivateKeyController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      setState(() => _pickedImage = image);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final updatedCompany = Company(
        id: _company?.id,
        name: _nameController.text,
        addressNumber: _addressNumberController.text,
        addressStreet: _addressStreetController.text,
        addressCity: _cityController.text,
        addressZipCode: _zipCodeController.text,
        addressCountry: _countryController.text,
        phoneNumber: _phoneNumberController.text,
        email: _emailController.text,
        ethereumAddress: _ethereumAddressController.text,
      );

      await _companyBll.updateCompany(
          updatedCompany, _pickedImage, updatedCompany.id!);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Company updated!')),
      );
      setState(() {
        _companyFuture = _companyBll.getCompany(updatedCompany.id!);
        _pickedImage = null;
      });
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
      prefixIcon: icon != null ? Icon(icon, color: _primaryColor) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _primaryColor, width: 2.0),
        borderRadius: BorderRadius.circular(10.0),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      labelStyle: GoogleFonts.inter(color: Colors.black87),
      hintStyle: GoogleFonts.inter(color: Colors.black26),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 950;
    final isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Company Administration',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: _primaryColor,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      bottomNavigationBar: const MainBottomNavigationBar(),
      backgroundColor: Colors.white,
      body: FutureBuilder<Company>(
        future: _companyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          final company = snapshot.data!;

          return Center(
            child: SingleChildScrollView(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1050),
                padding: EdgeInsets.symmetric(
                    vertical: isMobile ? 24 : 36,
                    horizontal: isMobile ? 10 : 32),
                child: Card(
                  elevation: 7,
                  color: _glassBackground,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  child: Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Center(
                            child: InkWell(
                              onTap: _pickImage,
                              borderRadius: BorderRadius.circular(60),
                              child: CircleAvatar(
                                radius: 55,
                                backgroundColor: Colors.deepPurple.shade50,
                                backgroundImage: _pickedImage != null
                                    ? FileImage(File(_pickedImage!.path))
                                    : NetworkImage(company.getProfilePicture()),
                                child: (_pickedImage == null &&
                                        (company.profilePicture == null ||
                                            company.profilePicture!.isEmpty))
                                    ? const Icon(Icons.camera_alt_outlined,
                                        size: 38, color: Colors.deepPurple)
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Change company logo/image",
                            style:
                                TextStyle(color: Colors.black54, fontSize: 15),
                          ),
                          const SizedBox(height: 30),
                          isWide
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: _buildMainFields()),
                                    const SizedBox(width: 30),
                                    Expanded(child: _buildOtherFields()),
                                  ],
                                )
                              : Column(
                                  children: [
                                    _buildMainFields(),
                                    const SizedBox(height: 20),
                                    _buildOtherFields(),
                                  ],
                                ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: _isSubmitting ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryColor,
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
                                    ? "Submitting..."
                                    : "Update Company"),
                              ),
                            ),
                          ),
                          const SizedBox(height: 36),
                          _buildSectionCard(
                            isMobile: isMobile,
                            title: "Ethereum Wallet",
                            icon: Icons.account_balance_wallet,
                            content: Column(
                              children: [
                                _buildTextField(
                                    _ethereumAddressController,
                                    "Ethereum Address",
                                    Icons.account_balance_wallet),
                                const SizedBox(height: 16),
                                _buildTextField(_ethereumPrivateKeyController,
                                    "Ethereum Private key", Icons.lock,
                                    obscure: true),
                                const SizedBox(height: 10),
                                Text(
                                  'This is the Ethereum address that will be used to mint tokens for your employees.\nWe don\'t store your private key on our server, it is stored on your device so make sure to keep it safe.',
                                  style: GoogleFonts.inter(
                                      color: Colors.black54,
                                      fontSize: 13,
                                      height: 1.2),
                                ),
                                const SizedBox(height: 10),
                                _buildTextField(
                                    _passwordController,
                                    "Password (encrypts private key)",
                                    Icons.password,
                                    obscure: true),
                                const SizedBox(height: 8),
                                Text(
                                  'This password will be used to encrypt your private key. Make sure to remember it. (There is no way to recover it)',
                                  style: GoogleFonts.inter(
                                      color: Colors.black54, fontSize: 12),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      await _companyBll.setEthereumAddress(
                                        company,
                                        _ethereumAddressController.text,
                                        _ethereumPrivateKeyController.text,
                                        _passwordController.text,
                                      );
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'Ethereum address saved!')));
                                      setState(() {});
                                    },
                                    icon: const Icon(Icons.save),
                                    label: const Text('Save Ethereum'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _primaryColor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildSectionCard(
                            isMobile: isMobile,
                            title: "Employees",
                            icon: Icons.people,
                            content: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  var args = CompanyParameter(id: company.id!);
                                  Navigator.pushNamed(
                                      context, '/company/add-an-employee',
                                      arguments: args);
                                },
                                icon: const Icon(Icons.person_add_alt_1),
                                label: const Text('+ Add Employee'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainFields() {
    return Column(
      children: [
        _buildTextField(_nameController, "Company Name", Icons.business,
            required: true),
        const SizedBox(height: 18),
        _buildTextField(
            _addressNumberController, "Address number", Icons.location_on),
        const SizedBox(height: 18),
        _buildTextField(
            _addressStreetController, "Address street", Icons.location_on),
        const SizedBox(height: 18),
        _buildTextField(_cityController, "City", Icons.location_city),
      ],
    );
  }

  Widget _buildOtherFields() {
    return Column(
      children: [
        _buildTextField(
            _zipCodeController, "Zip code", Icons.local_post_office),
        const SizedBox(height: 18),
        _buildTextField(_countryController, "Country", Icons.flag),
        const SizedBox(height: 18),
        _buildTextField(_phoneNumberController, "Phone Number", Icons.phone),
        const SizedBox(height: 18),
        _buildTextField(_emailController, "Email", Icons.email, isEmail: true),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool required = false,
    bool isEmail = false,
    bool obscure = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      obscureText: obscure,
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

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget content,
    required bool isMobile,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      width: double.infinity,
      padding: const EdgeInsets.all(22.0),
      decoration: BoxDecoration(
        color: _glassBackground,
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(color: _gradientStart.withOpacity(0.18), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: _shadowColor,
            blurRadius: 14,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [_gradientStart, _gradientEnd],
                  ),
                ),
                padding: const EdgeInsets.all(8),
                child:
                    Icon(icon, color: Colors.white, size: isMobile ? 22 : 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: isMobile ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }
}
