import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme.dart';

/// [TissueImageGallery] — Thumbnail Grids and Lightbox zooming
/// Intended to parse Supabase URLs natively or standard flutter `ImageProvider`s.
class TissueImageGallery extends StatelessWidget {
  final List<String> imageUrls;
  final BoxFit fit;

  const TissueImageGallery({
    super.key,
    required this.imageUrls,
    this.fit = BoxFit.cover,
  });

  void _openLightbox(BuildContext context, int initialIndex) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      barrierDismissible: true,
      barrierLabel: 'Close Image',
      pageBuilder: (context, _, __) {
        return _LightboxView(imageUrls: imageUrls, initialIndex: initialIndex);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 150,
        crossAxisSpacing: OrganismTheme.spacingSm,
        mainAxisSpacing: OrganismTheme.spacingSm,
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _openLightbox(context, index),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: OrganismTheme.borderMd,
              border: Border.all(color: OrganismTheme.colorsOf(context).border),
              image: DecorationImage(
                image: NetworkImage(imageUrls[index]),
                fit: fit,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LightboxView extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const _LightboxView({required this.imageUrls, required this.initialIndex});

  @override
  State<_LightboxView> createState() => _LightboxViewState();
}

class _LightboxViewState extends State<_LightboxView> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PhotoViewGallery.builder(
          scrollPhysics: const BouncingScrollPhysics(),
          builder: (BuildContext context, int index) {
            return PhotoViewGalleryPageOptions(
              imageProvider: NetworkImage(widget.imageUrls[index]),
              initialScale: PhotoViewComputedScale.contained,
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
            );
          },
          itemCount: widget.imageUrls.length,
          pageController: PageController(initialPage: widget.initialIndex),
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundDecoration: const BoxDecoration(color: Colors.transparent),
        ),
        
        // Header
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.all(OrganismTheme.spacingMd),
              color: Colors.black.withValues(alpha: 0.3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_currentIndex + 1} / ${widget.imageUrls.length}',
                    style: OrganismTheme.bodyLarge(context).copyWith(color: Colors.white),
                  ),
                  IconButton(
                    icon: Icon(LucideIcons.x, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ),
            ),
          ),
        ),

        // Carousel preview
        if (widget.imageUrls.length > 1)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
                padding: const EdgeInsets.symmetric(vertical: OrganismTheme.spacingMd),
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 80,
                    viewportFraction: 0.2,
                    initialPage: widget.initialIndex,
                    enableInfiniteScroll: false,
                    enlargeCenterPage: true,
                  ),
                  items: widget.imageUrls.map((url) {
                    final index = widget.imageUrls.indexOf(url);
                    return GestureDetector(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _currentIndex == index ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                          image: DecorationImage(
                            image: NetworkImage(url),
                            fit: BoxFit.cover,
                          )
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          )
      ],
    );
  }
}
