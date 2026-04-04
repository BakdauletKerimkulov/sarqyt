import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sarqyt/src/common_widgets/primary_button.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/auth/utils/auth_layout.dart';
import 'package:sarqyt/src/features/items/domain/money.dart';
import 'package:sarqyt/src/features/items/presentation/item_create/item_draft_controller.dart';
import 'package:sarqyt/src/features/onboarding/presentation/onboarding_panel.dart';
import 'package:sarqyt/src/routing/business_router.dart';

class PriceAndStockScreen extends StatelessWidget {
  const PriceAndStockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      startBackground: 'assets/sarqyt_item.png',
      child: OnboardingPanel(
        topSpacerHeight: 100,
        bottomSpacerHeight: 100,
        title: 'Set the price and daily stock of your items',
        onBackPressed: () => context.pop(),
        child: const PriceAndStockContent(),
      ),
    );
  }
}

class PriceAndStockContent extends ConsumerStatefulWidget {
  const PriceAndStockContent({super.key});

  @override
  ConsumerState<PriceAndStockContent> createState() =>
      _PriceAndStockContentState();
}

class _PriceAndStockContentState extends ConsumerState<PriceAndStockContent> {
  final _priceController = TextEditingController();
  final _estimatedValueController = TextEditingController();
  String? _priceError;

  static const _stockOptions = [
    _StockOption(value: 3, icon: Icons.shopping_bag_outlined),
    _StockOption(value: 5, icon: Icons.shopping_bag),
    _StockOption(value: 7, icon: Icons.luggage),
  ];
  static const _defaultStock = 5;

  double get _price => double.tryParse(_priceController.text) ?? 0;
  double? get _estimatedValue {
    final text = _estimatedValueController.text;
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  int? get _calculatedDiscount {
    final ev = _estimatedValue;
    if (_price <= 0 || ev == null || ev <= 0) return null;
    final percent = ((1 - (_price / ev)) * 100).round();
    return percent.clamp(0, 100);
  }

  @override
  void initState() {
    super.initState();
    final draft = ref.read(itemDraftControllerProvider);
    if (draft.price != null && draft.price! > 0) {
      _priceController.text = draft.price!.round().toString();
    }
    if (draft.estimatedValue != null && draft.estimatedValue! > 0) {
      _estimatedValueController.text = draft.estimatedValue!.round().toString();
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _estimatedValueController.dispose();
    super.dispose();
  }

  String? _validateAndSave() {
    if (_priceController.text.isEmpty) return 'Введите цену';
    if (_price <= 0) return 'Цена должна быть больше 0';

    final ev = _estimatedValue;
    if (ev != null && ev <= _price) {
      return 'Примерная стоимость должна быть больше цены';
    }

    final controller = ref.read(itemDraftControllerProvider.notifier);
    controller.savePrice(_price);
    if (ev != null) {
      controller.saveEstimatedValue(ev);
    }

    final stock =
        ref.read(itemDraftControllerProvider.select((d) => d.defaultDailyStock)) ??
        _defaultStock;
    controller.saveDefaultDailyStock(stock);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final quantity =
        ref.watch(itemDraftControllerProvider.select((d) => d.defaultDailyStock)) ??
        _defaultStock;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // --- Price section ---
        Text('Цена покупателя', style: textTheme.titleSmall),
        gapH12,
        TextField(
          controller: _priceController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            suffixText: Currency.kzt.symbol,
            errorText: _priceError,
            border: const OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {
            _priceError = null;
          }),
        ),
        gapH4,
        Text(
          'Цена, по которой покупатель приобретёт товар.',
          style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
        ),

        gapH24,

        // --- Estimated value section ---
        Text('Примерная стоимость', style: textTheme.titleSmall),
        gapH12,
        TextField(
          controller: _estimatedValueController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            suffixText: Currency.kzt.symbol,
            border: const OutlineInputBorder(),
            hintText: 'Необязательно',
          ),
          onChanged: (_) => setState(() {}),
        ),
        gapH4,
        Text(
          'Розничная стоимость содержимого (необязательно).',
          style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
        ),

        // --- Calculated discount display ---
        if (_calculatedDiscount != null) ...[
          gapH12,
          Container(
            padding: const EdgeInsets.all(Sizes.p12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(Sizes.p8),
            ),
            child: Text(
              'Скидка: $_calculatedDiscount%',
              style: textTheme.titleSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],

        gapH24,

        // --- Stock section ---
        Text('Daily stock', style: textTheme.titleSmall),
        gapH4,
        Text(
          'How many surprise bags can you prepare each day?',
          style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
        ),
        gapH12,
        RadioGroup<int>(
          groupValue: quantity,
          onChanged: (value) {
            if (value == null) return;
            ref.read(itemDraftControllerProvider.notifier).saveDefaultDailyStock(value);
          },
          child: Row(
            children: _stockOptions
                .map(
                  (option) => Expanded(
                    child: _StockCard(
                      option: option,
                      selected: quantity == option.value,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        gapH16,
        PrimaryWebButton(
          text: 'Continue',
          onPressed: () {
            final error = _validateAndSave();
            if (error != null) {
              setState(() => _priceError = error);
              return;
            }
            context.pushNamed(BusinessRoute.schedule.name);
          },
        ),
      ],
    );
  }
}

class _StockOption {
  const _StockOption({required this.value, required this.icon});

  final int value;
  final IconData icon;
}

class _StockCard extends StatelessWidget {
  const _StockCard({required this.option, required this.selected});

  final _StockOption option;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sizes.p4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(Sizes.p16),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(Sizes.p12),
              border: selected
                  ? Border.all(color: AppColors.primary, width: 2)
                  : null,
            ),
            child: Icon(
              option.icon,
              size: Sizes.p48,
              color: selected ? AppColors.primary : colors.onSurfaceVariant,
            ),
          ),
          gapH8,
          Text('${option.value}', style: Theme.of(context).textTheme.bodySmall),
          Radio<int>(value: option.value),
        ],
      ),
    );
  }
}
