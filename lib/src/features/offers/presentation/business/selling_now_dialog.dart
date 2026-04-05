import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/offers/data/business_offer_repository.dart';
import 'package:sarqyt/src/features/offers/domain/offer.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

class SellingNowDialog extends ConsumerStatefulWidget {
  const SellingNowDialog({super.key, required this.offer});

  final Offer offer;

  @override
  ConsumerState<SellingNowDialog> createState() => _SellingNowDialogState();
}

class _SellingNowDialogState extends ConsumerState<SellingNowDialog> {
  late int _quantity = widget.offer.quantity;
  bool _isSaving = false;

  int get _sold {
    // Original quantity from schedule minus current available
    // We don't track original, so show 0 for now
    return 0;
  }

  Future<void> _save() async {
    if (_quantity == widget.offer.quantity) {
      Navigator.pop(context);
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref.read(businessOfferRepositoryProvider).updateOfferQuantity(
            offerId: widget.offer.id,
            quantity: _quantity,
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(Sizes.p24),
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Surprise Bags for sale'.hardcoded,
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              gapH16,
              Text(
                'Sold: $_sold'.hardcoded,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: Colors.grey),
              ),
              gapH24,

              // Quantity adjuster
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _CircleButton(
                      icon: Icons.remove,
                      onPressed: _isSaving || _quantity <= 0
                          ? null
                          : () => setState(() => _quantity--),
                    ),
                    gapW16,
                    Container(
                      width: 60,
                      padding: const EdgeInsets.symmetric(
                        vertical: Sizes.p8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(Sizes.p4),
                      ),
                      child: Text(
                        '$_quantity',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    gapW16,
                    _CircleButton(
                      icon: Icons.add,
                      onPressed: _isSaving || _quantity >= 99
                          ? null
                          : () => setState(() => _quantity++),
                    ),
                  ],
                ),
              ),
              gapH4,
              Center(
                child: Text(
                  'Total Surprise Bags'.hardcoded,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.grey),
                ),
              ),
              gapH24,

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Sizes.p24),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: Sizes.p12),
                  ),
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text('Save'.hardcoded),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onPressed != null ? AppColors.primary : Colors.grey.shade300,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(Sizes.p12),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}
