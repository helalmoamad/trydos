// `hide`: easy_localization re-exports intl's `TextDirection`.
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import '../boutique_form.dart';
import 'boutique_availability_section.dart';

/// The banners of one language: 16:9 tiles in order, then a dashed
/// **Add banner** tile. Always laid out left to right, also in Arabic and
/// Kurdish, like the website (AC-28).
class BoutiqueBannerGrid extends StatelessWidget {
  final List<BannerItem> banners;
  final bool editing;
  final int pending;
  final VoidCallback onAdd;
  final void Function(int index, int delta) onMove;
  final ValueChanged<int> onRemove;

  const BoutiqueBannerGrid({
    super.key,
    required this.banners,
    required this.editing,
    required this.pending,
    required this.onAdd,
    required this.onMove,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final int columns = constraints.maxWidth >= 600 ? 2 : 1;
          const double gap = 12;
          final double tileWidth =
              (constraints.maxWidth - gap * (columns - 1)) / columns;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: <Widget>[
              for (int i = 0; i < banners.length; i++)
                SizedBox(
                  width: tileWidth,
                  child: _BannerTile(
                    banner: banners[i],
                    index: i,
                    count: banners.length,
                    editing: editing,
                    decodeWidth: tileWidth.round(),
                    onMove: onMove,
                    onRemove: onRemove,
                  ),
                ),
              if (editing)
                SizedBox(
                  width: tileWidth,
                  child: _AddBannerTile(pending: pending, onTap: onAdd),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _BannerTile extends StatelessWidget {
  final BannerItem banner;
  final int index;
  final int count;
  final bool editing;
  final int decodeWidth;
  final void Function(int index, int delta) onMove;
  final ValueChanged<int> onRemove;

  const _BannerTile({
    required this.banner,
    required this.index,
    required this.count,
    required this.editing,
    required this.decodeWidth,
    required this.onMove,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: BoutiqueColors.field,
            border: Border.all(color: BoutiqueColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              BoutiquePreviewImage(
                localPath: banner.localPath,
                storedValue: banner.previewUrl ?? banner.fileName,
                legacyFolder: 'boutiques/boutiques',
                decodeWidth: decodeWidth,
                placeholder: Icons.image_outlined,
              ),
              if (editing)
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 8,
                  child: Row(
                    children: [
                      _TileButton(
                        icon: Icons.arrow_back,
                        onTap: index > 0 ? () => onMove(index, -1) : null,
                      ),
                      const SizedBox(width: 6),
                      _TileButton(
                        icon: Icons.arrow_forward,
                        onTap: index < count - 1
                            ? () => onMove(index, 1)
                            : null,
                      ),
                      const Spacer(),
                      _TileButton(
                        icon: Icons.delete_outline,
                        color: BoutiqueColors.error,
                        onTap: () => onRemove(index),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TileButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;

  const _TileButton({
    required this.icon,
    required this.onTap,
    this.color = BoutiqueColors.text,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: onTap == null ? 0.6 : 0.95),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 18,
            color: onTap == null ? BoutiqueColors.muted : color,
          ),
        ),
      ),
    );
  }
}

class _AddBannerTile extends StatelessWidget {
  final int pending;
  final VoidCallback onTap;

  const _AddBannerTile({required this.pending, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool busy = pending > 0;
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: CustomPaint(
        painter: const _DashedBorderPainter(),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: busy ? null : onTap,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (busy)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  const Icon(Icons.add, size: 22, color: BoutiqueColors.muted),
                const SizedBox(height: 6),
                Text(
                  busy
                      ? LocaleKeys.boutique_uploading.tr(args: ['$pending'])
                      : LocaleKeys.boutique_add_banner.tr(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: BoutiqueColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFFD9D9DE)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final Path path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(12),
        ),
      );
    const double dash = 6;
    const double gap = 4;
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dash),
          paint,
        );
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
