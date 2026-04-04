import 'package:flutter/material.dart';
import 'package:sarqyt/src/common_widgets/outlined_section_widget.dart';
import 'package:sarqyt/src/common_widgets/primary_button.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/items/domain/item.dart';
import 'package:sarqyt/src/features/items/domain/weekly_schedule.dart';

class SavingsCard extends StatefulWidget {
  const SavingsCard({
    super.key,
    required this.item,
    required this.maxDayQuantity,
    required this.onUpdateDailyQuantity,
  });

  final Item item;
  final int maxDayQuantity;
  final ValueChanged<int>? onUpdateDailyQuantity;

  @override
  State<SavingsCard> createState() => _SavingsCardState();
}

class _SavingsCardState extends State<SavingsCard> {
  /// Slider value: how many extra bags to add (1..10).
  double _extraBags = 1;

  int get _newQuantity => widget.maxDayQuantity + _extraBags.round();

  bool get _canUpdate => _newQuantity <= DaySchedule.maxQuantity;

  @override
  void initState() {
    super.initState();
    _extraBags = 1;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final item = widget.item;
    final price = item.price;
    final estimatedValue = item.estimatedValue ?? price;

    final totalBags = _newQuantity.toDouble();

    // Savings = difference between estimated value and price × bags × 365
    final savingsPerBag = estimatedValue - price;
    final moneySaved = totalBags * savingsPerBag * 365;
    final bagsPerYear = (totalBags * 365).round();
    final co2Saved = (bagsPerYear * 2.7).round();
    final showerHours = (co2Saved / 18.9).round();

    return OutlinedSectionWidgetWithHeader(
      header: 'Every ${item.name} counts',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Calculate how much money you can save and how much CO2e you can avoid yearly by adding extra ${item.name}s',
            style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
          ),
          gapH16,

          // Green money saved banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: Sizes.p16,
              vertical: Sizes.p20,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(Sizes.p12),
            ),
            child: Column(
              children: [
                Text(
                  _formatNumber(moneySaved),
                  style: textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                gapH4,
                Text(
                  'Сохранено за год',
                  style: textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          gapH16,

          // Stats
          _StatRow(
            icon: Icons.shower_outlined,
            value: _formatNumber(showerHours.toDouble()),
            label: 'hrs of hot showers',
          ),
          gapH4,
          _StatRow(
            icon: Icons.eco_outlined,
            value: _formatNumber(co2Saved.toDouble()),
            label: 'kg of CO2e avoided per year',
          ),
          gapH12,
          _StatRow(
            icon: Icons.shopping_bag_outlined,
            value: _formatNumber(bagsPerYear.toDouble()),
            label: '${item.name}s saved per year',
          ),
          gapH20,

          // Slider
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primary,
              thumbColor: Colors.white,
              overlayColor: AppColors.primary.withValues(alpha: 0.1),
              inactiveTrackColor: Colors.grey.shade300,
            ),
            child: Slider(
              value: _extraBags,
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: (v) => setState(() => _extraBags = v),
            ),
          ),
          Center(
            child: Text(
              '${_extraBags.round()} ${item.name}(s) per day',
              style: textTheme.bodySmall?.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          gapH16,

          // Disclaimer
          Container(
            padding: const EdgeInsets.all(Sizes.p12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(Sizes.p8),
            ),
            child: Text(
              'This number is a close estimate and can be achieved if all of your listed ${item.name}s get saved over a one-year period.',
              style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
          ),
          gapH16,
          PrimaryWebButton(
            text: 'Update daily quantity to $_newQuantity',
            onPressed: _canUpdate
                ? () => widget.onUpdateDailyQuantity?.call(_newQuantity)
                : null,
          ),
        ],
      ),
    );
  }

  String _formatNumber(double n) {
    if (n >= 1000) {
      return n
          .toStringAsFixed(n.truncateToDouble() == n ? 0 : 2)
          .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},',
          );
    }
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 2);
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        gapW8,
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              TextSpan(
                text: ' $label',
                style: TextStyle(color: AppColors.primary),
              ),
            ],
          ),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
