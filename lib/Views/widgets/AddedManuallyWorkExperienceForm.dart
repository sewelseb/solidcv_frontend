import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSPromotions.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/ManualExperience.dart';

class AddedManuallyWorkExperienceForm extends StatefulWidget {
  final void Function(ManualExperience) onSubmit;

  const AddedManuallyWorkExperienceForm({super.key, required this.onSubmit});

  @override
  State<AddedManuallyWorkExperienceForm> createState() =>
      _AddedManuallyWorkExperienceFormState();
}

class _AddedManuallyWorkExperienceFormState
    extends State<AddedManuallyWorkExperienceForm> {
  final _formKey = GlobalKey<FormState>();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String? _title, _company, _description, _location;

  final _promotionList = <Map<String, dynamic>>[];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 500;
    final double horizontalPadding = isMobile ? 10 : 28;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 6 : 24,
        vertical: isMobile ? 14 : 36,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isMobile ? screenWidth * 0.97 : 420,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(horizontalPadding, isMobile ? 22 : 36,
              horizontalPadding, isMobile ? 16 : 28),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.work_outline,
                          color: const Color(0xFF7B3FE4), size: isMobile ? 24 : 30),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          AppLocalizations.of(context)!.addWorkExperienceTitle,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize:
                                isMobile ? 17 : 23, 
                            color: const Color(0xFF7B3FE4),
                            height: 1.2,
                          ),
                          maxLines: 2, 
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _buildTextField(AppLocalizations.of(context)!.addWorkExperienceJobTitle, (v) => _title = v),
                  const SizedBox(height: 14),
                  _buildTextField(AppLocalizations.of(context)!.addWorkExperienceCompany, (v) => _company = v),
                  const SizedBox(height: 14),
                  _buildTextField(AppLocalizations.of(context)!.addWorkExperienceLocation, (v) => _location = v),
                  const SizedBox(height: 14),
                  _buildTextField(AppLocalizations.of(context)!.addWorkExperienceDescription, (v) => _description = v,
                      multiline: true),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField(AppLocalizations.of(context)!.addWorkExperienceStartDate, _startDateController,
                            (picked) {
                          setState(() => _startDate = picked);
                        }),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildDateField(AppLocalizations.of(context)!.addWorkExperienceEndDate, _endDateController,
                            (picked) {
                          setState(() => _endDate = picked);
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF7B3FE4),
                            side: const BorderSide(
                                color: Color(0xFF7B3FE4), width: 1.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                          ),
                          child: Text(AppLocalizations.of(context)!.addWorkExperienceCancel,
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              final manual = ManualExperience(
                                title: _title,
                                company: _company,
                                location: _location,
                                description: _description,
                                startDateAsTimestamp:
                                    (_startDate?.millisecondsSinceEpoch ?? 0) ~/
                                        1000,
                                endDateAsTimestamp: _endDate != null
                                    ? _endDate!.millisecondsSinceEpoch ~/ 1000
                                    : null,
                                promotions: _promotionList
                                    .where((p) =>
                                        p['title'] != null &&
                                        p['timestamp'] != null)
                                    .map((p) => Promotion(
                                        newTitle: p['title'],
                                        date: p['timestamp']))
                                    .toList(),
                              );
                              widget.onSubmit(manual);
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7B3FE4),
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.addWorkExperienceSave,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, void Function(String?) onSaved,
      {bool multiline = false}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 14),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF7B3FE4), width: 1.5),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      maxLines: multiline ? 3 : 1,
      validator: (value) =>
          value == null || value.isEmpty ? AppLocalizations.of(context)!.addWorkExperienceFieldRequired(label) : null,
      onSaved: onSaved,
    );
  }

  Widget _buildDateField(String label, TextEditingController controller,
      void Function(DateTime) onPicked) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 14),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF7B3FE4), width: 1.5),
          borderRadius: BorderRadius.circular(14),
        ),
        suffixIcon:
            const Icon(Icons.calendar_today_outlined, color: Color(0xFF7B3FE4)),
      ),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          controller.text = picked.toIso8601String().split('T')[0];
          onPicked(picked);
        }
      },
      validator: (value) =>
          (label == AppLocalizations.of(context)!.addWorkExperienceStartDate && (value == null || value.isEmpty))
              ? AppLocalizations.of(context)!.addWorkExperienceDateRequired(label)
              : null,
    );
  }
}
