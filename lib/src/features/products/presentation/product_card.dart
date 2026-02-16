// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sarqyt/src/common_widgets/alert_dialogs.dart';
import 'package:sarqyt/src/common_widgets/primary_button.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/products/domain/product.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, this.onPublish});

  final Product product;
  final VoidCallback? onPublish;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Sizes.p12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                MyCachedNetworkImage(imageUrl: product.imageUrl),
                Positioned(
                  top: Sizes.p8,
                  right: Sizes.p8,
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.8),
                    shape: const CircleBorder(),
                    child: IconButton(
                      tooltip: 'Edit',
                      iconSize: 20,
                      icon: const Icon(Icons.edit, color: Colors.black87),
                      onPressed: () =>
                          showNotImplementedAlertDialog(context: context),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Контент
          Padding(
            padding: const EdgeInsets.all(Sizes.p12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Название
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                gapH4,
                // Описание
                Text(
                  product.description ?? 'No description',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                gapH8,
                Text(product.priceWithCurrency),

                gapH16,

                SizedBox(
                  width: double.infinity,
                  child: PrimaryWebButton(
                    text: 'Publish order'.hardcoded,
                    onPressed: onPublish,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MyCachedNetworkImage extends StatelessWidget {
  const MyCachedNetworkImage({super.key, this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl ?? '',
      placeholder: (context, url) => SizedBox.expand(
        child: Image.asset('assets/icons/food-placeholder.png'),
      ),
      errorWidget: (context, url, error) =>
          SizedBox.expand(child: Image.asset('assets/icons/error-image.png')),
      fit: BoxFit.cover,
    );
  }
}
