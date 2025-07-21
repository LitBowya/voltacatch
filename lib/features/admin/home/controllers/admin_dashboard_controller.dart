// lib/features/admin/home/controllers/admin_dashboard_controller.dart
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxInt totalUsers = 0.obs;
  final RxInt totalProducts = 0.obs;
  final RxInt totalOrders = 0.obs;
  final RxInt totalCategories = 0.obs;
  final RxList<double> monthlyOrderCounts = List.filled(12, 0.0).obs;
  final RxBool isLoading = true.obs;
  final RxBool isLoadingChart = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
    loadMonthlyOrders();
  }

  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;

      // Fetch all counts concurrently
      final results = await Future.wait([
        _getUsersCount(),
        _getProductsCount(),
        _getOrdersCount(),
        _getCategoriesCount(),
      ]);

      totalUsers.value = results[0];
      totalProducts.value = results[1];
      totalOrders.value = results[2];
      totalCategories.value = results[3];

    } catch (e) {
      Get.snackbar('Error', 'Failed to load dashboard data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMonthlyOrders() async {
    try {
      isLoadingChart.value = true;
      final currentYear = DateTime.now().year;

      // Initialize monthly counts array
      List<double> monthlyCounts = List.filled(12, 0.0);

      // Get start and end of current year
      final startOfYear = DateTime(currentYear, 1, 1);
      final endOfYear = DateTime(currentYear + 1, 1, 1);

      // Fetch orders for current year
      final snapshot = await _firestore
          .collection('orders')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfYear))
          .where('createdAt', isLessThan: Timestamp.fromDate(endOfYear))
          .get();

      // Count orders by month
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final createdAt = (data['createdAt'] as Timestamp).toDate();
        final month = createdAt.month - 1; // 0-based index
        monthlyCounts[month]++;
      }

      monthlyOrderCounts.value = monthlyCounts;

    } catch (e) {
      Get.snackbar('Error', 'Failed to load monthly orders: $e');
    } finally {
      isLoadingChart.value = false;
    }
  }

  Future<int> _getUsersCount() async {
    final snapshot = await _firestore.collection('users').count().get();
    return snapshot.count ?? 0;
  }

  Future<int> _getProductsCount() async {
    final snapshot = await _firestore
        .collection('products')
        .where('isActive', isEqualTo: true)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  Future<int> _getOrdersCount() async {
    final snapshot = await _firestore.collection('orders').count().get();
    return snapshot.count ?? 0;
  }

  Future<int> _getCategoriesCount() async {
    final snapshot = await _firestore.collection('categories').count().get();
    return snapshot.count ?? 0;
  }

  Future<void> refreshData() async {
    await Future.wait([
      loadDashboardData(),
      loadMonthlyOrders(),
    ]);
  }
}