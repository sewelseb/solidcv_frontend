import 'package:flutter/material.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSPromotions.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/ManualExperience.dart';

class AddedManuallyWorkExperienceForm extends StatefulWidget {
  final void Function(ManualExperience) onSubmit;

  const AddedManuallyWorkExperienceForm({super.key, required this.onSubmit});

  @override
  State<AddedManuallyWorkExperienceForm> createState() => _AddedManuallyWorkExperienceFormState();
}

class _AddedManuallyWorkExperienceFormState extends State<AddedManuallyWorkExperienceForm> {
  final _formKey = GlobalKey<FormState>();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String? _title, _company, _description, _location;

  final _promotionList = <Map<String, dynamic>>[];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Work Experience'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField('Title', (v) => _title = v),
              _buildTextField('Company', (v) => _company = v),
              _buildTextField('Location', (v) => _location = v),
              _buildTextField('Description', (v) => _description = v, multiline: true),
              _buildDateField('Start Date', _startDateController, (picked) {
                setState(() {
                  _startDate = picked;
                });
              }),
              _buildDateField('End Date', _endDateController, (picked) {
                setState(() {
                  _endDate = picked;
                });
              }),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              final manual = ManualExperience(
                title: _title,
                company: _company,
                location: _location,
                description: _description,
                startDateAsTimestamp: (_startDate?.millisecondsSinceEpoch ?? 0) ~/ 1000,
                endDateAsTimestamp: _endDate != null ? _endDate!.millisecondsSinceEpoch ~/ 1000 : null,
                promotions: _promotionList
                    .where((p) => p['title'] != null && p['timestamp'] != null)
                    .map((p) => Promotion(newTitle: p['title'], date: p['timestamp']))
                    .toList(),
              );
              widget.onSubmit(manual);
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, void Function(String?) onSaved, {bool multiline = false}) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      maxLines: multiline ? 3 : 1,
      validator: (value) => value == null || value.isEmpty ? 'Enter $label' : null,
      onSaved: onSaved,
    );
  }

  Widget _buildDateField(String label, TextEditingController controller, void Function(DateTime) onPicked) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(labelText: label),
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
    );
  }
}
