import 'package:cryptography/helpers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:solid_cv/business_layer/ICompanyBll.dart';
import 'package:solid_cv/business_layer/IBlockchainWalletBll.dart';
import 'package:solid_cv/models/User.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSCleanExperience.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSWorkCreatEvent.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSWorkEndedEvent.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSWorkPromotedEvent.dart';
import 'package:solid_cv/models/Company.dart';

class AddEmployeeExperiencePage extends StatefulWidget {
  final User user;
  final int companyId;
  final ICompanyBll companyBll;
  final IBlockchainWalletBll walletBll;
  final Future<Company> company;

  const AddEmployeeExperiencePage({
    super.key,
    required this.user,
    required this.companyId,
    required this.companyBll,
    required this.walletBll,
    required this.company,
  });

  @override
  State<AddEmployeeExperiencePage> createState() =>
      _AddEmployeeExperiencePageState();
}

class _AddEmployeeExperiencePageState extends State<AddEmployeeExperiencePage> {
  // Controllers
  final TextEditingController roleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController newTitleController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController promotionDateController = TextEditingController();
  final TextEditingController createPasswordController =
      TextEditingController();
  final TextEditingController endPasswordController = TextEditingController();
  final TextEditingController promotePasswordController =
      TextEditingController();
  final ScrollController _outerScrollController = ScrollController();

  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _promotionDate;

  String? _selectedStreamEndEventId;
  String? _selectedStreamPromoteEventId;

  late Future<List<CleanExperience>> _workExperiences;

  @override
  void initState() {
    super.initState();
    if (widget.user.ethereumAddress != null &&
        widget.user.ethereumAddress!.isNotEmpty) {
      _workExperiences =
          widget.walletBll.getEventsForUser(widget.user.ethereumAddress!);
    } else {
      _workExperiences = Future.value([]);
    }
  }

