import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startupet/features/application/bloc/application_state.dart';

import '../../core/app_colors.dart';
import '../../features/application/bloc/application_bloc.dart';
import '../../features/application/bloc/application_event.dart';
import '../../models/application.dart';

class NewApplicationWizardScreen extends StatefulWidget {
  final Application? existingApplication;

  const NewApplicationWizardScreen({super.key, this.existingApplication});

  @override
  State<NewApplicationWizardScreen> createState() =>
      _NewApplicationWizardScreenState();
}

class _NewApplicationWizardScreenState
    extends State<NewApplicationWizardScreen> {
  int _currentStep = 1;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingApplication != null) {
      final data = widget.existingApplication!.data ?? {};
      String getVal(List<String> keys) {
        for (final k in keys) {
          if (data[k] != null && data[k].toString().isNotEmpty) {
            return data[k].toString();
          }
        }
        return '';
      }

      _startupNameController.text = getVal([
        'startupName',
        'startup_name',
        'name',
      ]);
      _registrationNumberController.text = getVal([
        'registrationNumber',
        'registration_number',
        'regNumber',
      ]);
      _tinController.text = getVal(['tin', 'tinNumber', 'tin_number']);
      _employeesController.text = getVal([
        'employees',
        'employeeCount',
        'num_employees',
      ]);
      _capitalController.text = getVal(['capital', 'totalCapital']);
      _websiteController.text = getVal(['website', 'url']);
      _businessEmailController.text = getVal([
        'email',
        'businessEmail',
        'business_email',
      ]);
      _phoneController.text = getVal(['phone', 'phoneNumber', 'phone_number']);
      _founderNameController.text = getVal([
        'founderName',
        'founder_name',
        'founder',
      ]);
      _descriptionController.text = getVal([
        'description',
        'productSummary',
        'summary',
      ]);

      final indVal = getVal(['industry', 'sector']);
      if (indVal.isNotEmpty && _industries.contains(indVal)) {
        _selectedIndustry = indVal;
      }
      final stgVal = getVal(['stage', 'lifecycle']);
      if (stgVal.isNotEmpty && _stages.contains(stgVal)) {
        _selectedStage = stgVal;
      }

      final artDoc = getVal([
        'articlesDoc',
        'articles_of_incorporation',
        'articlesDocName',
      ]);
      if (artDoc.isNotEmpty) _articlesDocName = artDoc;
      final artPath = getVal(['articlesDocPath']);
      if (artPath.isNotEmpty) _articlesDocPath = artPath;

      final regDoc = getVal([
        'regCertDoc',
        'registration_certificate',
        'regCertDocName',
      ]);
      if (regDoc.isNotEmpty) _regCertDocName = regDoc;
      final regPath = getVal(['regCertDocPath']);
      if (regPath.isNotEmpty) _regCertDocPath = regPath;

      final pitchDoc = getVal([
        'pitchDeckDoc',
        'pitch_deck',
        'pitchDeckDocName',
      ]);
      if (pitchDoc.isNotEmpty) _pitchDeckDocName = pitchDoc;
      final pitchPath = getVal(['pitchDeckDocPath']);
      if (pitchPath.isNotEmpty) _pitchDeckDocPath = pitchPath;
    }
  }

  // Step 1: Business Profile Controllers
  final _startupNameController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _tinController = TextEditingController();
  final _employeesController = TextEditingController();
  final _capitalController = TextEditingController();
  DateTime? _foundingDate;
  String? _selectedIndustry;
  String? _selectedStage;
  final _websiteController = TextEditingController();
  final _businessEmailController = TextEditingController();
  final _altEmailController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _articlesDocName;
  String? _articlesDocPath;

  // Step 2: Founders Controllers
  final _founderNameController = TextEditingController();
  final _founderRoleController = TextEditingController();
  final _founderFaydaController = TextEditingController();
  final _founderEquityController = TextEditingController();

  // Step 3: Details Controllers
  final _descriptionController = TextEditingController();
  final _problemSolutionController = TextEditingController();

  // Step 4: Financials Controllers
  final _revenueController = TextEditingController();
  final _fundingController = TextEditingController();

  // Step 5: Documents
  String? _regCertDocName;
  String? _regCertDocPath;
  String? _pitchDeckDocName;
  String? _pitchDeckDocPath;

  // Step 6: Review & Declaration
  bool _declarationConfirmed = false;

  final List<String> _industries = [
    'Agriculture & AgriTech',
    'FinTech & Financial Services',
    'HealthTech & BioTech',
    'EdTech & Learning',
    'E-Commerce & Retail',
    'Logistics & Mobility',
    'CleanTech & Energy',
    'Artificial Intelligence & Software',
    'Other Industry',
  ];

  final List<String> _stages = [
    'Idea Stage',
    'Early Stage (MVP)',
    'Growth Stage',
    'Expansion Stage',
  ];

  @override
  void dispose() {
    _startupNameController.dispose();
    _registrationNumberController.dispose();
    _tinController.dispose();
    _employeesController.dispose();
    _capitalController.dispose();
    _websiteController.dispose();
    _businessEmailController.dispose();
    _altEmailController.dispose();
    _phoneController.dispose();
    _founderNameController.dispose();
    _founderRoleController.dispose();
    _founderFaydaController.dispose();
    _founderEquityController.dispose();
    _descriptionController.dispose();
    _problemSolutionController.dispose();
    _revenueController.dispose();
    _fundingController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument({
    required Function(String name, String? path) onPicked,
    List<String>? allowedExtensions,
  }) async {
    try {
      final XTypeGroup typeGroup = XTypeGroup(
        label: 'documents',
        extensions: allowedExtensions ?? const [],
      );
      final XFile? file = await openFile(
        acceptedTypeGroups:
            allowedExtensions != null && allowedExtensions.isNotEmpty
            ? [typeGroup]
            : const [],
      );

      if (file != null) {
        onPicked(file.name, file.path);
      }
    } catch (e) {
      if (mounted) {
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'File Error',
            message: 'Could not pick file: $e',
            contentType: ContentType.failure,
          ),
        );
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      }
    }
  }

  String _mapStageToBackend(String? stage) {
    switch (stage) {
      case 'Idea Stage':
      case 'Early Stage (MVP)':
        return 'INITIAL';
      case 'Growth Stage':
        return 'POST_INITIAL';
      case 'Expansion Stage':
        return 'SCALE_EXIT';
      default:
        return 'INITIAL';
    }
  }

  Map<String, dynamic> _buildPayload({required String status}) {
    final Map<String, dynamic> payload = {
      'status': status,
      'startupName': _startupNameController.text.trim().isEmpty
          ? (status == 'DRAFT'
                ? 'Draft Startup Application'
                : 'My Ethiopian Startup')
          : _startupNameController.text.trim(),
      'industry': _selectedIndustry ?? 'Agriculture & AgriTech',
      'stage': _mapStageToBackend(_selectedStage),
    };

    void addIfNotEmpty(String key, String value) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) {
        payload[key] = trimmed;
      }
    }

    // Backend fields + legacy client fallbacks
    addIfNotEmpty('businessRegNumber', _registrationNumberController.text);
    addIfNotEmpty('registrationNumber', _registrationNumberController.text);

    addIfNotEmpty('tinNumber', _tinController.text);
    addIfNotEmpty('tin', _tinController.text);

    addIfNotEmpty('numberOfEmployees', _employeesController.text);
    addIfNotEmpty('employees', _employeesController.text);

    addIfNotEmpty('capital', _capitalController.text);

    if (_foundingDate != null) {
      payload['foundingDate'] = _foundingDate!.toIso8601String();
    }

    addIfNotEmpty('website', _websiteController.text);

    addIfNotEmpty('businessEmail', _businessEmailController.text);
    addIfNotEmpty('email', _businessEmailController.text);

    addIfNotEmpty('phoneNumber', _phoneController.text);
    addIfNotEmpty('phone', _phoneController.text);

    addIfNotEmpty('founderName', _founderNameController.text);

    addIfNotEmpty('businessDescription', _descriptionController.text);
    addIfNotEmpty('description', _descriptionController.text);

    if (_articlesDocName != null) payload['articlesDoc'] = _articlesDocName;
    if (_articlesDocPath != null) payload['articlesDocPath'] = _articlesDocPath;
    if (_regCertDocName != null) payload['regCertDoc'] = _regCertDocName;
    if (_regCertDocPath != null) payload['regCertDocPath'] = _regCertDocPath;
    if (_pitchDeckDocName != null) payload['pitchDeckDoc'] = _pitchDeckDocName;
    if (_pitchDeckDocPath != null)
      payload['pitchDeckDocPath'] = _pitchDeckDocPath;

    return payload;
  }

  void _saveDraft() {
    setState(() {
      _isSubmitting = true;
    });

    final draftData = _buildPayload(status: 'DRAFT');

    if (widget.existingApplication != null) {
      draftData['id'] = widget.existingApplication!.id;
      context.read<ApplicationBloc>().add(UpdateApplication(draftData));
    } else {
      context.read<ApplicationBloc>().add(CreateApplication(draftData));
    }
  }

  void _submitApplication() {
    if (!_declarationConfirmed) {
      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Declaration Required',
          message: 'Please accept the declaration before submitting.',
          contentType: ContentType.warning,
        ),
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final applicationData = _buildPayload(status: 'PENDING');

    if (widget.existingApplication != null) {
      applicationData['id'] = widget.existingApplication!.id;
      context.read<ApplicationBloc>().add(UpdateApplication(applicationData));
    } else {
      context.read<ApplicationBloc>().add(CreateApplication(applicationData));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ApplicationBloc, ApplicationState>(
      listener: (context, state) {
        if (!_isSubmitting) return;

        if (state is ApplicationError) {
          setState(() {
            _isSubmitting = false;
          });
          final snackBar = SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Application Error',
              message: state.message,
              contentType: ContentType.failure,
            ),
          );
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(snackBar);
        } else if (state is ApplicationCreated ||
            state is ApplicationListLoaded) {
          setState(() {
            _isSubmitting = false;
          });
          final snackBar = SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Success',
              message: 'Application saved successfully!',
              contentType: ContentType.success,
            ),
          );
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(snackBar);
          Navigator.pop(context);
        }
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.grey.shade50,
            appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'New Application',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Step $_currentStep of 6',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              actions: [
                TextButton.icon(
                  onPressed: _isSubmitting ? null : _saveDraft,
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: const Text('Save Draft'),
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: Column(
              children: [
                // Step Progress Bar Indicator
                _buildStepProgressHeader(),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: _buildCurrentStepView(),
                  ),
                ),

                // Bottom Action Bar
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity( 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentStep > 1)
                        OutlinedButton(
                          onPressed: _isSubmitting
                              ? null
                              : () {
                                  setState(() {
                                    _currentStep--;
                                  });
                                },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Back'),
                        )
                      else
                        const SizedBox(),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isSubmitting
                            ? null
                            : () {
                                if (_currentStep < 6) {
                                  setState(() {
                                    _currentStep++;
                                  });
                                } else {
                                  _submitApplication();
                                }
                              },
                        child: Text(
                          _currentStep == 6
                              ? 'Submit Application'
                              : 'Save and Continue',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isSubmitting)
            Container(
              color: Colors.black.withOpacity( 0.45),
              child: Center(
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: 18),
                        Text(
                          'Submitting Application...',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStepProgressHeader() {
    final stepTitles = [
      'Business Info',
      'Founders',
      'Details',
      'Financials',
      'Documents',
      'Review',
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: List.generate(6, (index) {
            final stepNumber = index + 1;
            final isActive = stepNumber == _currentStep;
            final isCompleted = stepNumber < _currentStep;

            return Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentStep = stepNumber;
                    });
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: isActive
                            ? AppColors.primary
                            : isCompleted
                            ? Colors.teal
                            : Colors.grey.shade300,
                        child: isCompleted
                            ? const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              )
                            : Text(
                                '$stepNumber',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isActive || isCompleted
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        stepTitles[index],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isActive
                              ? AppColors.primary
                              : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (index < 5)
                  Container(
                    width: 24,
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    color: isCompleted ? Colors.teal : Colors.grey.shade300,
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildCurrentStepView() {
    switch (_currentStep) {
      case 1:
        return _buildStep1BusinessInfo();
      case 2:
        return _buildStep2Founders();
      case 3:
        return _buildStep3Details();
      case 4:
        return _buildStep4Financials();
      case 5:
        return _buildStep5Documents();
      case 6:
        return _buildStep6Review();
      default:
        return const SizedBox();
    }
  }

  // --- Step 1: Business Profile ---
  Widget _buildStep1BusinessInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Business Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Provide core legal and organizational details of your startup.',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        const SizedBox(height: 20),

        _buildLabel('Startup Name *'),
        TextField(
          controller: _startupNameController,
          decoration: _inputDecoration('Your business name'),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Business Registration No.'),
                  TextField(
                    controller: _registrationNumberController,
                    decoration: _inputDecoration('e.g., BRN123456'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('TIN Number'),
                  TextField(
                    controller: _tinController,
                    decoration: _inputDecoration('Tax ID Number'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Number of Employees *'),
                  TextField(
                    controller: _employeesController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration('e.g., 10'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Capital (ETB)'),
                  TextField(
                    controller: _capitalController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration('e.g., 100,000'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        _buildLabel('Founding Date'),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() {
                _foundingDate = picked;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _foundingDate != null
                      ? '${_foundingDate!.year}-${_foundingDate!.month.toString().padLeft(2, '0')}-${_foundingDate!.day.toString().padLeft(2, '0')}'
                      : 'ቀን ይምረጡ…',
                  style: TextStyle(
                    color: _foundingDate != null
                        ? Colors.black
                        : Colors.grey[600],
                  ),
                ),
                const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        _buildLabel('Industry *'),
        DropdownButtonFormField<String>(
          value: _selectedIndustry,
          items: _industries
              .map((ind) => DropdownMenuItem(value: ind, child: Text(ind)))
              .toList(),
          onChanged: (val) => setState(() => _selectedIndustry = val),
          decoration: _inputDecoration('Select industry'),
        ),
        const SizedBox(height: 16),

        _buildLabel('Business Stage *'),
        DropdownButtonFormField<String>(
          value: _selectedStage,
          items: _stages
              .map((stg) => DropdownMenuItem(value: stg, child: Text(stg)))
              .toList(),
          onChanged: (val) => setState(() => _selectedStage = val),
          decoration: _inputDecoration('Select lifecycle stage'),
        ),
        const SizedBox(height: 16),

        _buildLabel('Website'),
        TextField(
          controller: _websiteController,
          decoration: _inputDecoration('https://www.example.com'),
        ),
        const SizedBox(height: 16),

        _buildLabel('Business Email *'),
        TextField(
          controller: _businessEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecoration('business@example.com'),
        ),
        const SizedBox(height: 16),

        _buildLabel('Alternative Email'),
        TextField(
          controller: _altEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecoration('alternative@example.com'),
        ),
        const SizedBox(height: 16),

        _buildLabel('Phone Number *'),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: _inputDecoration('+251 91 234 5678'),
        ),
        const SizedBox(height: 16),

        _buildLabel('Articles of Incorporation *'),
        _buildFileUploadTile(
          fileName: _articlesDocName,
          hint: 'Max 20MB (PDF, DOCX, PNG, JPG)',
          onPick: () {
            _pickDocument(
              allowedExtensions: ['pdf', 'docx', 'doc', 'png', 'jpg', 'jpeg'],
              onPicked: (name, path) {
                setState(() {
                  _articlesDocName = name;
                  _articlesDocPath = path;
                });
              },
            );
          },
          onClear: () {
            setState(() {
              _articlesDocName = null;
              _articlesDocPath = null;
            });
          },
        ),
      ],
    );
  }

  // --- Step 2: Founders ---
  Widget _buildStep2Founders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Founders & Leadership',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Add founder profile and equity distribution details.',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        const SizedBox(height: 20),

        _buildLabel('Founder Full Name *'),
        TextField(
          controller: _founderNameController,
          decoration: _inputDecoration('e.g., Leul Eyasu'),
        ),
        const SizedBox(height: 16),

        _buildLabel('Role / Position *'),
        TextField(
          controller: _founderRoleController,
          decoration: _inputDecoration('e.g., Chief Executive Officer (CEO)'),
        ),
        const SizedBox(height: 16),

        _buildLabel('Fayda National ID (FCN) *'),
        TextField(
          controller: _founderFaydaController,
          decoration: _inputDecoration('16-digit FCN number'),
        ),
        const SizedBox(height: 16),

        _buildLabel('Equity Ownership (%) *'),
        TextField(
          controller: _founderEquityController,
          keyboardType: TextInputType.number,
          decoration: _inputDecoration('e.g., 60%'),
        ),
      ],
    );
  }

  // --- Step 3: Details ---
  Widget _buildStep3Details() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Product & Innovation Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Describe your technology solution and value proposition.',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        const SizedBox(height: 20),

        _buildLabel('Product / Service Summary *'),
        TextField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: _inputDecoration(
            'Briefly outline your product or software platform',
          ),
        ),
        const SizedBox(height: 16),

        _buildLabel('Problem & Solution *'),
        TextField(
          controller: _problemSolutionController,
          maxLines: 4,
          decoration: _inputDecoration(
            'Describe the local problem in Ethiopia and your innovative solution',
          ),
        ),
      ],
    );
  }

  // --- Step 4: Financials ---
  Widget _buildStep4Financials() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Financial Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Provide financial capital, revenue, and funding info.',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        const SizedBox(height: 20),

        _buildLabel('Annual Revenue (ETB)'),
        TextField(
          controller: _revenueController,
          keyboardType: TextInputType.number,
          decoration: _inputDecoration('e.g., 500,000 ETB'),
        ),
        const SizedBox(height: 16),

        _buildLabel('Total Raised Funding (ETB)'),
        TextField(
          controller: _fundingController,
          keyboardType: TextInputType.number,
          decoration: _inputDecoration('e.g., 1,000,000 ETB'),
        ),
      ],
    );
  }

  // --- Step 5: Documents ---
  Widget _buildStep5Documents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Required Verification Documents',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Upload official certificates for verification (Max 20MB per document).',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        const SizedBox(height: 20),

        _buildLabel('Business Registration Certificate *'),
        _buildFileUploadTile(
          fileName: _regCertDocName,
          hint: 'Commercial registration certificate (PDF, DOCX, PNG, JPG)',
          onPick: () {
            _pickDocument(
              allowedExtensions: ['pdf', 'docx', 'doc', 'png', 'jpg', 'jpeg'],
              onPicked: (name, path) {
                setState(() {
                  _regCertDocName = name;
                  _regCertDocPath = path;
                });
              },
            );
          },
          onClear: () {
            setState(() {
              _regCertDocName = null;
              _regCertDocPath = null;
            });
          },
        ),
        const SizedBox(height: 16),

        _buildLabel('Startup Pitch Deck (PDF) *'),
        _buildFileUploadTile(
          fileName: _pitchDeckDocName,
          hint: 'Executive pitch deck slides (PDF, PPTX)',
          onPick: () {
            _pickDocument(
              allowedExtensions: ['pdf', 'pptx', 'ppt'],
              onPicked: (name, path) {
                setState(() {
                  _pitchDeckDocName = name;
                  _pitchDeckDocPath = path;
                });
              },
            );
          },
          onClear: () {
            setState(() {
              _pitchDeckDocName = null;
              _pitchDeckDocPath = null;
            });
          },
        ),
      ],
    );
  }

  // --- Step 6: Review & Submit ---
  Widget _buildStep6Review() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Review & Submission',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Verify all details before submitting for official Ethiopian startup label certification.',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        const SizedBox(height: 20),

        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _reviewRow(
                  'Startup Name',
                  _startupNameController.text.isEmpty
                      ? 'My Startup'
                      : _startupNameController.text,
                ),
                _reviewRow('Industry', _selectedIndustry ?? 'Technology'),
                _reviewRow('Stage', _selectedStage ?? 'Early Stage'),
                _reviewRow(
                  'Employees',
                  _employeesController.text.isEmpty
                      ? '10'
                      : _employeesController.text,
                ),
                _reviewRow(
                  'Email',
                  _businessEmailController.text.isEmpty
                      ? 'business@example.com'
                      : _businessEmailController.text,
                ),
                _reviewRow(
                  'Phone',
                  _phoneController.text.isEmpty
                      ? '+251 91 234 5678'
                      : _phoneController.text,
                ),
                const Divider(height: 20),
                _reviewRow(
                  'Articles of Inc.',
                  _articlesDocName ?? 'Not uploaded',
                ),
                _reviewRow(
                  'Registration Cert.',
                  _regCertDocName ?? 'Not uploaded',
                ),
                _reviewRow('Pitch Deck', _pitchDeckDocName ?? 'Not uploaded'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        CheckboxListTile(
          value: _declarationConfirmed,
          onChanged: (val) =>
              setState(() => _declarationConfirmed = val ?? false),
          activeColor: AppColors.primary,
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'I hereby declare that all provided business info is accurate under penalty of Ethiopian startup proclamation guidelines.',
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _reviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: value == 'Not uploaded' ? Colors.red.shade400 : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String labelText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        labelText,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: Color(0xFF1E293B),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  Widget _buildFileUploadTile({
    required String? fileName,
    required String hint,
    required VoidCallback onPick,
    VoidCallback? onClear,
  }) {
    final hasFile = fileName != null && fileName.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasFile
            ? AppColors.primary.withOpacity( 0.04)
            : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasFile
              ? AppColors.primary.withOpacity( 0.5)
              : Colors.grey.shade300,
          width: hasFile ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: hasFile
                  ? AppColors.primary
                  : Colors.grey.shade200,
              foregroundColor: hasFile ? Colors.white : Colors.black87,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: onPick,
            icon: Icon(
              hasFile ? Icons.file_present_rounded : Icons.upload_file_rounded,
              size: 18,
            ),
            label: Text(hasFile ? 'Change File' : 'Choose File'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasFile ? fileName : 'No file chosen',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: hasFile ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                    color: hasFile ? AppColors.primary : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hint,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          if (hasFile && onClear != null)
            IconButton(
              icon: const Icon(
                Icons.cancel_outlined,
                size: 20,
                color: Colors.redAccent,
              ),
              onPressed: onClear,
              tooltip: 'Remove File',
            ),
        ],
      ),
    );
  }
}
