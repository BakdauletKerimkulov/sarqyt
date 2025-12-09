import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/common_widgets/alert_dialogs.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/offers/presentation/home_app_bar/shopping_cart_icon.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

class HomeAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      leading: IconButton(
        onPressed: () => showNotImplementedAlertDialog(context: context),
        icon: Icon(Icons.menu),
      ),
      title: Text(
        'Sarqyt'.hardcoded,
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: Sizes.p24),
      ),
      actions: [
        ShoppingCartIcon(),
        // TODO: Добавить отдельную кнопку фильтра, который показывает кол-во выбранных фильтров
        IconButton(
          onPressed: () => showNotImplementedAlertDialog(context: context),
          icon: Icon(Icons.tune),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60.0);
}
