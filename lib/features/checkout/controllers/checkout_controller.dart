// lib/features/checkout/controllers/checkout_controller.dart
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../cart/models/cart_model.dart';
import '../../orders/models/order_model.dart';
import '../models/shipping_model.dart';

class CheckoutController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxList<CartModel> checkoutItems = <CartModel>[].obs;
  final RxList<ShippingAddressModel> savedAddresses = <ShippingAddressModel>[].obs;
  final Rx<ShippingAddressModel?> selectedAddress = Rx<ShippingAddressModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isLoadingAddresses = false.obs;
  final RxBool isCreatingOrder = false.obs;
  final RxDouble subtotal = 0.0.obs;
  final RxDouble shippingFee = 10.0.obs; // Default shipping fee
  final RxDouble totalPrice = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSavedAddresses();
  }

  void initializeCheckout(List<CartModel> items, bool isFromCart) {
    checkoutItems.value = items;
    _calculateTotals();
  }

  Future<void> fetchSavedAddresses() async {
    if (_auth.currentUser == null) return;

    try {
      isLoadingAddresses.value = true;
      final userId = _auth.currentUser!.uid;

      final QuerySnapshot snapshot = await _firestore
          .collection('shipping_addresses')
          .where('userId', isEqualTo: userId)
          .orderBy('isDefault', descending: true)
          .orderBy('updatedAt', descending: true)
          .get();

      savedAddresses.value = snapshot.docs
          .map((doc) => ShippingAddressModel.fromJson(
          doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      // Auto-select default address if available
      if (savedAddresses.isNotEmpty && selectedAddress.value == null) {
        final defaultAddress = savedAddresses.firstWhereOrNull(
              (address) => address.isDefault,
        );
        selectedAddress.value = defaultAddress ?? savedAddresses.first;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch saved addresses: $e');
    } finally {
      isLoadingAddresses.value = false;
    }
  }

  Future<String?> saveShippingAddress({
    required String name,
    required String region,
    required String city,
    required String town,
    required String address1,
    required String address2,
    required String contact,
    bool isDefault = false,
  }) async {
    if (_auth.currentUser == null) return null;

    try {
      final userId = _auth.currentUser!.uid;

      // If setting as default, update existing default addresses
      if (isDefault) {
        await _updateExistingDefaultAddresses(userId);
      }

      final address = ShippingAddressModel(
        id: '',
        userId: userId,
        name: name,
        region: region,
        city: city,
        town: town,
        address1: address1,
        address2: address2,
        contact: contact,
        isDefault: isDefault,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final docRef = await _firestore
          .collection('shipping_addresses')
          .add(address.toJson());

      final savedAddress = address.copyWith(id: docRef.id);
      savedAddresses.insert(isDefault ? 0 : savedAddresses.length, savedAddress);

      if (isDefault || selectedAddress.value == null) {
        selectedAddress.value = savedAddress;
      }

      Get.snackbar('Success', 'Shipping address saved successfully');
      Get.back();
      return docRef.id;
    } catch (e) {
      Get.snackbar('Error', 'Failed to save shipping address: $e');
      print('Error saving shipping address: $e');
      return null;
    }
  }

  Future<void> _updateExistingDefaultAddresses(String userId) async {
    final batch = _firestore.batch();

    for (final address in savedAddresses.where((a) => a.isDefault)) {
      batch.update(
        _firestore.collection('shipping_addresses').doc(address.id),
        {'isDefault': false, 'updatedAt': Timestamp.now()},
      );
    }

    await batch.commit();

    // Update local state
    for (int i = 0; i < savedAddresses.length; i++) {
      if (savedAddresses[i].isDefault) {
        savedAddresses[i] = savedAddresses[i].copyWith(
          isDefault: false,
          updatedAt: DateTime.now(),
        );
      }
    }
  }

  void selectAddress(ShippingAddressModel address) {
    selectedAddress.value = address;
  }

  Future<String?> createOrder() async {
    if (_auth.currentUser == null) {
      Get.snackbar('Error', 'User not authenticated');
      return null;
    }

    if (selectedAddress.value == null) {
      Get.snackbar('Error', 'Please select a shipping address');
      return null;
    }

    if (checkoutItems.isEmpty) {
      Get.snackbar('Error', 'No items in checkout');
      return null;
    }

    try {
      isCreatingOrder.value = true;
      final userId = _auth.currentUser!.uid;

      final order = OrderModel(
        id: '',
        userId: userId,
        items: checkoutItems,
        shippingAddress: selectedAddress.value!,
        subtotal: subtotal.value,
        shippingFee: shippingFee.value,
        totalPrice: totalPrice.value,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final docRef = await _firestore.collection('orders').add(order.toJson());

      // Update product stock
      await _updateProductStock();

      Get.snackbar('Success', 'Order placed successfully!');
      return docRef.id;
    } catch (e) {
      Get.snackbar('Error', 'Failed to create order: $e');
      print('Error creating order: $e');
      return null;
    } finally {
      isCreatingOrder.value = false;
    }
  }

  Future<void> _updateProductStock() async {
    final batch = _firestore.batch();

    for (final item in checkoutItems) {
      final productRef = _firestore.collection('products').doc(item.productId);
      batch.update(productRef, {
        'stock': FieldValue.increment(-item.quantity),
        'updatedAt': Timestamp.now(),
      });
    }

    await batch.commit();
  }

  void _calculateTotals() {
    subtotal.value = checkoutItems.fold(0.0, (sum, item) => sum + item.totalPrice);
    totalPrice.value = subtotal.value + shippingFee.value;
  }

  void updateShippingFee(double fee) {
    shippingFee.value = fee;
    _calculateTotals();
  }
}