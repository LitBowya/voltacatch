// lib/features/admin/orders/controllers/admin_order_controller.dart
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../orders/models/order_model.dart';
import '../../../auth/models/user_model.dart';

class AdminOrderController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<OrderModel> _orders = <OrderModel>[].obs;
  final RxList<OrderModel> _filteredOrders = <OrderModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _searchQuery = ''.obs;
  final Rx<OrderStatus?> _selectedStatus = Rx<OrderStatus?>(null);
  final RxString _sortBy = 'createdAt_desc'.obs;

  // Pagination
  DocumentSnapshot? _lastDocument;
  final RxBool _hasMore = true.obs;
  final int _pageSize = 20;

  List<OrderModel> get orders => _filteredOrders;
  bool get isLoading => _isLoading.value;
  bool get hasMore => _hasMore.value;
  String get searchQuery => _searchQuery.value;
  OrderStatus? get selectedStatus => _selectedStatus.value;
  String get sortBy => _sortBy.value;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders({bool refresh = false}) async {
    if (_isLoading.value || (!_hasMore.value && !refresh)) return;

    try {
      _isLoading.value = true;

      if (refresh) {
        _orders.clear();
        _lastDocument = null;
        _hasMore.value = true;
      }

      Query query = _firestore.collection('orders');

      // Apply status filter
      if (_selectedStatus.value != null) {
        query = query.where('status', isEqualTo: _selectedStatus.value.toString().split('.').last);
      }

      // Apply sorting
      switch (_sortBy.value) {
        case 'createdAt_asc':
          query = query.orderBy('createdAt', descending: false);
          break;
        case 'totalPrice_desc':
          query = query.orderBy('totalPrice', descending: true);
          break;
        case 'totalPrice_asc':
          query = query.orderBy('totalPrice', descending: false);
          break;
        default:
          query = query.orderBy('createdAt', descending: true);
      }

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      query = query.limit(_pageSize);

      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
        final newOrders = snapshot.docs
            .map((doc) => OrderModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
            .toList();
        _orders.addAll(newOrders);

        if (snapshot.docs.length < _pageSize) {
          _hasMore.value = false;
        }
      } else {
        _hasMore.value = false;
      }

      _applyFilters();
      _isLoading.value = false;
    } catch (e) {
      _isLoading.value = false;
      Get.snackbar('Error', 'Failed to load orders: $e');
    }
  }

  void searchOrders(String query) {
    _searchQuery.value = query;
    _applyFilters();
  }

  void filterByStatus(OrderStatus? status) {
    _selectedStatus.value = status;
    loadOrders(refresh: true);
  }

  void sortOrders(String sortBy) {
    _sortBy.value = sortBy;
    loadOrders(refresh: true);
  }

  void _applyFilters() {
    _filteredOrders.value = _orders.where((order) {
      final matchesSearch = _searchQuery.value.isEmpty ||
          order.id.toLowerCase().contains(_searchQuery.value.toLowerCase()) ||
          order.userId.toLowerCase().contains(_searchQuery.value.toLowerCase());

      return matchesSearch;
    }).toList();
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus.toString().split('.').last,
        'updatedAt': Timestamp.now(),
      });

      // Update local order
      final orderIndex = _orders.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        final updatedOrder = OrderModel(
          id: _orders[orderIndex].id,
          userId: _orders[orderIndex].userId,
          items: _orders[orderIndex].items,
          shippingAddress: _orders[orderIndex].shippingAddress,
          subtotal: _orders[orderIndex].subtotal,
          shippingFee: _orders[orderIndex].shippingFee,
          totalPrice: _orders[orderIndex].totalPrice,
          status: newStatus,
          createdAt: _orders[orderIndex].createdAt,
          updatedAt: DateTime.now(),
        );
        _orders[orderIndex] = updatedOrder;
      }

      _applyFilters();
      Get.snackbar('Success', 'Order status updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update order status: $e');
    }
  }

  Future<UserModel?> getUserDetails(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void reset() {
    _orders.clear();
    _filteredOrders.clear();
    _lastDocument = null;
    _hasMore.value = true;
    _searchQuery.value = '';
    _selectedStatus.value = null;
    _sortBy.value = 'createdAt_desc';
  }
}