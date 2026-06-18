import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/allergen_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/theme_style.dart';
import '../widgets/adaptive_button.dart';
import '../widgets/adaptive_widgets.dart';
import '../widgets/allergen_chip.dart';
import '../widgets/settings_toggle_row.dart';
import '../widgets/category_selector.dart';
import '../data/allergen_knowledge_base.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _nameController = TextEditingController();
  final _picker = ImagePicker();
  String _selectedCategory = 'Padre';
  String? _profilePhotoPath;
  final Set<String> _selectedAllergens = {};
  bool _isCreating = false;

  final _commonAllergens = List<String>.from(allergenCategories);

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _toggleAllergen(String name) {
    setState(() {
      if (_selectedAllergens.contains(name)) {
        _selectedAllergens.remove(name);
      } else {
        _selectedAllergens.add(name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeSettingProvider);
    final canPop = Navigator.of(context).canPop();
    final profilesAsync = ref.watch(allProfilesProvider);
    final isFirstProfile = profilesAsync.maybeWhen(
      data: (profiles) => profiles.isEmpty,
      orElse: () => profilesAsync.value?.isEmpty ?? true,
    );

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: canPop
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
              foregroundColor: theme.colorScheme.onSurface,
              leading: IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Cancelar',
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            )
          : null,
      body: SafeArea(
        top: canPop ? false : true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/logo.svg',
                      width: 48,
                      height: 48,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Bienvenido a ',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Flexible(
                      child: SvgPicture.asset(
                        'assets/logo_text.svg',
                        height: 32,
                        fit: BoxFit.contain,
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isFirstProfile
                    ? 'Comencemos creando tu primer perfil.\nPodrás crear varios perfiles desde la app'
                    : 'Completa los datos para añadir un nuevo perfil.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.35,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              const _SectionHeader(title: 'CREAR PERFIL'),
              AdaptiveCard(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: _showPhotoOptions,
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                              backgroundImage: _profilePhotoPath != null
                                  ? FileImage(File(_profilePhotoPath!))
                                  : null,
                              child: _profilePhotoPath == null
                                  ? Icon(
                                      Icons.person,
                                      size: 40,
                                      color: theme
                                          .colorScheme.onPrimaryContainer,
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _showPhotoOptions,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
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
                    const SizedBox(height: 20),
                    const Text(
                      'Nombre / Alias',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AdaptiveTextField(
                      controller: _nameController,
                      placeholder: 'Tu nombre o alias',
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Categoría',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CategorySelector(
                      value: _selectedCategory,
                      onChanged: (v) => setState(() => _selectedCategory = v),
                    ),
                  ],
                ),
              ),
              AdaptiveCard(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Alérgenos',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ..._commonAllergens.map((allergen) {
                          final isSelected =
                              _selectedAllergens.contains(allergen);
                          return AllergenChip(
                            label: allergen,
                            isSelected: isSelected,
                            onTap: () => _toggleAllergen(allergen),
                          );
                        }),
                      ],
                    ),
                    if (isFirstProfile) ...[
                      const SizedBox(height: 16),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: AdaptiveDivider(),
                      ),
                      const SizedBox(height: 8),
                      SettingsToggleRow(
                        icon: Icons.dark_mode,
                        title: 'Modo oscuro',
                        value: themeMode == ThemeModeSetting.dark,
                        onChanged: (v) {
                          ref
                              .read(settingsNotifierProvider.notifier)
                              .updateThemeMode(
                                v
                                    ? ThemeModeSetting.dark
                                    : ThemeModeSetting.light,
                              );
                        },
                        isLast: true,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: AdaptiveButton(
                  height: 56,
                  onTap: _isCreating ? null : _onStart,
                  child: _isCreating
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : const Text(
                          'EMPEZAR',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPhotoOptions() {
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
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (photo != null) {
        final savedPath = await _savePhoto(photo);
        setState(() => _profilePhotoPath = savedPath);
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
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (photo != null) {
        final savedPath = await _savePhoto(photo);
        setState(() => _profilePhotoPath = savedPath);
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

  Future<void> _onStart() async {
    if (_isCreating) return;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      AdaptiveToast.show(context,
          message: 'Completa el nombre',
          variant: AdaptiveToastVariant.warning);
      return;
    }

    setState(() => _isCreating = true);

    final wasFirstProfile = (ref.read(allProfilesProvider).value ?? const [])
        .isEmpty;
    final canPop = Navigator.of(context).canPop();

    final profileNotifier = ref.read(profileNotifierProvider.notifier);
    try {
      final id = await profileNotifier.createProfile(
        name,
        '',
        _selectedCategory,
        photoUri: _profilePhotoPath,
      );

      if (_selectedAllergens.isNotEmpty && mounted) {
        await ref
            .read(allergenNotifierProvider.notifier)
            .addInitialAllergens(id, _selectedAllergens.toList());
      }

      if (mounted) {
        ref.read(activeProfileIdProvider.notifier).state = id;
        ref.read(currentScreenProvider.notifier).state =
            wasFirstProfile ? KeComoScreen.welcome : KeComoScreen.today;
        if (canPop) Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        AdaptiveToast.show(context,
            message: 'No se pudo crear el perfil: $e',
            variant: AdaptiveToastVariant.destructive);
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}