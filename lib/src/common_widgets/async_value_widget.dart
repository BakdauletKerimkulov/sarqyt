import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:sarqyt/src/common_widgets/error_message_widget.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';

/// A reusable widget to provide default loading and error widgets when working
/// with AsyncValue.
/// More info here:
/// https://codewithandrea.com/articles/async-value-widget-riverpod/
class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({super.key, required this.value, required this.data});
  final AsyncValue<T> value;
  final Widget Function(T) data;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      error: (e, st) {
        debugPrint(st.toString());
        return Center(child: ErrorMessageWidget(e.toString()));
      },

      loading: () => Center(
        child: LottieBuilder.asset(
          'assets/animations/food-animation.json',
          width: Sizes.p48,
          height: Sizes.p48,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

/// Sliver equivalent of [AsyncValueWidget]
class AsyncValueSliverWidget<T> extends StatelessWidget {
  const AsyncValueSliverWidget({
    super.key,
    required this.value,
    required this.data,
  });
  final AsyncValue<T> value;
  final Widget Function(T) data;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () => SliverToBoxAdapter(
        child: Center(
          child: LottieBuilder.asset(
            'assets/animations/food-animation.json',
            width: Sizes.p48,
            height: Sizes.p48,
          ),
        ),
      ),
      error: (e, st) => SliverToBoxAdapter(
        child: Center(child: ErrorMessageWidget(e.toString())),
      ),
    );
  }
}