  List<DropdownMenuItem<String>> _buildDropdownItems(
      List<CleanExperience> experiences) {
    final filtered = experiences
        .where((e) =>
            e.title != null &&
            e.startDate != null &&
            e.experienceStreamId != null)
        .toList();

    return filtered.map<DropdownMenuItem<String>>((e) {
      final label =
          "${e.companyName ?? 'Company'} - ${e.title ?? 'Title'} (${DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(e.startDate!))})";
      return DropdownMenuItem<String>(
        value: e.experienceStreamId!,
        child: Text(label),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add or Update Experience'),
      ),
      backgroundColor: const Color(0xFFF7F8FC),
      body: Scrollbar(
        controller: _outerScrollController,
        thumbVisibility: true,
        radius: const Radius.circular(16),
        thickness: 7,
        child: SingleChildScrollView(
          controller: _outerScrollController,
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 570),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 6 : 0,
                vertical: isMobile ? 8 : 30,
              ),
              child: Card(
                elevation: 7,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 34,
                      vertical: isMobile ? 24 : 38),
                  child: (widget.user.ethereumAddress == null ||
                          widget.user.ethereumAddress!.isEmpty)
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Text(
                              "Cet utilisateur n'a pas de wallet associé.",
                              style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.redAccent),
                            ),
                          ),
                        )
                      : FutureBuilder<List<CleanExperience>>(
                          future: _workExperiences,
                          builder: (context, snapshot) {
                            final dropdownItems = snapshot.hasData
                                ? _buildDropdownItems(snapshot.data!)
                                : [];

                            return SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Add or Update Experience for "${widget.user.getEasyName() ?? '-'}"',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 21,
                                      color: Color(0xFF7B3FE4),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  // Create Experience Card
                                  Card(
                                    elevation: 0,
                                    color: Colors.grey[50],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    margin: EdgeInsets.zero,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 18, vertical: 22),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "▶️ Create Work Experience",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600),
                                          ),
                                          const SizedBox(height: 14),
                                          _field(roleController, "Role"),
                                          _field(descriptionController,
                                              "Description"),
                                          _dateField(
                                            context,
                                            startDateController,
                                            "Start Date",
                                            _startDate,
                                            (date) {
                                              setState(() {
                                                _startDate = date;
                                                startDateController.text =
                                                    DateFormat('dd/MM/yyyy')
                                                        .format(date);
                                              });
                                            },
                                          ),
                                          _passwordField(
                                              createPasswordController,
                                              "Wallet Password"),
                                          const SizedBox(height: 18),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.deepPurple[300],
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 16),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              onPressed: () async {
                                                bool isSuccess = false;
                                                String message = '';
                                                try {
                                                  final company =
                                                      await widget.company;
                                                  final event =
                                                      WorkCreatedEvent(
                                                    id: randomBytesAsHexString(
                                                        16),
                                                    timestamp: DateTime.now()
                                                        .millisecondsSinceEpoch,
                                                    title: roleController.text,
                                                    startDate: _startDate
                                                            ?.millisecondsSinceEpoch ??
                                                        DateTime.now()
                                                            .millisecondsSinceEpoch,
                                                    description:
                                                        descriptionController
                                                            .text,
                                                    companyName: company.name ??
                                                        'Unknown',
                                                    companyWallet: company
                                                            .ethereumAddress ??
                                                        '',
                                                    location: 'Unknown',
                                                    experienceStreamId:
                                                        randomBytesAsHexString(
                                                            16),
                                                  );
                                                  await widget.companyBll
                                                      .addEmployeeEvents(
                                                          widget.user,
                                                          event,
                                                          widget.companyId,
                                                          createPasswordController
                                                              .text);
                                                  isSuccess = true;
                                                  message =
                                                      "Work experience created!";
                                                } catch (e) {
                                                  isSuccess = false;
                                                  message = "Error: $e";
                                                }
                                                if (!mounted) return;
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(message),
                                                    backgroundColor: isSuccess
                                                        ? Colors.green
                                                        : Colors.red,
                                                  ),
                                                );
                                                if (isSuccess)
                                                  Navigator.of(context).pop();
                                              },
                                              child: const Text(
                                                '+ Create',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 26),
                                  // End Experience Card
                                  Card(
                                    elevation: 0,
                                    color: Colors.grey[50],
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    margin: EdgeInsets.zero,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 18, vertical: 22),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Row(
                                            children: [
                                              Icon(Icons.stop_circle,
                                                  color: Colors.red, size: 22),
                                              SizedBox(width: 6),
                                              Text("End Experience",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600)),
                                            ],
                                          ),
                                          const SizedBox(height: 14),
                                          DropdownButtonFormField<String>(
                                            value: _selectedStreamEndEventId,
                                            isExpanded: true,
                                            decoration: const InputDecoration(
                                              labelText:
                                                  "Select Experience to End",
                                              border: OutlineInputBorder(),
                                            ),
                                            items: dropdownItems.cast<
                                                DropdownMenuItem<String>>(),
                                            onChanged: (value) {
                                              setState(() {
                                                _selectedStreamEndEventId =
                                                    value;
                                              });
                                            },
                                          ),
                                          _dateField(
                                            context,
                                            endDateController,
                                            "End Date",
                                            _endDate,
                                            (date) {
                                              setState(() {
                                                _endDate = date;
                                                endDateController.text =
                                                    DateFormat('dd/MM/yyyy')
                                                        .format(date);
                                              });
                                            },
                                          ),
                                          _passwordField(endPasswordController,
                                              "Wallet Password"),
                                          const SizedBox(height: 18),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.red[400],
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 16),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                              ),
                                              icon: const Icon(Icons.stop,
                                                  color: Colors.white),
                                              onPressed: () async {
                                                bool isSuccess = false;
                                                String message = '';
                                                try {
                                                  final company =
                                                      await widget.company;
                                                  final event = WorkEndedEvent(
                                                    id: randomBytesAsHexString(
                                                        16),
                                                    timestamp: DateTime.now()
                                                        .millisecondsSinceEpoch,
                                                    endDate: _endDate
                                                            ?.millisecondsSinceEpoch ??
                                                        DateTime.now()
                                                            .millisecondsSinceEpoch,
                                                    experienceStreamId:
                                                        _selectedStreamEndEventId ??
                                                            '',
                                                    companyName: company.name ??
                                                        'Unknown',
                                                    companyWallet: company
                                                            .ethereumAddress ??
                                                        '',
                                                  );
                                                  await widget.companyBll
                                                      .addEmployeeEvents(
                                                    widget.user,
                                                    event,
                                                    widget.companyId,
                                                    endPasswordController.text,
                                                  );
                                                  isSuccess = true;
                                                  message = "Experience ended!";
                                                } catch (e) {
                                                  isSuccess = false;
                                                  message = "Error: $e";
                                                }
                                                if (!mounted) return;
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(message),
                                                    backgroundColor: isSuccess
                                                        ? Colors.green
                                                        : Colors.red,
                                                  ),
                                                );
                                                if (isSuccess)
                                                  Navigator.of(context).pop();
                                              },
                                              label: const Text('End',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 26),
                                  // Promote Card
                                  Card(
                                    elevation: 0,
                                    color: Colors.grey[50],
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    margin: EdgeInsets.zero,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 18, vertical: 22),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Row(
                                            children: [
                                              Icon(Icons.trending_up,
                                                  color: Colors.blue, size: 22),
                                              SizedBox(width: 6),
                                              Text("Promote",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600)),
                                            ],
                                          ),
                                          const SizedBox(height: 14),
                                          DropdownButtonFormField<String>(
                                            value:
                                                _selectedStreamPromoteEventId,
                                            isExpanded: true,
                                            decoration: const InputDecoration(
                                              labelText:
                                                  "Select Experience to Promote",
                                              border: OutlineInputBorder(),
                                            ),
                                            items: dropdownItems.cast<
                                                DropdownMenuItem<String>>(),
                                            onChanged: (value) {
                                              setState(() {
                                                _selectedStreamPromoteEventId =
                                                    value;
                                              });
                                            },
                                          ),
                                          _field(
                                              newTitleController, "New Title"),
                                          _dateField(
                                            context,
                                            promotionDateController,
                                            "Promotion Date",
                                            _promotionDate,
                                            (date) {
                                              setState(() {
                                                _promotionDate = date;
                                                promotionDateController.text =
                                                    DateFormat('dd/MM/yyyy')
                                                        .format(date);
                                              });
                                            },
                                          ),
                                          _passwordField(
                                              promotePasswordController,
                                              "Wallet Password"),
                                          const SizedBox(height: 18),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.blue[400],
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 16),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                              ),
                                              icon: const Icon(
                                                  Icons.trending_up,
                                                  color: Colors.white),
                                              onPressed: () async {
                                                bool isSuccess = false;
                                                String message = '';
                                                try {
                                                  final company =
                                                      await widget.company;
                                                  final event =
                                                      WorkPromotedEvent(
                                                    id: randomBytesAsHexString(
                                                        16),
                                                    timestamp: DateTime.now()
                                                        .millisecondsSinceEpoch,
                                                    newTitle:
                                                        newTitleController.text,
                                                    promotionDate: _promotionDate
                                                            ?.millisecondsSinceEpoch ??
                                                        DateTime.now()
                                                            .millisecondsSinceEpoch,
                                                    experienceStreamId:
                                                        _selectedStreamPromoteEventId ??
                                                            '',
                                                    companyName: company.name ??
                                                        'Unknown',
                                                    companyWallet: company
                                                            .ethereumAddress ??
                                                        '',
                                                  );
                                                  await widget.companyBll
                                                      .addEmployeeEvents(
                                                    widget.user,
                                                    event,
                                                    widget.companyId,
                                                    promotePasswordController
                                                        .text,
                                                  );
                                                  isSuccess = true;
                                                  message =
                                                      "Promotion validated!";
                                                } catch (e) {
                                                  isSuccess = false;
                                                  message = "Error: $e";
                                                }
                                                if (!mounted) return;
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(message),
                                                    backgroundColor: isSuccess
                                                        ? Colors.green
                                                        : Colors.red,
                                                  ),
                                                );
                                                if (isSuccess)
                                                  Navigator.of(context).pop();
                                              },
                                              label: const Text('Promote',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        ),
      ),
    );
  }

  Widget _passwordField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        ),
        obscureText: true,
      ),
    );
  }

  Widget _dateField(
    BuildContext context,
    TextEditingController controller,
    String label,
    DateTime? date,
    Function(DateTime) onPick,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          prefixIcon: const Icon(Icons.date_range),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        ),
        onTap: () async {
          FocusScope.of(context).unfocus();
          final picked = await showDatePicker(
            context: context,
            initialDate: date ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
          );
          if (picked != null) {
            onPick(picked);
          }
        },
      ),
    );
  }
}
