// lib/features/reviews/widgets/review_submission_form.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/review_controller.dart';
import '../../../core/constants/colors.dart';
import 'rating_display.dart';

class ReviewSubmissionForm extends StatefulWidget {
  final String productId;
  final String productName;
  final VoidCallback? onSubmitted;

  const ReviewSubmissionForm({
    super.key,
    required this.productId,
    required this.productName,
    this.onSubmitted,
  });

  @override
  State<ReviewSubmissionForm> createState() => _ReviewSubmissionFormState();
}

class _ReviewSubmissionFormState extends State<ReviewSubmissionForm>
    with SingleTickerProviderStateMixin {
  final ReviewController reviewController = Get.find<ReviewController>();
  final TextEditingController commentController = TextEditingController();
  double selectedRating = 0;
  bool isExpanded = false;
  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    commentController.dispose();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TColors.primary.withAlpha((0.05 * 255).toInt()),
            Colors.blue.withAlpha((0.05 * 255).toInt()),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TColors.primary.withAlpha((0.2 * 255).toInt())),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
              if (isExpanded) {
                animationController.forward();
              } else {
                animationController.reverse();
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [TColors.primary, TColors.primary.withAlpha((0.8 * 255).toInt())],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.rate_review,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Share Your Experience',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Help others by reviewing ${widget.productName}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.expand_more,
                      color: TColors.primary,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expandable form
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: animation.value,
                  child: child,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 16),

                  // Rating selector
                  const Text(
                    'Rate this product',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      InteractiveRatingInput(
                        initialRating: selectedRating,
                        onRatingChanged: (rating) {
                          setState(() {
                            selectedRating = rating;
                          });
                        },
                        size: 36,
                      ),
                      const SizedBox(width: 16),
                      if (selectedRating > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getRatingColor(selectedRating).withAlpha((0.1 * 255).toInt()),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _getRatingColor(selectedRating).withAlpha((0.3 * 255).toInt()),
                            ),
                          ),
                          child: Text(
                            _getRatingText(selectedRating),
                            style: TextStyle(
                              color: _getRatingColor(selectedRating),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Comment field
                  const Text(
                    'Write your review',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextFormField(
                      controller: commentController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Tell others about your experience with this product...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit button
                  Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selectedRating > 0 && !reviewController.isLoading.value
                          ? _submitReview
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: reviewController.isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.send, size: 18),
                                const SizedBox(width: 8),
                                const Text(
                                  'Submit Review',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4) return Colors.green;
    if (rating >= 3) return Colors.orange;
    return Colors.red;
  }

  String _getRatingText(double rating) {
    if (rating >= 4.5) return 'Excellent';
    if (rating >= 4) return 'Very Good';
    if (rating >= 3) return 'Good';
    if (rating >= 2) return 'Fair';
    return 'Poor';
  }

  Future<void> _submitReview() async {
    if (selectedRating == 0) {
      Get.snackbar('Error', 'Please select a rating');
      return;
    }

    final success = await reviewController.submitReview(
      productId: widget.productId,
      rating: selectedRating,
      comment: commentController.text.trim(),
    );

    if (success && mounted) {  // Check if widget is still mounted before calling setState
      setState(() {
        selectedRating = 0;
        commentController.clear();
        isExpanded = false;
      });
      animationController.reverse();
      widget.onSubmitted?.call();
    }
  }
}
