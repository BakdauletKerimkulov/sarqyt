import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sarqyt/src/constants/app_colors.dart';

class InlineTextLink extends StatelessWidget {
  const InlineTextLink({
    super.key,
    required this.text,
    required this.linkText,
    this.onTap,
    this.textStyle,
    this.linkStyle,
    this.textAlign = TextAlign.start,
  });

  final String text;
  final String linkText;
  final TextStyle? textStyle;
  final TextStyle? linkStyle;
  final TextAlign textAlign;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = textStyle ?? theme.textTheme.bodyMedium!;
    final resolvedLinkStyle =
        linkStyle ??
        baseStyle.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        );

    return Center(
      child: RichText(
        text: TextSpan(
          style: baseStyle,
          children: [
            TextSpan(text: text),
            TextSpan(
              text: linkText,
              style: resolvedLinkStyle,
              recognizer: TapGestureRecognizer()..onTap = onTap,
            ),
          ],
        ),
      ),
    );
  }
}
