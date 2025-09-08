import 'dart:async';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solid_cv/Views/Parameters/CompanyParameter.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';
import 'package:solid_cv/business_layer/CompanyBll.dart';
import 'package:solid_cv/business_layer/ICompanyBll.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/models/Company.dart';
import 'package:solid_cv/models/SearchTherms.dart';
import 'package:solid_cv/models/User.dart';

class MyCompanyAdministration extends StatefulWidget {
  const MyCompanyAdministration({super.key});

  @override
  State<MyCompanyAdministration> createState() =>
      _MyCompanyAdministrationState();
}

class _MyCompanyAdministrationState extends State<MyCompanyAdministration> {
  final ICompanyBll _companyBll = CompanyBll();
  final IUserBLL _userBll = UserBll();
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
  final _adminEmailController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Uint8List? _pickedImageBytes;
  String? _pickedImageExt;

  bool _isSubmitting = false;
  bool _isAddingAdmin = false;
  bool _isSearching = false;
  List<User> _searchResults = [];
  Timer? _searchTimer;

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
    _adminEmailController.dispose();
    _scrollController.dispose();
    _searchTimer?.cancel();
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

      await _companyBll.updateCompany(updatedCompany, _pickedImageBytes,
          _pickedImageExt, updatedCompany.id!);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.companyUpdated)),
      );
      setState(() {
        _companyFuture = _companyBll.getCompany(updatedCompany.id!);
        _pickedImageBytes = null;
        _pickedImageExt = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _addAdministrator(Company company) async {
    final email = _adminEmailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an email address')),
      );
      return;
    }

    // Basic email validation
    final emailRegex = RegExp(r"^[\w\.-]+@[\w\.-]+\.\w{2,}$");
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    setState(() => _isAddingAdmin = true);

    try {
      //await _companyBll.addCompanyAdministrator(company.id!, );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Administrator $email added successfully')),
      );

      _adminEmailController.clear();

      // Refresh the company data to update the administrators list
      setState(() {
        _companyFuture = _companyBll.getCompany(company.id!);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding administrator: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isAddingAdmin = false);
      }
    }
  }

  Future<void> _removeAdministrator(User admin, Company company) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Administrator'),
        content: Text(
          'Are you sure you want to remove ${admin.getEasyName() ?? admin.email} as an administrator?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _companyBll.removeCompanyAdministrator(company.id!, admin.id!);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${admin.getEasyName() ?? admin.email} removed as administrator')),
      );

      // Refresh the company data to update the administrators list
      setState(() {
        _companyFuture = _companyBll.getCompany(company.id!);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing administrator: $e')),
      );
    }
  }

  void _searchUsers(String query) {
    // Cancel previous timer if it exists
    _searchTimer?.cancel();
    
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    // Debounce search to avoid too many API calls
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      _performUserSearch(query.trim());
    });
  }

  Future<void> _performUserSearch(String query) async {
    setState(() => _isSearching = true);

    try {
      // Call your user search API - you'll need to implement this in your UserBLL
      var searcTherm = SearchTherms();
      searcTherm.term = query;
      final results = await _userBll.searchUsers(searcTherm);
      
      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching users: $e')),
      );
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
          AppLocalizations.of(context)!.companyAdministration,
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
            return Center(child: Text('${AppLocalizations.of(context)!.error}: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text(AppLocalizations.of(context)!.noDataAvailable));
          }

          final company = snapshot.data!;

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
                                      backgroundColor:
                                          Colors.deepPurple.shade50,
                                      backgroundImage: _pickedImageBytes != null
                                          ? MemoryImage(_pickedImageBytes!)
                                          : NetworkImage(
                                              company.getProfilePicture()),
                                    )),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                AppLocalizations.of(context)!.changeCompanyLogo,
                                style: const TextStyle(
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
                                        ? AppLocalizations.of(context)!.submitting
                                        : AppLocalizations.of(context)!.updateCompany),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 36),
                              _buildSectionCard(
                                isMobile: isMobile,
                                title: AppLocalizations.of(context)!.baseBlockchainWallet,
                                icon: Icons.account_balance_wallet,
                                content: Column(
                                  children: [
                                    _buildTextField(
                                        _ethereumAddressController,
                                        AppLocalizations.of(context)!.baseBlockchainAddress,
                                        Icons.account_balance_wallet),
                                    const SizedBox(height: 16),
                                    _buildTextField(
                                        _ethereumPrivateKeyController,
                                        AppLocalizations.of(context)!.baseBlockchainPrivateKey,
                                        Icons.lock,
                                        obscure: true),
                                    const SizedBox(height: 10),
                                    Text(
                                      AppLocalizations.of(context)!.blockchainWalletDescription,
                                      style: GoogleFonts.inter(
                                          color: Colors.black54,
                                          fontSize: 13,
                                          height: 1.2),
                                    ),
                                    const SizedBox(height: 10),
                                    _buildTextField(
                                        _passwordController,
                                        AppLocalizations.of(context)!.passwordEncryptsPrivateKey,
                                        Icons.password,
                                        obscure: true),
                                    const SizedBox(height: 8),
                                    Text(
                                      AppLocalizations.of(context)!.passwordRecoveryWarning,
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
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    AppLocalizations.of(context)!.baseBlockchainAddressSaved)),
                                          );
                                          setState(() {
                                            _companyFuture = _companyBll
                                                .getCompany(company.id!);
                                          });
                                        },
                                        icon: const Icon(Icons.save),
                                        label: Text(AppLocalizations.of(context)!.saveEthereum),
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
                                title: AppLocalizations.of(context)!.jobOffers,
                                icon: Icons.work,
                                content: Column(
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.pushNamed(context,
                                              '/company/manage-job-offers',
                                              arguments: company.id!.toString());
                                        },
                                        icon: const Icon(Icons.business_center),
                                        label: Text(AppLocalizations.of(context)!.manageJobOffers),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _primaryColor,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                              _buildSectionCard(
                                isMobile: isMobile,
                                title: AppLocalizations.of(context)!.companyAdministrators,
                                icon: Icons.admin_panel_settings,
                                content: Column(
                                  children: [
                                    // Current administrators list
                                    FutureBuilder<List<User>>(
                                      future: _companyBll.getCompanyAdministrators(company.id!),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: Center(child: CircularProgressIndicator()),
                                          );
                                        } else if (snapshot.hasError) {
                                          return Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Text(
                                              'Error loading administrators: ${snapshot.error}',
                                              style: const TextStyle(color: Colors.redAccent),
                                            ),
                                          );
                                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                          return const Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: Text(
                                              'No administrators found. Add the first administrator below.',
                                              style: TextStyle(
                                                color: Colors.orange,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          );
                                        }

                                        final administrators = snapshot.data!;
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Current Administrators (${administrators.length})',
                                              style: GoogleFonts.inter(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            ...administrators.map((admin) => _buildAdministratorTile(admin, company)).toList(),
                                            const SizedBox(height: 16),
                                          ],
                                        );
                                      },
                                    ),
                                    
                                    // Add administrator section
                                    Container(
                                      padding: const EdgeInsets.all(16.0),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.grey.shade200),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.person_add, color: _primaryColor, size: 20),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Add New Administrator',
                                                style: GoogleFonts.inter(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          
                                          // Search bar
                                          TextField(
                                            controller: _adminEmailController,
                                            decoration: InputDecoration(
                                              hintText: 'Search users by name or email...',
                                              prefixIcon: Icon(Icons.search, color: _primaryColor),
                                              suffixIcon: _adminEmailController.text.isNotEmpty
                                                  ? IconButton(
                                                      icon: const Icon(Icons.clear),
                                                      onPressed: () {
                                                        setState(() {
                                                          _adminEmailController.clear();
                                                          _searchResults = [];
                                                          _isSearching = false;
                                                        });
                                                      },
                                                    )
                                                  : null,
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: _primaryColor, width: 2),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              contentPadding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 14,
                                              ),
                                            ),
                                            onChanged: (value) => _searchUsers(value),
                                          ),
                                          
                                          // Search results
                                          if (_isSearching)
                                            const Padding(
                                              padding: EdgeInsets.all(16.0),
                                              child: Center(
                                                child: CircularProgressIndicator(),
                                              ),
                                            )
                                          else if (_searchResults.isNotEmpty) ...[
                                            const SizedBox(height: 12),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: Colors.grey.shade300),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.all(12.0),
                                                    child: Text(
                                                      'Search Results (${_searchResults.length})',
                                                      style: GoogleFonts.inter(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w600,
                                                        color: Colors.grey.shade700,
                                                      ),
                                                    ),
                                                  ),
                                                  const Divider(height: 1),
                                                  ListView.separated(
                                                    shrinkWrap: true,
                                                    physics: const NeverScrollableScrollPhysics(),
                                                    itemCount: _searchResults.length,
                                                    separatorBuilder: (_, __) => const Divider(height: 1),
                                                    itemBuilder: (context, index) {
                                                      final user = _searchResults[index];
                                                      return _buildUserSearchResult(user, company);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ] else if (_adminEmailController.text.isNotEmpty && !_isSearching) ...[
                                            const SizedBox(height: 12),
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.orange.shade50,
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: Colors.orange.shade200),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.info_outline, color: Colors.orange.shade600, size: 20),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      'No users found matching your search.',
                                                      style: GoogleFonts.inter(
                                                        fontSize: 13,
                                                        color: Colors.orange.shade700,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                          
                                          const SizedBox(height: 8),
                                          Text(
                                            'Search for existing users to add as company administrators.',
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                              height: 1.3,
                                            ),
                                          ),
                                        ],
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
                                content: (company.ethereumAddress == null ||
                                        company.ethereumAddress!.isEmpty)
                                    ? const Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Text(
                                          "Add your company's Base Blochchain address to manage employees.",
                                          style: TextStyle(
                                              color: Colors.redAccent,
                                              fontStyle: FontStyle.italic),
                                        ),
                                      )
                                    : SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            var args = CompanyParameter(
                                                id: company.id!);
                                            Navigator.pushNamed(context,
                                                '/company/add-an-employee',
                                                arguments: args);
                                          },
                                          icon: const Icon(
                                              Icons.person_add_alt_1),
                                          label: const Text('+ Add Employee'),
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
        _buildTextField(_nameController, AppLocalizations.of(context)!.companyName, Icons.business,
            required: true),
        const SizedBox(height: 18),
        _buildTextField(
            _addressNumberController, AppLocalizations.of(context)!.addressNumber, Icons.location_on),
        const SizedBox(height: 18),
        _buildTextField(
            _addressStreetController, AppLocalizations.of(context)!.addressStreet, Icons.location_on),
        const SizedBox(height: 18),
        _buildTextField(_cityController, AppLocalizations.of(context)!.city, Icons.location_city),
      ],
    );
  }

  Widget _buildOtherFields() {
    return Column(
      children: [
        _buildTextField(
            _zipCodeController, AppLocalizations.of(context)!.zipCode, Icons.local_post_office),
        const SizedBox(height: 18),
        _buildTextField(_countryController, AppLocalizations.of(context)!.country, Icons.flag),
        const SizedBox(height: 18),
        _buildTextField(_phoneNumberController, AppLocalizations.of(context)!.phoneNumber, Icons.phone),
        const SizedBox(height: 18),
        _buildTextField(_emailController, AppLocalizations.of(context)!.email, Icons.email, isEmail: true),
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
          return AppLocalizations.of(context)!.required;
        }
        if (isEmail && value != null && value.trim().isNotEmpty) {
          final emailRegex = RegExp(r"^[\w\.-]+@[\w\.-]+\.\w{2,}$");
          if (!emailRegex.hasMatch(value.trim())) {
            return AppLocalizations.of(context)!.invalidEmail;
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

  Widget _buildAdministratorTile(User admin, Company company) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: _primaryColor,
            backgroundImage: admin.getProfilePicture().isNotEmpty
                ? NetworkImage(admin.getProfilePicture())
                : null,
            child: admin.getProfilePicture().isEmpty
                ? Text(
                    (admin.getEasyName() ?? 'A').substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  admin.getEasyName() ?? 'Unknown',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  admin.email ?? '',
                  style: GoogleFonts.inter(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _removeAdministrator(admin, company),
            icon: const Icon(Icons.remove_circle_outline),
            color: Colors.redAccent,
            tooltip: 'Remove Administrator',
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserSearchResult(User user, Company company) {
    final isCurrentAdmin = false;
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: _primaryColor,
        backgroundImage: user.getProfilePicture().isNotEmpty
            ? NetworkImage(user.getProfilePicture())
            : null,
        child: user.getProfilePicture().isEmpty
            ? Text(
                (user.getEasyName() ?? 'U').substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              )
            : null,
      ),
      title: Text(
        user.getEasyName() ?? 'Unknown',
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user.email ?? '',
            style: GoogleFonts.inter(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
      trailing: SizedBox(
              width: 80,
              height: 32,
              child: ElevatedButton(
                onPressed: _isAddingAdmin ? null : () => _addUserAsAdministrator(user, company),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: _isAddingAdmin
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Add',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
    );
  }

  Future<void> _addUserAsAdministrator(User user, Company company) async {
    setState(() => _isAddingAdmin = true);

    try {
      await _companyBll.addCompanyAdministrator(company.id!, user.id!);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${user.getEasyName() ?? user.email} added as administrator')),
      );
      
      // Clear search and refresh data
      setState(() {
        _adminEmailController.clear();
        _searchResults = [];
        _companyFuture = _companyBll.getCompany(company.id!);
      });
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding administrator: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isAddingAdmin = false);
      }
    }
  }
}
