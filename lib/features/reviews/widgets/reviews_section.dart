// lib/features/reviews/widgets/reviews_section.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/review_controller.dart';
import '../../../core/constants/colors.dart';
import 'rating_statistics.dart';
import 'review_card.dart';
import 'review_submission_form.dart';

class ReviewsSection extends StatefulWidget {
  final String productId;
  final String productName;

  const ReviewsSection({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<ReviewsSection> {
  final ReviewController reviewController = Get.put(ReviewController());
  bool showAllReviews = false;
  String sortBy = 'newest';

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    await reviewController.getProductReviews(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber, Colors.orange],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.reviews,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Customer Reviews',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        Obx(() {
          if (reviewController.isLoading.value && reviewController.productReviews.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          return Column(
            children: [
              // Rating Statistics
              RatingStatistics(stats: reviewController.ratingStats.value),
              const SizedBox(height: 24),

              // Review Submission Form (only if user can review)
              FutureBuilder<bool>(
                future: reviewController.canUserReviewProduct(widget.productId),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data == true) {
                    return ReviewSubmissionForm(
                      productId: widget.productId,
                      productName: widget.productName,
                      onSubmitted: _loadReviews,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              // Reviews List Header
              if (reviewController.productReviews.isNotEmpty) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text(
                      'Reviews (${reviewController.productReviews.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    // Sort dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: sortBy,
                          icon: const Icon(Icons.sort, size: 16),
                          isDense: true,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                          onChanged: (value) {
                            setState(() {
                              sortBy = value!;
                              _sortReviews();
                            });
                          },
                          items: const [
                            DropdownMenuItem(
                              value: 'newest',
                              child: Text('Newest First'),
                            ),
                            DropdownMenuItem(
                              value: 'oldest',
                              child: Text('Oldest First'),
                            ),
                            DropdownMenuItem(
                              value: 'highest',
                              child: Text('Highest Rating'),
                            ),
                            DropdownMenuItem(
                              value: 'lowest',
                              child: Text('Lowest Rating'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Reviews List
              if (reviewController.productReviews.isEmpty)
                _buildEmptyState()
              else
                _buildReviewsList(),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No reviews yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to share your thoughts about this product!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsList() {
    final reviews = reviewController.productReviews;
    final displayReviews = showAllReviews ? reviews : reviews.take(3).toList();

    return Column(
      children: [
        // Reviews
        ...displayReviews.map((review) => ReviewCard(
          review: review,
          onDelete: _loadReviews,
        )),

        // Show more/less button
        if (reviews.length > 3) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  showAllReviews = !showAllReviews;
                });
              },
              icon: Icon(
                showAllReviews ? Icons.expand_less : Icons.expand_more,
                color: TColors.primary,
              ),
              label: Text(
                showAllReviews
                    ? 'Show Less'
                    : 'Show All ${reviews.length} Reviews',
                style: TextStyle(
                  color: TColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: TColors.primary.withAlpha((0.3 * 255).toInt())),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _sortReviews() {
    final reviews = reviewController.productReviews;

    switch (sortBy) {
      case 'newest':
        reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'oldest':
        reviews.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'highest':
        reviews.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'lowest':
        reviews.sort((a, b) => a.rating.compareTo(b.rating));
        break;
    }

    reviewController.productReviews.refresh();
  }
}
