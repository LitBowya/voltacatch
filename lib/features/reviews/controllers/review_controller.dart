// lib/features/reviews/controllers/review_controller.dart
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/review_model.dart';
import '../../orders/models/order_model.dart';
import '../../auth/models/user_model.dart';

class ReviewController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxBool isLoading = false.obs;
  final RxList<ReviewModel> productReviews = <ReviewModel>[].obs;
  final Rx<ProductRatingStats> ratingStats = ProductRatingStats.empty().obs;

  // Check if user can review a specific product
  Future<bool> canUserReviewProduct(String productId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Check if user has purchased this product and it's been delivered
      final ordersSnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'delivered')
          .get();

      bool hasPurchased = false;
      for (var orderDoc in ordersSnapshot.docs) {
        final order = OrderModel.fromJson(orderDoc.data(), orderDoc.id);
        if (order.items.any((item) => item.productId == productId)) {
          hasPurchased = true;
          break;
        }
      }

      if (!hasPurchased) return false;

      // Check if user has already reviewed this product
      final existingReview = await _firestore
          .collection('reviews')
          .where('productId', isEqualTo: productId)
          .where('userId', isEqualTo: user.uid)
          .get();

      return existingReview.docs.isEmpty;
    } catch (e) {
      Get.snackbar('Error', 'Error checking review eligibility: $e');

      return false;
    }
  }

  // Get delivered order for a specific product (to link review to order)
  Future<String?> getDeliveredOrderForProduct(String productId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final ordersSnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'delivered')
          .get();

      for (var orderDoc in ordersSnapshot.docs) {
        final order = OrderModel.fromJson(orderDoc.data(), orderDoc.id);
        if (order.items.any((item) => item.productId == productId)) {
          return orderDoc.id;
        }
      }
      return null;
    } catch (e) {
      Get.snackbar('Error', 'Error getting delivered order: $e');

      return null;
    }
  }

  // Submit a new review
  Future<bool> submitReview({
    required String productId,
    required double rating,
    required String comment,
    List<String> images = const [],
  }) async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Get user data
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = UserModel.fromMap(userDoc.data()!, user.uid);

      // Get full name
      String userName = '';
      if (userData.firstName != null && userData.lastName != null) {
        userName = '${userData.firstName} ${userData.lastName}';
      } else if (userData.firstName != null) {
        userName = userData.firstName!;
      } else {
        userName = userData.email.split('@')[0]; // Use email prefix as fallback
      }

      // Get the order ID
      final orderId = await getDeliveredOrderForProduct(productId);
      if (orderId == null) throw Exception('No delivered order found for this product');

      final review = ReviewModel(
        id: '',
        productId: productId,
        userId: user.uid,
        userName: userName,
        userEmail: userData.email,
        orderId: orderId,
        rating: rating,
        comment: comment,
        images: images,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isVerifiedPurchase: true,
      );

      await _firestore.collection('reviews').add(review.toJson());

      // Update product rating stats
      await _updateProductRatingStats(productId);

      Get.snackbar('Success', 'Review submitted successfully!',
          snackPosition: SnackPosition.BOTTOM);
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit review: $e',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Get reviews for a product
  Future<void> getProductReviews(String productId) async {
    try {
      isLoading.value = true;
      final snapshot = await _firestore
          .collection('reviews')
          .where('productId', isEqualTo: productId)
          .orderBy('createdAt', descending: true)
          .get();

      productReviews.value = snapshot.docs
          .map((doc) => ReviewModel.fromJson(doc.data(), doc.id))
          .toList();

      // Calculate rating stats
      await _calculateRatingStats(productId);
    } catch (e) {
      Get.snackbar('Error', 'Error getting product reviews: $e');

    } finally {
      isLoading.value = false;
    }
  }

  // Calculate and update product rating statistics
  Future<void> _calculateRatingStats(String productId) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('productId', isEqualTo: productId)
          .get();

      if (snapshot.docs.isEmpty) {
        ratingStats.value = ProductRatingStats.empty();
        return;
      }

      final reviews = snapshot.docs
          .map((doc) => ReviewModel.fromJson(doc.data(), doc.id))
          .toList();

      double totalRating = 0;
      Map<int, int> distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

      for (final review in reviews) {
        totalRating += review.rating;
        int ratingInt = review.rating.round();
        distribution[ratingInt] = (distribution[ratingInt] ?? 0) + 1;
      }

      ratingStats.value = ProductRatingStats(
        averageRating: totalRating / reviews.length,
        totalReviews: reviews.length,
        ratingDistribution: distribution,
      );
    } catch (e) {
      Get.snackbar('Error', 'Error calculating rating stats: $e');

    }
  }

  // Update product rating stats in Firestore
  Future<void> _updateProductRatingStats(String productId) async {
    try {
      await _calculateRatingStats(productId);

      // Convert int keys to string keys for Firestore storage
      Map<String, int> distributionForFirestore = {};
      ratingStats.value.ratingDistribution.forEach((key, value) {
        distributionForFirestore[key.toString()] = value;
      });

      // Store the stats in the product document for quick access
      await _firestore.collection('products').doc(productId).update({
        'averageRating': ratingStats.value.averageRating,
        'totalReviews': ratingStats.value.totalReviews,
        'ratingDistribution': distributionForFirestore,
        'lastRatingUpdate': Timestamp.now(),
      });
    } catch (e) {
      Get.snackbar('Error', 'Error updating product rating stats: $e');
    }
  }

  // Delete a review (only by the review author)
  Future<bool> deleteReview(String reviewId, String productId) async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Verify the review belongs to the current user
      final reviewDoc = await _firestore.collection('reviews').doc(reviewId).get();
      if (!reviewDoc.exists) throw Exception('Review not found');

      final review = ReviewModel.fromJson(reviewDoc.data()!, reviewDoc.id);
      if (review.userId != user.uid) throw Exception('Unauthorized');

      await _firestore.collection('reviews').doc(reviewId).delete();

      // Update product rating stats
      await _updateProductRatingStats(productId);

      // Refresh reviews list
      await getProductReviews(productId);

      Get.snackbar('Success', 'Review deleted successfully!',
          snackPosition: SnackPosition.BOTTOM);
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete review: $e',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Get user's review for a specific product
  Future<ReviewModel?> getUserReviewForProduct(String productId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final snapshot = await _firestore
          .collection('reviews')
          .where('productId', isEqualTo: productId)
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return ReviewModel.fromJson(snapshot.docs.first.data(), snapshot.docs.first.id);
    } catch (e) {
      Get.snackbar('Error', 'Error getting user review: $e');

      return null;
    }
  }
}
