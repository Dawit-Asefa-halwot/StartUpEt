import 'dart:ui';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_colors.dart';
import '../../features/application/bloc/application_bloc.dart';
import '../../features/application/bloc/application_event.dart';
import '../../features/application/bloc/application_state.dart';
import '../../models/application.dart';

/// Dashed border painter for file upload container
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedBorderPainter({
    this.color = const Color(0x7308737C),
    this.strokeWidth = 1.0,
    this.gap = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(14),
    );

    final Path path = Path()..addRRect(rrect);
    final PathMetrics metrics = path.computeMetrics();

    for (final PathMetric metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        const double length = 6.0;
        final Path extractPath =
            metric.extractPath(distance, distance + length);
        canvas.drawPath(extractPath, paint);
        distance += length + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

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

  final List<String> _stepTitles = [
    'Business info',
    'Founders',
    'Details',
    'Financials',
    'Documents',
    'Review',
  ];

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
    if (_pitchDeckDocPath != null) {
      payload['pitchDeckDocPath'] = _pitchDeckDocPath;
    }

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
      const snackBar = SnackBar(
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
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).padding.bottom;

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
          const snackBar = SnackBar(
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
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            Column(
              children: [
                // Solid Header Container (Stays fixed)
                _buildHeader(context, topPadding),

                // Form Area (Scrolls)
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      24,
                      28,
                      24,
                      130 + bottomInset,
                    ),
                    child: _buildCurrentStepView(),
                  ),
                ),
              ],
            ),

            // Floating Glass Footer (Pinned to bottom)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildFloatingFooter(context, bottomInset),
            ),

            // Loading overlay during submission
            if (_isSubmitting)
              Container(
                color: Colors.black.withOpacity(0.45),
                child: Center(
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 24,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Submitting Application...',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.textPrimary,
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
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double topPadding) {
    final currentStepTitle = _stepTitles[_currentStep - 1];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, topPadding + 24, 24, 24),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(32),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Row: Back Button, Title Block, Save Draft Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Back Button
              Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () {
                    if (_currentStep > 1) {
                      setState(() {
                        _currentStep--;
                      });
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.16),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Title Block
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'New application',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.44,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Step $_currentStep of 6 · $currentStepTitle',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.80),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Save Draft Button
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: _isSubmitting ? null : _saveDraft,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        'Save draft',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Progress Bar: 6 equal-width segments
          Semantics(
            label: 'Step $_currentStep of 6',
            child: Row(
              children: List.generate(6, (index) {
                final stepNum = index + 1;
                Color segmentColor;
                if (stepNum < _currentStep) {
                  segmentColor = Colors.white;
                } else if (stepNum == _currentStep) {
                  segmentColor = AppColors.secondary;
                } else {
                  segmentColor = Colors.white.withOpacity(0.25);
                }

                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: index < 5 ? 6 : 0),
                    decoration: BoxDecoration(
                      color: segmentColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingFooter(BuildContext context, double bottomInset) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, 14, 20, 14 + bottomInset),
      decoration: const BoxDecoration(
        color: Color(0x99FFFFFF),
        border: Border(
          top: BorderSide(
            color: Color(0xCCFFFFFF),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x2E08737C),
            blurRadius: 32,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Row(
            children: [
              if (_currentStep > 1) ...[
                // Secondary Back Button
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 54,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(
                          color: Color(0x4D08737C),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27),
                        ),
                      ),
                      onPressed: _isSubmitting
                          ? null
                          : () {
                              setState(() {
                                _currentStep--;
                              });
                            },
                      child: Text(
                        'Back',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],

              // Main Save & Continue / Submit Button
              Expanded(
                flex: 2,
                child: PressableWizardButton(
                  label: _currentStep == 6
                      ? 'Submit application'
                      : 'Save and continue',
                  onPressed: _isSubmitting
                      ? () {}
                      : () {
                          if (_currentStep < 6) {
                            setState(() {
                              _currentStep++;
                            });
                          } else {
                            _submitApplication();
                          }
                        },
                ),
              ),
            ],
          ),
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
        Text(
          'Business profile',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: -0.48,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Provide core legal and organizational details of your startup.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            height: 1.6,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 26),

        _buildLabel('Startup name', isRequired: true),
        TextField(
          controller: _startupNameController,
          decoration: _inputDecoration('Your business name'),
        ),
        const SizedBox(height: 20),

        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Business registration no.'),
                  TextField(
                    controller: _registrationNumberController,
                    decoration: _inputDecoration('e.g., BRN123456'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('TIN number'),
                  TextField(
                    controller: _tinController,
                    decoration: _inputDecoration('Tax ID number'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Number of employees', isRequired: true),
                  TextField(
                    controller: _employeesController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration('e.g., 10'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
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
        const SizedBox(height: 20),

        _buildLabel('Founding date'),
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
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0x3808737C)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _foundingDate != null
                      ? '${_foundingDate!.year}-${_foundingDate!.month.toString().padLeft(2, '0')}-${_foundingDate!.day.toString().padLeft(2, '0')}'
                      : 'ቀን ይምረጡ…',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: _foundingDate != null
                        ? AppColors.textPrimary
                        : const Color(0xFF93A8AB),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 22,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        _buildLabel('Industry', isRequired: true),
        DropdownButtonFormField<String>(
          value: _selectedIndustry,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 20,
            color: AppColors.primary,
          ),
          items: _industries
              .map((ind) => DropdownMenuItem(
                    value: ind,
                    child: Text(
                      ind,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ))
              .toList(),
          onChanged: (val) => setState(() => _selectedIndustry = val),
          decoration: _inputDecoration('Select industry'),
        ),
        const SizedBox(height: 20),

        _buildLabel('Business stage', isRequired: true),
        DropdownButtonFormField<String>(
          value: _selectedStage,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 20,
            color: AppColors.primary,
          ),
          items: _stages
              .map((stg) => DropdownMenuItem(
                    value: stg,
                    child: Text(
                      stg,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ))
              .toList(),
          onChanged: (val) => setState(() => _selectedStage = val),
          decoration: _inputDecoration('Select lifecycle stage'),
        ),
        const SizedBox(height: 20),

        _buildLabel('Website'),
        TextField(
          controller: _websiteController,
          decoration: _inputDecoration('https://www.example.com'),
        ),
        const SizedBox(height: 20),

        _buildLabel('Business email', isRequired: true),
        TextField(
          controller: _businessEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecoration('business@example.com'),
        ),
        const SizedBox(height: 20),

        _buildLabel('Alternative email'),
        TextField(
          controller: _altEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecoration('alternative@example.com'),
        ),
        const SizedBox(height: 20),

        _buildLabel('Phone number', isRequired: true),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: _inputDecoration('+251 91 234 5678'),
        ),
        const SizedBox(height: 20),

        _buildLabel('Articles of incorporation', isRequired: true),
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
        Text(
          'Founders & leadership',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: -0.48,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Add founder profile and equity distribution details.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            height: 1.6,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 26),

        _buildLabel('Founder full name', isRequired: true),
        TextField(
          controller: _founderNameController,
          decoration: _inputDecoration('e.g., Abebe Feleke'),
        ),
        const SizedBox(height: 20),

        _buildLabel('Role / position', isRequired: true),
        TextField(
          controller: _founderRoleController,
          decoration: _inputDecoration('e.g., Chief Executive Officer (CEO)'),
        ),
        const SizedBox(height: 20),

        _buildLabel('Fayda National ID (FCN)', isRequired: true),
        TextField(
          controller: _founderFaydaController,
          decoration: _inputDecoration('16-digit FCN number'),
        ),
        const SizedBox(height: 20),

        _buildLabel('Equity ownership (%)', isRequired: true),
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
        Text(
          'Product & innovation details',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: -0.48,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Describe your technology solution and value proposition.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            height: 1.6,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 26),

        _buildLabel('Product / service summary', isRequired: true),
        TextField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: _inputDecoration(
            'Briefly outline your product or software platform',
          ),
        ),
        const SizedBox(height: 20),

        _buildLabel('Problem & solution', isRequired: true),
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
        Text(
          'Financial overview',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: -0.48,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Provide financial capital, revenue, and funding info.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            height: 1.6,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 26),

        _buildLabel('Annual revenue (ETB)'),
        TextField(
          controller: _revenueController,
          keyboardType: TextInputType.number,
          decoration: _inputDecoration('e.g., 500,000 ETB'),
        ),
        const SizedBox(height: 20),

        _buildLabel('Total raised funding (ETB)'),
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
        Text(
          'Required verification documents',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: -0.48,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Upload official certificates for verification (Max 20MB per document).',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            height: 1.6,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 26),

        _buildLabel('Business registration certificate', isRequired: true),
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
        const SizedBox(height: 20),

        _buildLabel('Startup pitch deck (PDF)', isRequired: true),
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
        Text(
          'Review & submission',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: -0.48,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Verify all details before submitting for official Ethiopian startup label certification.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            height: 1.6,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 26),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          padding: const EdgeInsets.all(20),
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
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                height: 1,
                color: const Color(0x1F08737C),
              ),
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
        const SizedBox(height: 20),

        CheckboxListTile(
          value: _declarationConfirmed,
          onChanged: (val) =>
              setState(() => _declarationConfirmed = val ?? false),
          activeColor: AppColors.primary,
          contentPadding: EdgeInsets.zero,
          title: Text(
            'I hereby declare that all provided business info is accurate under penalty of Ethiopian startup proclamation guidelines.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
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
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: value == 'Not uploaded'
                  ? const Color(0xFFD14343)
                  : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String labelText, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          children: [
            TextSpan(text: labelText),
            if (isRequired)
              TextSpan(
                text: ' *',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.plusJakartaSans(
        color: const Color(0xFF93A8AB),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0x3808737C)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0x3808737C)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
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

    return CustomPaint(
      painter: DashedBorderPainter(
        color: hasFile ? AppColors.primary : const Color(0x7308737C),
        strokeWidth: 1.2,
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Material(
              color: const Color(0x1A08737C),
              borderRadius: BorderRadius.circular(21),
              child: InkWell(
                onTap: onPick,
                borderRadius: BorderRadius.circular(21),
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: Text(
                      'Choose file',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasFile ? fileName : 'No file chosen',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    hint,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (hasFile && onClear != null)
              IconButton(
                icon: const Icon(
                  Icons.cancel_outlined,
                  size: 20,
                  color: Color(0xFFD14343),
                ),
                onPressed: onClear,
                tooltip: 'Remove File',
              ),
          ],
        ),
      ),
    );
  }
}

/// Animated Pressable Wizard Button with 0.98 press scale animation
class PressableWizardButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const PressableWizardButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  State<PressableWizardButton> createState() => _PressableWizardButtonState();
}

class _PressableWizardButtonState extends State<PressableWizardButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: _isPressed ? AppColors.primaryDark : AppColors.primary,
          borderRadius: BorderRadius.circular(27),
          boxShadow: const [
            BoxShadow(
              color: Color(0x7F08737C),
              blurRadius: 22,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(27),
          child: InkWell(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(27),
            child: Center(
              child: Text(
                widget.label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
