import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../data/models/allergen.dart';
import '../data/models/profile.dart';
import '../providers/allergen_provider.dart';
import '../providers/profile_provider.dart';
import 'adaptive_widgets.dart';
import 'allergen_badge.dart';
import 'allergen_chip.dart';
import 'category_selector.dart';
import 'adaptive_button.dart';
import '../data/allergen_knowledge_base.dart';

class ProfileSummaryCard extends ConsumerStatefulWidget {
  const ProfileSummaryCard({super.key});

  @override
  ConsumerState<ProfileSummaryCard> createState() =>
      _ProfileSummaryCardState();
}

class _ProfileSummaryCardState extends ConsumerState<ProfileSummaryCard> {
  static const _commonAllergens = allergenCategories;

  final _picker = ImagePicker();
  final _nameCtrl = TextEditingController();
  final Set<String> _selectedAllergens = {};
  final Set<String> _newAllergenNames = {};
  final Set<int> _removedAllergenIds = {};
  String _category = 'Padre';
  String? _photoPath;
  bool _isEditing = false;
  bool _hydrated = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _hydrateFrom(Profile? profile, List<Allergen> allergens) {
    if (profile != null) {
      _nameCtrl.text = profile.firstName;
      _category = profile.category.isEmpty ? 'Padre' : profile.category;
      _photoPath = profile.photoUri;
    }
    _selectedAllergens
      ..clear()
      ..addAll(allergens.map((a) => a.name));
    _newAllergenNames.clear();
    _removedAllergenIds.clear();
    _hydrated = true;
  }

  void _resetDraft() {
    _nameCtrl.clear();
    _category = 'Padre';
    _photoPath = null;
    _selectedAllergens.clear();
    _newAllergenNames.clear();
    _removedAllergenIds.clear();
    _hydrated = false;
  }

  void _toggleAllergen(String name) {
    final activeId = ref.read(activeProfileIdProvider);
    final original =
        ref.read(allergensProvider(activeId ?? 0)).value ?? const [];
    setState(() {
      if (_selectedAllergens.contains(name)) {
        _selectedAllergens.remove(name);
        _newAllergenNames.remove(name);
        for (final a in original) {
          if (a.name == name && a.id != null) {
            _removedAllergenIds.add(a.id!);
          }
        }
      } else {
        _selectedAllergens.add(name);
        final wasInOriginal = original.any((a) => a.name == name);
        if (!wasInOriginal) {
          _newAllergenNames.add(name);
        }
        _removedAllergenIds.removeWhere((id) {
          for (final a in original) {
            if (a.id == id) return a.name == name;
          }
          return false;
        });
      }
    });
  }

  Future<void> _save(Profile profile) async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      AdaptiveToast.show(
        context,
        message: 'Ingresa un nombre',
        variant: AdaptiveToastVariant.warning,
      );
      return;
    }
    final id = profile.id;
    if (id == null) return;

    final updated = profile.copyWith(
      firstName: name,
      category: _category,
      photoUri: _photoPath,
    );
    await ref
        .read(profileNotifierProvider.notifier)
        .updateActiveProfileFull(updated);

    for (final allergenId in _removedAllergenIds) {
      await ref
          .read(allergenNotifierProvider.notifier)
          .removeAllergen(allergenId);
    }
    for (final newName in _newAllergenNames) {
      await ref
          .read(allergenNotifierProvider.notifier)
          .addAllergen(id, newName);
    }

    if (!mounted) return;
    setState(() {
      _isEditing = false;
      _hydrated = false;
    });
    AdaptiveToast.show(context, message: 'Perfil actualizado');
  }

  void _cancel() {
    setState(() {
      _resetDraft();
      _isEditing = false;
    });
  }

  Future<void> _showPhotoOptions() async {
    if (!_isEditing) return;
    AdaptiveActionSheet.show(
      context,
      title: 'Foto de perfil',
      options: [
        AdaptiveActionSheetOption(
          label: '📷 Tomar foto',
          onTap: () => _takePhoto(),
        ),
        AdaptiveActionSheetOption(
          label: '🖼️ Seleccionar de galería',
          onTap: () => _pickFromGallery(),
        ),
      ],
    );
  }

  Future<void> _takePhoto() async {
    try {
      final photo =
          await _picker.pickImage(source: ImageSource.camera, maxWidth: 512, maxHeight: 512, imageQuality: 85);
      if (photo != null) {
        final saved = await _savePhoto(photo);
        setState(() => _photoPath = saved);
      }
    } catch (_) {
      if (mounted) {
        AdaptiveToast.show(context,
            message: 'No se pudo tomar la foto',
            variant: AdaptiveToastVariant.warning);
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final photo = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 512,
          maxHeight: 512,
          imageQuality: 85);
      if (photo != null) {
        final saved = await _savePhoto(photo);
        setState(() => _photoPath = saved);
      }
    } catch (_) {
      if (mounted) {
        AdaptiveToast.show(context,
            message: 'No se pudo seleccionar la foto',
            variant: AdaptiveToastVariant.warning);
      }
    }
  }

  Future<String> _savePhoto(XFile file) async {
    final appDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${appDir.path}/profile_photos');
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }
    final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final newPath = '${photosDir.path}/$fileName';
    await File(file.path).copy(newPath);
    return newPath;
  }

  @override
  Widget build(BuildContext context) {
    final activeId = ref.watch(activeProfileIdProvider);
    final profileAsync = ref.watch(activeProfileProvider);
    final allergensAsync = ref.watch(allergensProvider(activeId ?? 0));

    final profile = profileAsync.value;
    final allergens = allergensAsync.value ?? const [];

    if (!_hydrated && !_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _hydrateFrom(profile, allergens);
        });
      });
    }

    return AdaptiveCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: EdgeInsets.zero,
      child: AnimatedCrossFade(
        duration: const Duration(milliseconds: 300),
        firstCurve: Curves.easeInOut,
        secondCurve: Curves.easeInOut,
        crossFadeState:
            _isEditing ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        firstChild: _Collapsed(
          profile: profile,
          allergens: allergens,
          onEdit: () => setState(() {
            _hydrateFrom(profile, allergens);
            _isEditing = true;
          }),
        ),
        secondChild: _Expanded(
          nameCtrl: _nameCtrl,
          category: _category,
          photoPath: _photoPath,
          selectedAllergens: _selectedAllergens,
          commonAllergens: _commonAllergens,
          onCategoryChanged: (v) => setState(() => _category = v),
          onToggleAllergen: _toggleAllergen,
          onPhotoTap: _showPhotoOptions,
          onSave: profile == null ? null : () => _save(profile),
          onCancel: _cancel,
        ),
      ),
    );
  }
}

