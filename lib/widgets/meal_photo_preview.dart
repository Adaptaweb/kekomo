import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/meal_log_provider.dart';
import '../data/models/meal_photo.dart';

class PhotoInlinePreview extends ConsumerWidget {
  final int profileId;
  final String date;
  final String mealType;

  const PhotoInlinePreview({
    super.key,
    required this.profileId,
    required this.date,
    required this.mealType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosAsync = ref.watch(mealPhotosBySectionProvider(
      MealSectionArgs(profileId: profileId, date: date, mealType: mealType),
    ));

    final photos = photosAsync.maybeWhen(
      data: (list) => list,
      orElse: () => const <MealPhoto>[],
    );

    if (photos.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final total = photos.length;
    final firstPhoto = photos.first;
    final extraCount = total - 1;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _showPhotosCarousel(context, ref, photos),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(firstPhoto.path),
                width: 36,
                height: 36,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.broken_image,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            if (extraCount > 0) ...[
              const SizedBox(width: 6),
              Text(
                '+$extraCount',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showPhotosCarousel(
      BuildContext context, WidgetRef ref, List<MealPhoto> photos) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'PhotoCarousel',
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, _, _) => PhotoCarouselViewer(
        photos: photos,
        onDelete: (photoId) async {
          await ref
              .read(mealLogNotifierProvider.notifier)
              .deletePhoto(photoId, profileId, date, mealType);
        },
      ),
      transitionBuilder: (_, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}

class PhotoCarouselViewer extends StatefulWidget {
  final List<MealPhoto> photos;
  final Future<void> Function(int photoId) onDelete;

  const PhotoCarouselViewer({
    super.key,
    required this.photos,
    required this.onDelete,
  });

  @override
  State<PhotoCarouselViewer> createState() => _PhotoCarouselViewerState();
}

class _PhotoCarouselViewerState extends State<PhotoCarouselViewer> {
  late final PageController _ctrl;
  int _currentIndex = 0;
  late List<MealPhoto> _photos;

  @override
  void initState() {
    super.initState();
    _ctrl = PageController();
    _photos = List<MealPhoto>.from(widget.photos);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _deleteCurrent() async {
    if (_photos.isEmpty) return;
    final current = _photos[_currentIndex];
    final id = current.id;
    if (id == null) return;
    await widget.onDelete(id);
    if (!mounted) return;
    setState(() {
      _photos = List<MealPhoto>.from(_photos)..removeAt(_currentIndex);
    });
    if (_photos.isEmpty) {
      Navigator.pop(context);
      return;
    }
    if (_currentIndex >= _photos.length) {
      _currentIndex = _photos.length - 1;
    }
    if (_ctrl.hasClients) {
      _ctrl.jumpToPage(_currentIndex);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.all(0),
      child: Stack(
        children: [
          PageView.builder(
            controller: _ctrl,
            itemCount: _photos.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Center(
                  child: Image.file(
                    File(_photos[index].path),
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.broken_image,
                      color: Colors.white,
                      size: 64,
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: 40,
            right: 16,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  onPressed: _deleteCurrent,
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentIndex + 1} / ${_photos.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
