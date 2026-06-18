import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/models/profile.dart';
import '../providers/profile_provider.dart';
import 'profile_sheet.dart';

class ProfileButton extends ConsumerStatefulWidget {
  final double size;
  final double elevation;

  const ProfileButton({
    super.key,
    this.size = 56,
    this.elevation = 6,
  });

  @override
  ConsumerState<ProfileButton> createState() => _ProfileButtonState();
}

class _ProfileButtonState extends ConsumerState<ProfileButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeProfileAsync = ref.watch(activeProfileProvider);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () => showProfileSheet(context, ref),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: Material(
          elevation: widget.elevation,
          shadowColor: theme.colorScheme.primary.withValues(alpha: 0.4),
          shape: const CircleBorder(),
          color: theme.colorScheme.surface,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: activeProfileAsync.when(
              data: (profile) => _buildAvatar(theme, profile),
              loading: () => const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (_, _) => Icon(
                Icons.person_outline,
                size: widget.size * 0.5,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme, Profile? profile) {
    if (profile == null) {
      return Icon(
        CupertinoIcons.person_add,
        size: widget.size * 0.45,
        color: theme.colorScheme.primary,
      );
    }

    final photoUri = profile.photoUri;
    if (photoUri != null && photoUri.isNotEmpty) {
      final imageProvider = _buildImageProvider(photoUri);
      if (imageProvider != null) {
        return ClipOval(
          child: Image(
            image: imageProvider,
            width: widget.size,
            height: widget.size,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _buildCategoryIcon(theme, profile),
          ),
        );
      }
    }

    return _buildCategoryIcon(theme, profile);
  }

  Widget _buildCategoryIcon(ThemeData theme, Profile profile) {
    final svgAsset = _getCategorySvg(profile.category);
    
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.primary,
      ),
      alignment: Alignment.center,
      child: SvgPicture.asset(
        svgAsset,
        width: widget.size * 0.55,
        height: widget.size * 0.55,
      ),
    );
  }

  String _getCategorySvg(String category) {
    switch (category) {
      case 'Madre':
        return 'assets/icon/mama_filled.svg';
      case 'Padre':
        return 'assets/icon/padre_filled.svg';
      case 'Hijo':
        return 'assets/icon/hijo_filled.svg';
      case 'Hija':
        return 'assets/icon/hija_filled.svg';
      default:
        return 'assets/icon/mama_filled.svg';
    }
  }

  ImageProvider? _buildImageProvider(String uri) {
    if (uri.startsWith('http://') || uri.startsWith('https://')) {
      return NetworkImage(uri);
    }
    if (uri.startsWith('assets/')) {
      return AssetImage(uri);
    }
    final file = File(uri);
    if (file.existsSync()) {
      return FileImage(file);
    }
    return null;
  }
}
