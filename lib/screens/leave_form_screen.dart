import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../widgets/animated_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../controllers/leave_form_controller.dart';

class LeaveRequestFormScreen extends StatefulWidget {
  const LeaveRequestFormScreen({super.key});

  @override
  State<LeaveRequestFormScreen> createState() => _LeaveRequestFormScreenState();
}

class _LeaveRequestFormScreenState extends State<LeaveRequestFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _leaveType;
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _emiratesIdController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  File? _idImage;
  bool _ocrLoading = false;
  double _opacity = 0;
  Offset _offset = const Offset(0, 0.1);
  final LeaveFormController _controller = LeaveFormController();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted)
        setState(() {
          _opacity = 1;
          _offset = Offset.zero;
        });
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _emiratesIdController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _pickEmiratesId() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _idImage = File(picked.path);
        _ocrLoading = true;
      });
      final ocrResult = await _controller.extractEmiratesIdFromImage(_idImage!);
      if (ocrResult != null) {
        setState(() {
          _emiratesIdController.text = ocrResult['id']!;
          _nameController.text = ocrResult['name']!;
          _ocrLoading = false;
        });
      } else {
        setState(() => _ocrLoading = false);
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Invalid ID'),
              content: const Text(
                  'Could not extract a valid Emirates ID from the image.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  void _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_emiratesIdController.text.isEmpty || _nameController.text.isEmpty) {
      _showError('Please attach a valid Emirates ID.');
      return;
    }
    if (!_controller.allowedIds.contains(_emiratesIdController.text)) {
      _showError('This Emirates ID is not allowed to submit a leave request.');
      return;
    }
    final inOffice = await _controller.isInOffice();
    if (!inOffice) {
      _showError('You must be in the office to submit a leave request.');
      return;
    }
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Request Submitted'),
          content:
              const Text('Your leave request has been submitted successfully.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Request'),
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: AnimatedCard(
            opacity: _opacity,
            offset: _offset,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    value: _leaveType,
                    decoration: const InputDecoration(
                      labelText: 'Leave Type',
                      prefixIcon: Icon(Icons.beach_access),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'Annual', child: Text('Annual Leave')),
                      DropdownMenuItem(
                          value: 'Sick', child: Text('Sick Leave')),
                      DropdownMenuItem(
                          value: 'Unpaid', child: Text('Unpaid Leave')),
                    ],
                    onChanged: (val) => setState(() => _leaveType = val),
                    validator: (val) =>
                        val == null ? 'Please select leave type' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: TextEditingController(
                            text: _startDate == null
                                ? ''
                                : _startDate!
                                    .toLocal()
                                    .toString()
                                    .split(' ')[0],
                          ),
                          label: 'Start Date',
                          icon: Icons.date_range,
                          readOnly: true,
                          onTap: () => _pickDate(isStart: true),
                          validator: (val) => val == null || val.isEmpty
                              ? 'Select start date'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          controller: TextEditingController(
                            text: _endDate == null
                                ? ''
                                : _endDate!.toLocal().toString().split(' ')[0],
                          ),
                          label: 'End Date',
                          icon: Icons.date_range,
                          readOnly: true,
                          onTap: () => _pickDate(isStart: false),
                          validator: (val) => val == null || val.isEmpty
                              ? 'Select end date'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _reasonController,
                    label: 'Reason',
                    icon: Icons.edit_note,
                    maxLines: 2,
                    validator: (val) => val == null || val.isEmpty
                        ? 'Please enter a reason'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _emiratesIdController,
                    label: 'Emirates ID',
                    icon: Icons.badge_outlined,
                    readOnly: true,
                  ),
                  const SizedBox(height: 8),
                  CustomButton(
                    text: 'Attach Emirates ID',
                    icon: Icons.upload_file,
                    loading: _ocrLoading,
                    onPressed: _ocrLoading ? () {} : _pickEmiratesId,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _nameController,
                    label: 'Name',
                    icon: Icons.person_outline,
                    readOnly: true,
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Submit Request',
                    onPressed: _submitRequest,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
