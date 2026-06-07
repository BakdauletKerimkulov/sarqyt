import 'package:flutter/material.dart';

/// Reusable animated heart button for favorite toggle.
///
/// Shows a scale bounce animation (1.0 → 1.2 → 1.0) on tap.
/// Displays `Icons.favorite` (red) when favorited,
/// `Icons.favorite_border` (white) when not.
class AnimatedFavoriteButton extends StatefulWidget {
  const AnimatedFavoriteButton({
    super.key,
    required this.isFavorite,
    required this.storeName,
    this.onToggle,
  });

  final bool isFavorite;
  final String storeName;
  final VoidCallback? onToggle;

  @override
  State<AnimatedFavoriteButton> createState() => _AnimatedFavoriteButtonState();
}

class _AnimatedFavoriteButtonState extends State<AnimatedFavoriteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.2),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 1.0),
        weight: 50,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onToggle == null) return;
    _controller.forward(from: 0);
    widget.onToggle!();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Icon(
          widget.isFavorite ? Icons.favorite : Icons.favorite_border,
          color: widget.isFavorite ? Colors.red : Colors.white,
          size: 28,
          shadows: const [
            Shadow(blurRadius: 4, color: Colors.black45),
          ],
          semanticLabel: widget.isFavorite
              ? 'Remove from favorites'
              : 'Add to favorites',
        ),
      ),
    );
  }
}
