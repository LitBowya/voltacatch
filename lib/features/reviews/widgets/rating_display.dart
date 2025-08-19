// lib/features/reviews/widgets/rating_display.dart
import 'package:flutter/material.dart';

class RatingDisplay extends StatelessWidget {
  final double rating;
  final int totalReviews;
  final double size;
  final bool showText;
  final MainAxisAlignment alignment;

  const RatingDisplay({
    super.key,
    required this.rating,
    required this.totalReviews,
    this.size = 16,
    this.showText = true,
    this.alignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            return Icon(
              index < rating.floor()
                  ? Icons.star
                  : (index == rating.floor() && rating % 1 != 0)
                      ? Icons.star_half
                      : Icons.star_border,
              color: Colors.amber,
              size: size,
            );
          }),
        ),
        if (showText) ...[
          const SizedBox(width: 8),
          Text(
            '${rating.toStringAsFixed(1)} ($totalReviews rev ${totalReviews != 1 ? 's' : ''})',
            style: TextStyle(
              fontSize: size * 0.8,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class InteractiveRatingInput extends StatefulWidget {
  final double initialRating;
  final Function(double) onRatingChanged;
  final double size;
  final bool enabled;

  const InteractiveRatingInput({
    super.key,
    this.initialRating = 0,
    required this.onRatingChanged,
    this.size = 32,
    this.enabled = true,
  });

  @override
  State<InteractiveRatingInput> createState() => _InteractiveRatingInputState();
}

class _InteractiveRatingInputState extends State<InteractiveRatingInput>
    with SingleTickerProviderStateMixin {
  late double _currentRating;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: widget.enabled
              ? () {
                  setState(() {
                    _currentRating = (index + 1).toDouble();
                  });
                  _animationController.forward().then((_) {
                    _animationController.reverse();
                  });
                  widget.onRatingChanged(_currentRating);
                }
              : null,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_animationController.value * 0.2),
                child: Icon(
                  index < _currentRating ? Icons.star : Icons.star_border,
                  color: index < _currentRating ? Colors.amber : Colors.grey[400],
                  size: widget.size,
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
