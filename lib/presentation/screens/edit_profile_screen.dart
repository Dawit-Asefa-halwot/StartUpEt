import 'dart:ui';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_colors.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_event.dart';
import '../../features/auth/bloc/auth_state.dart';
import '../../models/user.dart';
import '../widgets/user_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  final User? user;

  const EditProfileScreen({super.key, this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _imageUrlController;

  final FocusNode _firstNameFocusNode = FocusNode();
  final FocusNode _lastNameFocusNode = FocusNode();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _addressFocusNode = FocusNode();

  String? _previewPhotoPath;
  bool _isPhotoRemoved = false;

  bool _isSubmitting = false;
  bool _isSavePressed = false;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    final nameParts = (u?.name ?? '').trim().split(' ');
    final defaultFirstName =
        u?.firstName ?? (nameParts.isNotEmpty ? nameParts.first : '');
    final defaultLastName =
        u?.lastName ??
        (nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '');

    _firstNameController = TextEditingController(text: defaultFirstName);
    _lastNameController = TextEditingController(text: defaultLastName);
    _nameController = TextEditingController(text: u?.name ?? '');
    _phoneController = TextEditingController(text: u?.phone ?? '');
    _addressController = TextEditingController(text: u?.address ?? '');
    _imageUrlController = TextEditingController(text: u?.image ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _imageUrlController.dispose();

    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _nameFocusNode.dispose();
    _phoneFocusNode.dispose();
    _addressFocusNode.dispose();
    super.dispose();
  }

  void _showAwesomeSnackbar(
    String title,
    String message,
    ContentType contentType,
  ) {
    if (!mounted) return;
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: contentType,
      ),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  void _showPhotoOptionsBottomSheet() {
    final hasPhoto = !_isPhotoRemoved &&
        ((_previewPhotoPath != null && _previewPhotoPath!.isNotEmpty) ||
            (widget.user?.image != null && widget.user!.image!.isNotEmpty));

    final bottomInset = MediaQuery.of(context).padding.bottom;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + bottomInset),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top drag handle bar
                Container(
                  width: 38,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0x3808737C),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Row 1: Take photo
                _buildBottomSheetOption(
                  label: 'Take photo',
                  textColor: AppColors.textPrimary,
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _pickImage();
                  },
                ),

                // Row 2: Choose from gallery
                _buildBottomSheetOption(
                  label: 'Choose from gallery',
                  textColor: AppColors.textPrimary,
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _pickImage();
                  },
                ),

                // Row 3: Remove photo (if photo exists)
                if (hasPhoto)
                  _buildBottomSheetOption(
                    label: 'Remove photo',
                    textColor: const Color(0xFFD14343),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      setState(() {
                        _isPhotoRemoved = true;
                        _previewPhotoPath = null;
                      });
                    },
                  ),

                // Row 4: Cancel
                _buildBottomSheetOption(
                  label: 'Cancel',
                  textColor: AppColors.textSecondary,
                  showDivider: false,
                  onTap: () => Navigator.pop(sheetContext),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetOption({
    required String label,
    required Color textColor,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Container(
      decoration: showDivider
          ? const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0x1F08737C), // rgba(8,115,124,0.12) hairline divider
                  width: 1,
                ),
              ),
            )
          : null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 56,
            alignment: Alignment.center,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      const XTypeGroup typeGroup = XTypeGroup(
        label: 'images',
        extensions: ['jpg', 'jpeg', 'png', 'webp'],
      );
      final XFile? file = await openFile(
        acceptedTypeGroups: const [typeGroup],
      );
      if (file != null) {
        setState(() {
          _previewPhotoPath = file.path;
          _isPhotoRemoved = false;
        });
      }
    } catch (e) {
      _showAwesomeSnackbar(
        'Image Notice',
        "Couldn't save the photo. Try again.",
        ContentType.failure,
      );
    }
  }

  Future<void> _onSave() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty) {
      _showAwesomeSnackbar(
        'Validation Error',
        'Please enter both first and last name',
        ContentType.warning,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Commit local photo changes ONLY when "Save changes" is tapped
    final userId = widget.user?.id ?? widget.user?.email ?? 'default_user';
    const storage = FlutterSecureStorage();
    final photoKey = 'profile_photo_$userId';

    try {
      if (_isPhotoRemoved) {
        await storage.delete(key: photoKey);
        UserAvatar.notifyPhotoChanged();
      } else if (_previewPhotoPath != null && _previewPhotoPath!.isNotEmpty) {
        await storage.write(key: photoKey, value: _previewPhotoPath!);
        UserAvatar.notifyPhotoChanged();
      }
    } catch (e) {
      // Ignore non-fatal local storage write errors
    }

    final name = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : '$firstName $lastName'.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();
    final image = _imageUrlController.text.trim(); // Keep existing URL in save payload

    context.read<AuthBloc>().add(
          AuthUpdateProfileRequested(
            firstName: firstName.isNotEmpty ? firstName : null,
            lastName: lastName.isNotEmpty ? lastName : null,
            name: name.isNotEmpty ? name : null,
            phone: phone.isNotEmpty ? phone : null,
            address: address.isNotEmpty ? address : null,
            image: image.isNotEmpty ? image : null,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          setState(() {
            _isSubmitting = false;
          });
          _showAwesomeSnackbar(
            'Profile Updated',
            'Profile updated successfully!',
            ContentType.success,
          );
          Navigator.pop(context);
        } else if (state is AuthError) {
          setState(() {
            _isSubmitting = false;
          });
          _showAwesomeSnackbar(
            'Update Failed',
            state.message,
            ContentType.failure,
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background, // #F3F8F8
        body: Stack(
          children: [
            Column(
              children: [
                // Fixed Teal Header + Overlapping Avatar Stack
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    // Header Container
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(24, topPadding + 24, 24, 68),
                      decoration: const BoxDecoration(
                        color: AppColors.primary, // #08737C
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(32),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Back button (44x44 circle, rgba(255,255,255,0.16))
                          Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            child: InkWell(
                              onTap: () => Navigator.pop(context),
                              customBorder: const CircleBorder(),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.16),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_back_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            'Edit profile',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.44, // -0.02em
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Avatar Overlapping Header (Move down by 52px)
                    Positioned(
                      bottom: -52,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          UserAvatar(
                            user: user,
                            radius: 52, // 104x104 circle
                            previewPath: _previewPhotoPath,
                            isPhotoRemoved: _isPhotoRemoved,
                            ringColor: AppColors.background, // #F3F8F8 6px ring
                            ringWidth: 6,
                          ),
                          // Camera Button (36x36, #F7A03A, 3px ring in #F3F8F8)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Semantics(
                              label: 'Change photo',
                              button: true,
                              child: GestureDetector(
                                onTap: _showPhotoOptionsBottomSheet,
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  alignment: Alignment.center,
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary, // #F7A03A
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.background, // #F3F8F8
                                        width: 3,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_outlined,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Scrollable Form Area
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(24, 74, 24, 130 + bottomInset),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Account email box (read-only)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0x1208737C), // rgba(8,115,124,0.07)
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Account email',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.textSecondary, // #5E7679
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    user?.email ?? 'Not available',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary, // #0D2E31
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  (user?.role ?? 'USER').toUpperCase(),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary, // #08737C
                                    letterSpacing: 0.88, // 0.08em
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Field 1: First Name | Last Name (2 columns)
                        Row(
                          children: [
                            Expanded(
                              child: _buildFormField(
                                label: 'First name',
                                placeholder: 'First name',
                                controller: _firstNameController,
                                focusNode: _firstNameFocusNode,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _buildFormField(
                                label: 'Last name',
                                placeholder: 'Last name',
                                controller: _lastNameController,
                                focusNode: _lastNameFocusNode,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Field 2: Full name
                        _buildFormField(
                          label: 'Full name',
                          placeholder: 'Full name',
                          controller: _nameController,
                          focusNode: _nameFocusNode,
                        ),
                        const SizedBox(height: 16),

                        // Field 3: Phone number
                        _buildFormField(
                          label: 'Phone number',
                          placeholder: '+251 91 123 4567',
                          controller: _phoneController,
                          focusNode: _phoneFocusNode,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),

                        // Field 4: Address or location
                        _buildFormField(
                          label: 'Address or location',
                          placeholder: 'e.g., Addis Ababa, Bole',
                          controller: _addressController,
                          focusNode: _addressFocusNode,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Floating Glass Footer Pinned at Bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 14, 20, 14 + bottomInset),
                decoration: const BoxDecoration(
                  color: Color(0x99FFFFFF), // rgba(255,255,255,0.6)
                  border: Border(
                    top: BorderSide(
                      color: Color(0xCCFFFFFF), // rgba(255,255,255,0.8)
                      width: 1,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1F08737C), // rgba(8,115,124,0.12)
                      blurRadius: 30,
                      offset: Offset(0, -10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(0),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                    child: Row(
                      children: [
                        // Cancel Button (flex 1)
                        Expanded(
                          flex: 10,
                          child: SizedBox(
                            height: 54,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(
                                  color: Color(0x4D08737C), // rgba(8,115,124,0.3)
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(27),
                                ),
                              ),
                              onPressed: _isSubmitting
                                  ? null
                                  : () => Navigator.pop(context),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Save Changes Button (flex 1.7)
                        Expanded(
                          flex: 17,
                          child: AnimatedScale(
                            scale: _isSavePressed ? 0.98 : 1.0,
                            duration: const Duration(milliseconds: 100),
                            child: Container(
                              height: 54,
                              decoration: BoxDecoration(
                                color: _isSavePressed
                                    ? AppColors.primaryDark // #06565D
                                    : AppColors.primary, // #08737C
                                borderRadius: BorderRadius.circular(27),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x7F08737C),
                                    blurRadius: 22,
                                    offset: Offset(0, 10),
                                    spreadRadius: -8,
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(27),
                                child: InkWell(
                                  onTapDown: (_) =>
                                      setState(() => _isSavePressed = true),
                                  onTapUp: (_) =>
                                      setState(() => _isSavePressed = false),
                                  onTapCancel: () =>
                                      setState(() => _isSavePressed = false),
                                  onTap: _isSubmitting ? null : _onSave,
                                  borderRadius: BorderRadius.circular(27),
                                  child: Center(
                                    child: _isSubmitting
                                        ? const SpinKitThreeBounce(
                                            color: Colors.white,
                                            size: 20,
                                          )
                                        : Text(
                                            'Save changes',
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

  Widget _buildFormField({
    required String label,
    required String placeholder,
    required TextEditingController controller,
    required FocusNode focusNode,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label (14px, semibold, #0D2E31, 8px above input)
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary, // #0D2E31
          ),
        ),
        const SizedBox(height: 8),

        // Input Box
        AnimatedBuilder(
          animation: focusNode,
          builder: (context, child) {
            final isFocused = focusNode.hasFocus;
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: isFocused
                    ? const [
                        BoxShadow(
                          color: Color(0x2408737C), // rgba(8,115,124,0.14) 3px glow
                          blurRadius: 6,
                          spreadRadius: 3,
                        ),
                      ]
                    : null,
              ),
              child: TextFormField(
                controller: controller,
                focusNode: focusNode,
                keyboardType: keyboardType,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary, // #0D2E31
                ),
                decoration: InputDecoration(
                  hintText: placeholder,
                  hintStyle: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF8DA3A6),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0x3808737C)), // 1px border rgba(8,115,124,0.22)
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0x3808737C)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFD14343), width: 1.5),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFD14343), width: 1.5),
                  ),
                  errorStyle: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFD14343),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
