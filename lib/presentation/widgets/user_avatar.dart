import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_colors.dart';
import '../../models/user.dart';

/// Shared User Avatar Widget that displays local saved photo, server photo, or initial.
class UserAvatar extends StatefulWidget {
  final User? user;
  final double radius;
  final String? previewPath;
  final bool isPhotoRemoved;
  final Color? ringColor;
  final double ringWidth;
  final VoidCallback? onTap;

  static final ValueNotifier<int> _changeNotifier = ValueNotifier<int>(0);

  /// Call this whenever a profile photo is committed/saved or removed.
  static void notifyPhotoChanged() {
    _changeNotifier.value++;
  }

  const UserAvatar({
    super.key,
    required this.user,
    this.radius = 32,
    this.previewPath,
    this.isPhotoRemoved = false,
    this.ringColor,
    this.ringWidth = 0,
    this.onTap,
  });

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  String? _localPhotoPath;

  @override
  void initState() {
    super.initState();
    _loadLocalPhoto();
    UserAvatar._changeNotifier.addListener(_loadLocalPhoto);
  }

  @override
  void didUpdateWidget(covariant UserAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user?.id != widget.user?.id ||
        oldWidget.user?.email != widget.user?.email) {
      _loadLocalPhoto();
    }
  }

  @override
  void dispose() {
    UserAvatar._changeNotifier.removeListener(_loadLocalPhoto);
    super.dispose();
  }

  Future<void> _loadLocalPhoto() async {
    final userId = widget.user?.id ?? widget.user?.email ?? 'default_user';
    const storage = FlutterSecureStorage();
    final savedPath = await storage.read(key: 'profile_photo_$userId');
    if (mounted) {
      setState(() {
        _localPhotoPath = savedPath;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.radius * 2;
    final u = widget.user;
    final userName = u?.name ?? u?.email ?? 'U';
    final initial = userName.trim().isNotEmpty
        ? userName.trim()[0].toUpperCase()
        : 'U';

    ImageProvider? imageProvider;

    if (!widget.isPhotoRemoved) {
      if (widget.previewPath != null && widget.previewPath!.isNotEmpty) {
        if (widget.previewPath!.startsWith('http://') ||
            widget.previewPath!.startsWith('https://')) {
          imageProvider = NetworkImage(widget.previewPath!);
        } else {
          imageProvider = FileImage(File(widget.previewPath!));
        }
      } else if (_localPhotoPath != null && _localPhotoPath!.isNotEmpty) {
        if (_localPhotoPath!.startsWith('http://') ||
            _localPhotoPath!.startsWith('https://')) {
          imageProvider = NetworkImage(_localPhotoPath!);
        } else {
          final file = File(_localPhotoPath!);
          if (file.existsSync()) {
            imageProvider = FileImage(file);
          }
        }
      } else if (u?.image != null && u!.image!.isNotEmpty) {
        if (u.image!.startsWith('http://') || u.image!.startsWith('https://')) {
          imageProvider = NetworkImage(u.image!);
        } else {
          final file = File(u.image!);
          if (file.existsSync()) {
            imageProvider = FileImage(file);
          }
        }
      }
    }

    final avatarContent = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        image: imageProvider != null
            ? DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: imageProvider == null
          ? Center(
              child: Text(
                initial,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: widget.radius * 0.76, // 40px for 52px radius (104px diameter)
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            )
          : null,
    );

    Widget result = avatarContent;

    if (widget.ringWidth > 0 && widget.ringColor != null) {
      result = Container(
        padding: EdgeInsets.all(widget.ringWidth),
        decoration: BoxDecoration(
          color: widget.ringColor,
          shape: BoxShape.circle,
        ),
        child: avatarContent,
      );
    }

    if (widget.onTap != null) {
      result = GestureDetector(
        onTap: widget.onTap,
        child: result,
      );
    }

    return Semantics(
      label: widget.user?.name ?? 'User avatar',
      child: result,
    );
  }
}
