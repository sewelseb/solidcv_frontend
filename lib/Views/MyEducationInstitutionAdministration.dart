import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solid_cv/Views/Parameters/EducationInstitutionParameter.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';
import 'package:solid_cv/business_layer/EducationInstitutionBll.dart';
import 'package:solid_cv/business_layer/IEducationInstitutionBll.dart';
import 'package:solid_cv/models/EducationInstitution.dart';

class MyEducationInstitutionAdministration extends StatefulWidget {
  const MyEducationInstitutionAdministration({super.key});

  @override
  State<MyEducationInstitutionAdministration> createState() =>
      _MyEducationInstitutionAdministrationState();
}

class _MyEducationInstitutionAdministrationState
    extends State<MyEducationInstitutionAdministration> {
  final IEducationInstitutionBll _educationInstitutionBll =
      EducationInstitutionBll();
  Future<EducationInstitution>? _educationInstitutionFuture;
  EducationInstitution? _educationInstitution;

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
  final ScrollController _scrollController = ScrollController();

  Uint8List? _pickedImageBytes;
  String? _pickedImageExt;
  bool _isSubmitting = false;

  final Color _primaryColor = const Color(0xFF7B3FE4);
  final Color _gradientStart = const Color(0xFF7B3FE4);
  final Color _gradientEnd = const Color(0xFFB57AED);
  final Color _glassBackground = Colors.white.withOpacity(0.85);
  final Color _shadowColor = Colors.deepPurple.shade50;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_educationInstitutionFuture == null) {
      final EducationInstitutionParameter args = ModalRoute.of(context)!
          .settings
          .arguments as EducationInstitutionParameter;
      _educationInstitutionFuture = _educationInstitutionBll
          .getEducationInstitution(args.id)
          .then((educationInstitution) {
        _educationInstitution = educationInstitution;
        _nameController.text = educationInstitution.name ?? '';
        _addressNumberController.text =
            educationInstitution.addressNumber ?? '';
        _addressStreetController.text =
            educationInstitution.addressStreet ?? '';
        _cityController.text = educationInstitution.addressCity ?? '';
        _zipCodeController.text = educationInstitution.addressZipCode ?? '';
        _countryController.text = educationInstitution.addressCountry ?? '';
        _phoneNumberController.text = educationInstitution.phoneNumber ?? '';
        _emailController.text = educationInstitution.email ?? '';
        _ethereumAddressController.text =
            educationInstitution.ethereumAddress ?? '';
        return educationInstitution;
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
    _scrollController.dispose();
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
      final updatedInstitution = EducationInstitution(
        id: _educationInstitution?.id,
        name: _nameController.text,
        addressNumber: _addressNumberController.text,
        addressStreet: _addressStreetController.text,
        addressCity: _cityController.text,
        addressZipCode: _zipCodeController.text,
        addressCountry: _countryController.text,
        phoneNumber: _phoneNumberController.text,
        email: _emailController.text,
        ethereumAddress: _ethereumAddressController.text,
        profilePicture: _educationInstitution?.profilePicture,
      );

      await _educationInstitutionBll.updateEducationInstitution(
          updatedInstitution,
          _pickedImageBytes,
          _pickedImageExt,
          updatedInstitution.id!);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Education Institution updated!')),
      );
      setState(() {
        _educationInstitutionFuture = _educationInstitutionBll
            .getEducationInstitution(updatedInstitution.id!);
        _pickedImageBytes = null;
        _pickedImageExt = null;
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
          'Education Institution Administration',
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
      body: FutureBuilder<EducationInstitution>(
        future: _educationInstitutionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          final institution = snapshot.data!;

          return ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(scrollbars: false),
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              trackVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(
                  vertical: isMobile ? 24 : 36,
                  horizontal: isMobile ? 10 : 32,
                ),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1050),
                    child: Card(
                      elevation: 7,
                      color: _glassBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
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
                                    backgroundImage: _pickedImageBytes != null
                                        ? MemoryImage(_pickedImageBytes!)
                                        : NetworkImage(
                                            institution.getProfilePicture()),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "Change institution logo/image",
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 15),
                              ),
                              const SizedBox(height: 30),
                              isWide
                                  ? Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    elevation: 2,
                                  ),
                                  icon: _isSubmitting
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 3,
                                              color: Colors.white),
                                        )
                                      : const Icon(Icons.save),
                                  label: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6.0),
                                    child: Text(_isSubmitting
                                        ? "Submitting..."
                                        : "Update Institution"),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 36),
                              _buildSectionCard(
                                isMobile: isMobile,
                                title: "Base Blochchain Wallet",
                                icon: Icons.account_balance_wallet,
                                content: Column(
                                  children: [
                                    _buildTextField(
                                        _ethereumAddressController,
                                        "Base Blochchain Address",
                                        Icons.account_balance_wallet),
                                    const SizedBox(height: 16),
                                    _buildTextField(
                                        _ethereumPrivateKeyController,
                                        "Base Blochchain Private key",
                                        Icons.lock,
                                        obscure: true),
                                    const SizedBox(height: 10),
                                    Text(
                                      'This is the Base Blochchain address that will be used to mint certificates or diplomas.\nWe don\'t store your private key on our server, it is stored on your device so make sure to keep it safe.',
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
                                          await _educationInstitutionBll
                                              .setEthereumAddress(
                                            institution,
                                            _ethereumAddressController.text,
                                            _ethereumPrivateKeyController.text,
                                            _passwordController.text,
                                          );
                                          if (!mounted) return;
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Base Blochchain address saved!')),
                                          );
                                          setState(() {
                                            _educationInstitutionFuture =
                                                _educationInstitutionBll
                                                    .getEducationInstitution(
                                                        institution.id!);
                                          });
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
                                title: "Trainees and Students",
                                icon: Icons.people,
                                content: (institution.ethereumAddress == null ||
                                        institution.ethereumAddress!.isEmpty)
                                    ? const Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 18.0),
                                        child: Text(
                                          "Please add an Base Blochchain address before adding certificates.",
                                          style: TextStyle(
                                            color: Colors.redAccent,
                                            fontStyle: FontStyle.italic,
                                            fontSize: 15,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    : SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            var args =
                                                EducationInstitutionParameter(
                                                    id: institution.id!);
                                            Navigator.pushNamed(
                                              context,
                                              '/educationInstitution/add-a-certificate-to-user',
                                              arguments: args,
                                            );
                                          },
                                          icon: const Icon(
                                              Icons.person_add_alt_1),
                                          label: const Text(
                                              '+ Add Certificates to User'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: _primaryColor,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12)),
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
        _buildTextField(_nameController, "Institution Name", Icons.school,
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
