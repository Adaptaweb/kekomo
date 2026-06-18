import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/models/profile.dart';
import '../providers/profile_provider.dart';
import '../screens/onboarding_screen.dart';
import '../widgets/adaptive_widgets.dart';
import 'category_selector.dart';

Future<void> showProfileSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => const _ProfileSheetContent(),
  );
}

class _ProfileSheetContent extends ConsumerWidget {
  const _ProfileSheetContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profilesAsync = ref.watch(allProfilesProvider);
    final activeId = ref.watch(activeProfileIdProvider);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 16),
              child: Text(
                'Cambiar perfil',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            profilesAsync.when(
              data: (profiles) {
                if (profiles.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('No hay perfiles aún')),
                  );
                }
                return Column(
                  children: [
                    ...profiles.map(
                      (p) => _ProfileTile(
                        profile: p,
                        isActive: p.id == activeId,
                        onTap: () {
                          ref
                              .read(profileNotifierProvider.notifier)
                              .switchProfile(p.id!);
                          AdaptiveToast.show(
                            context,
                            message:
                                'Perfil cambiado a ${p.firstName} ${p.lastName}'
                                    .trim(),
                          );
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    _AddProfileTile(
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const OnboardingScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('Error al cargar perfiles')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final Profile profile;
  final bool isActive;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.profile,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isActive
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                _ProfileAvatar(profile: profile, size: 44),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${profile.firstName} ${profile.lastName}'.trim(),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (profile.category.isNotEmpty)
                        Text(
                          profile.category,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Activo',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else
                  Icon(
                    CupertinoIcons.chevron_right,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddProfileTile extends StatelessWidget {
  final VoidCallback onTap;

  const _AddProfileTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.4),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                ),
                child: Icon(
                  CupertinoIcons.person_add,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Añadir perfil',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                size: 16,
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final Profile profile;
  final double size;

  const _ProfileAvatar({required this.profile, required this.size});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final photoUri = profile.photoUri;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: _buildContent(theme, photoUri),
    );
  }

  Widget _buildContent(ThemeData theme, String? photoUri) {
    if (photoUri != null && photoUri.isNotEmpty) {
      ImageProvider? provider;
      if (photoUri.startsWith('http')) {
        provider = NetworkImage(photoUri);
      } else if (photoUri.startsWith('assets/')) {
        provider = AssetImage(photoUri);
      } else if (File(photoUri).existsSync()) {
        provider = FileImage(File(photoUri));
      }
      if (provider != null) {
        return ClipOval(
          key: ValueKey('photo-${profile.id}'),
          child: Image(
            image: provider,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _avatarFallback(theme),
          ),
        );
      }
    }
    return _avatarFallback(theme);
  }

  Widget _avatarFallback(ThemeData theme) {
    final categoryOption =
        kCategoryOptions.where((o) => o.value == profile.category).firstOrNull;

    return Container(
      key: ValueKey('${profile.id}-${profile.category}'),
      width: size,
      height: size,
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
              width: size * 0.5,
              height: size * 0.5,
            )
          : _initialsText(theme),
    );
  }

  Widget _initialsText(ThemeData theme) {
    final first = profile.firstName.trim();
    final last = profile.lastName.trim();
    final text = (first.isEmpty && last.isEmpty)
        ? '?'
        : last.isEmpty
            ? first[0].toUpperCase()
            : '${first[0]}${last[0]}'.toUpperCase();
    return Text(
      text,
      style: TextStyle(
        color: theme.colorScheme.onPrimary,
        fontSize: size * 0.38,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