class _Collapsed extends ConsumerWidget {
  final Profile? profile;
  final List<Allergen> allergens;
  final VoidCallback onEdit;

  const _Collapsed({
    required this.profile,
    required this.allergens,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final firstName =
        (profile?.firstName.isNotEmpty ?? false) ? profile!.firstName : '?';
    final lastName = profile?.lastName ?? '';
    final fullName = lastName.isEmpty ? firstName : '$firstName $lastName';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Hero(
                tag: 'profile-avatar',
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: profile?.photoUri != null
                      ? CircleAvatar(
                          key: ValueKey('photo-${profile!.id}'),
                          radius: 28,
                          backgroundColor:
                              theme.colorScheme.primaryContainer,
                          backgroundImage:
                              FileImage(File(profile!.photoUri!)),
                        )
                      : _avatarFallback(theme, profile),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'profile-name',
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          fullName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    if (allergens.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final a in allergens)
                            AllergenBadge(label: a.name),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: AdaptiveButton(
              variant: AdaptiveButtonVariant.secondary,
              onTap: onEdit,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: 8),
                  Text('Editar perfil'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback(ThemeData theme, Profile? profile) {
    if (profile == null) return const SizedBox.shrink();
    final categoryOption =
        kCategoryOptions.where((o) => o.value == profile.category).firstOrNull;

    return Container(
      key: ValueKey('fallback-${profile.id}-${profile.category}'),
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            Color.lerp(theme.colorScheme.primary, Colors.white, 0.35)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: categoryOption != null
          ? SvgPicture.asset(
              categoryOption.svgAssetSelected,
              width: 28,
              height: 28,
            )
          : _initialText(theme, profile),
    );
  }

  Widget _initialText(ThemeData theme, Profile profile) {
    final first = profile.firstName.trim();
    return Text(
      first.isNotEmpty ? first[0].toUpperCase() : '?',
      style: TextStyle(
        fontSize: 20,
        color: Colors.white,
      ),
    );
  }
}

class _Expanded extends StatelessWidget {
  final TextEditingController nameCtrl;
  final String category;
  final String? photoPath;
  final Set<String> selectedAllergens;
  final List<String> commonAllergens;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onToggleAllergen;
  final VoidCallback onPhotoTap;
  final VoidCallback? onSave;
  final VoidCallback onCancel;

  const _Expanded({
    required this.nameCtrl,
    required this.category,
    required this.photoPath,
    required this.selectedAllergens,
    required this.commonAllergens,
    required this.onCategoryChanged,
    required this.onToggleAllergen,
    required this.onPhotoTap,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Stack(
              children: [
                Hero(
                  tag: 'profile-avatar',
                  child: GestureDetector(
                    onTap: onPhotoTap,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                      child: photoPath != null
                          ? CircleAvatar(
                              key: ValueKey('ephoto-$photoPath'),
                              radius: 40,
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                              backgroundImage:
                                  FileImage(File(photoPath!)),
                            )
                          : _expandedAvatarFallback(theme),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: onPhotoTap,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.surface,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 14,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Hero(
              tag: 'profile-category',
              child: Material(
                color: Colors.transparent,
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nombre / Alias',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: nameCtrl,
            decoration: InputDecoration(
              hintText: 'Tu nombre o alias',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Categoría',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          CategorySelector(value: category, onChanged: onCategoryChanged),
          const SizedBox(height: 20),
          const Text(
            'Alérgenos Conocidos',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final name in commonAllergens)
                AllergenChip(
                  label: name,
                  isSelected: selectedAllergens.contains(name),
                  onTap: () => onToggleAllergen(name),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: AdaptiveButton(
                  label: 'Cancelar',
                  icon: Icons.close,
                  onTap: onCancel,
                  variant: AdaptiveButtonVariant.pill,
                  backgroundColor:
                      theme.colorScheme.surfaceContainerHighest,
                  foregroundColor: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: AdaptiveButton(
                    onTap: onSave,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, size: 16, color: Colors.white),
                        SizedBox(width: 6),
                        Text('Guardar'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _expandedAvatarFallback(ThemeData theme) {
    final categoryOption =
        kCategoryOptions.where((o) => o.value == category).firstOrNull;

    return Container(
      key: ValueKey('efallback-$category'),
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            Color.lerp(theme.colorScheme.primary, Colors.white, 0.35)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: categoryOption != null
          ? SvgPicture.asset(
              categoryOption.svgAssetSelected,
              width: 40,
              height: 40,
            )
          : const Icon(Icons.person, size: 40, color: Colors.white),
    );
  }
}
