import 'package:flutter/material.dart';
import 'package:sarqyt/src/common_widgets/custom_image.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/constants/breakpoints.dart';
import 'package:sarqyt/src/features/items/domain/item.dart';
import 'package:sarqyt/src/features/items/presentation/item_screen/item_settings_shared.dart';

class ItemDetails extends StatelessWidget {
  const ItemDetails({super.key, required this.item, this.storeName});

  final Item item;
  final String? storeName;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StoreHeaderCard(
          imageUrl: item.imageUrl,
          storeName: storeName,
        ),
        gapH16,
        DetailRow(
          label: 'Name',
          child: Text(item.name, style: textTheme.bodyMedium),
        ),
        gapH16,
        DetailRow(
          label: 'Description',
          child: Text(item.description ?? 'No description',
              style: textTheme.bodyMedium),
        ),
        gapH16,
        DetailRow(
          label: 'Category',
          child: Text(item.category ?? '-', style: textTheme.bodyMedium),
        ),
        gapH16,
        DetailRow(
          label: 'Dietary type',
          child:
              Text(item.dietaryType.label, style: textTheme.bodyMedium),
        ),
        gapH16,
        DetailRow(
          label: 'Price',
          child: Text(
            '${item.price.round()}',
            style: textTheme.bodyMedium,
          ),
        ),
        if (item.estimatedValue != null) ...[
          gapH16,
          DetailRow(
            label: 'Estimated value',
            child: Text(
              '${item.estimatedValue!.round()} (-${item.discountPercent}%)',
              style: textTheme.bodyMedium,
            ),
          ),
        ],
      ],
    );
  }
}

class StoreHeaderCard extends StatelessWidget {
  const StoreHeaderCard({
    super.key,
    this.imageUrl,
    this.storeName,
    this.onEditPressed,
  });

  final String? imageUrl;
  final String? storeName;
  /// Receives the [BuildContext] of the edit button for menu positioning.
  final void Function(BuildContext buttonContext)? onEditPressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final imageHeight = width / 2;

        final double avatarSize =
            constraints.maxWidth > Breakpoint.mobile ? 100 : 60;

        final avatarTop = imageHeight - avatarSize / 2;
        final stackHeight = imageHeight + avatarSize / 2;

        return SizedBox(
          height: stackHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(Sizes.p16),
                child: CustomImage(imageUrl: imageUrl, aspectRatio: 2),
              ),
              if (onEditPressed != null)
                Positioned(
                  top: Sizes.p16,
                  right: Sizes.p16,
                  child: Builder(
                    builder: (buttonContext) => IconButton.filled(
                      style: const ButtonStyle(
                        backgroundColor:
                            WidgetStatePropertyAll(AppColors.primary),
                      ),
                      onPressed: () => onEditPressed!(buttonContext),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                  ),
                ),
              Positioned(
                top: avatarTop,
                left: 0,
                right: 0,
                child: Center(
                  child: StoreAvatar(storeName: storeName, size: avatarSize),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class StoreAvatar extends StatelessWidget {
  const StoreAvatar({super.key, required this.storeName, required this.size});

  final String? storeName;
  final double size;

  static const _avatarColors = [
    Color(0xFF6750A4),
    Color(0xFF006C4C),
    Color(0xFFB3261E),
    Color(0xFF1D4ED8),
    Color(0xFF9A3412),
    Color(0xFF374151),
  ];

  String get _avatarLetter {
    final trimmed = storeName?.trim();
    if (trimmed == null || trimmed.isEmpty) return '?';
    return trimmed.characters.first.toUpperCase();
  }

  Color get _avatarBackgroundColor {
    final seed = storeName?.trim();
    if (seed == null || seed.isEmpty) return _avatarColors.first;
    final index = seed.hashCode.abs() % _avatarColors.length;
    return _avatarColors[index];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _avatarBackgroundColor,
        border: Border.all(width: 2, color: Colors.white),
      ),
      child: Text(
        _avatarLetter,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: size * 0.6,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
