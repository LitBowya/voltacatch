// lib/features/cart/controllers/cart_controller.dart
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cart_model.dart';
import '../../admin/products/models/product_model.dart';

class CartController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ Public getter to expose FirebaseAuth safely
  FirebaseAuth get auth => _auth;

  // ✅ Public getter to check authentication state
  bool get isUserAuthenticated => _auth.currentUser != null;

  final RxList<CartModel> cartItems = <CartModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxDouble totalPrice = 0.0.obs;
  final RxInt totalItems = 0.obs;

  @override
  void onInit() {
    super.onInit();
    if (_auth.currentUser != null) {
      fetchCartItems();
    }
  }


  Future<void> fetchCartItems() async {
    if (!isUserAuthenticated) return;

    try {
      isLoading.value = true;
      final userId = _auth.currentUser!.uid;

      final QuerySnapshot snapshot = await _firestore
          .collection('carts')
          .where('userId', isEqualTo: userId)
          .orderBy('updatedAt', descending: true)
          .get();

      cartItems.value = snapshot.docs
          .map((doc) => CartModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      _calculateTotals();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch cart items: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addToCart(ProductModel product, {int quantity = 1}) async {
    if (!isUserAuthenticated) {
      Get.snackbar('Authentication Required', 'Please login to add items to cart');
      return;
    }

    if (product.stock < quantity) {
      Get.snackbar('Insufficient Stock', 'Not enough items in stock');
      return;
    }

    try {
      final userId = _auth.currentUser!.uid;

      // Check if item already exists in cart
      final existingItemIndex = cartItems.indexWhere(
            (item) => item.productId == product.id,
      );

      if (existingItemIndex != -1) {
        // Update existing item
        final existingItem = cartItems[existingItemIndex];
        final newQuantity = existingItem.quantity + quantity;

        if (newQuantity > product.stock) {
          Get.snackbar('Stock Limit', 'Cannot add more items than available stock');
          return;
        }

        await _updateCartItem(existingItem.id, newQuantity);
      } else {
        // Add new item
        final cartItem = CartModel(
          id: '',
          userId: userId,
          productId: product.id,
          product: product,
          quantity: quantity,
          totalPrice: (product.price * quantity).toDouble(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _addNewCartItem(cartItem);
      }

      Get.snackbar(
        'Added to Cart',
        '${product.name} has been added to your cart',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to add item to cart: $e');
    }
  }

  Future<void> _addNewCartItem(CartModel cartItem) async {
    final docRef = await _firestore.collection('carts').add(cartItem.toJson());

    final newItem = cartItem.copyWith(id: docRef.id);
    cartItems.add(newItem);
    _calculateTotals();
  }

  Future<void> _updateCartItem(String cartId, int newQuantity) async {
    final cartIndex = cartItems.indexWhere((item) => item.id == cartId);
    if (cartIndex == -1) return;

    final cartItem = cartItems[cartIndex];
    final updatedItem = cartItem.copyWith(
      quantity: newQuantity,
      totalPrice: cartItem.product.price * newQuantity,
      updatedAt: DateTime.now(),
    );

    await _firestore.collection('carts').doc(cartId).update({
      'quantity': newQuantity,
      'totalPrice': updatedItem.totalPrice,
      'updatedAt': Timestamp.fromDate(updatedItem.updatedAt),
    });

    cartItems[cartIndex] = updatedItem;
    _calculateTotals();
  }

  Future<void> updateQuantity(String cartId, int newQuantity) async {
    if (newQuantity <= 0) {
      await removeFromCart(cartId);
      return;
    }

    final cartItem = cartItems.firstWhereOrNull((item) => item.id == cartId);
    if (cartItem == null) return;

    if (newQuantity > cartItem.product.stock) {
      Get.snackbar('Stock Limit', 'Cannot exceed available stock');
      return;
    }

    await _updateCartItem(cartId, newQuantity);
  }

  Future<void> removeFromCart(String cartId) async {
    try {
      await _firestore.collection('carts').doc(cartId).delete();
      cartItems.removeWhere((item) => item.id == cartId);
      _calculateTotals();

      Get.snackbar('Removed', 'Item removed from cart');
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove item: $e');
    }
  }

  Future<void> clearCart() async {
    try {
      final batch = _firestore.batch();
      for (final item in cartItems) {
        batch.delete(_firestore.collection('carts').doc(item.id));
      }
      await batch.commit();

      cartItems.clear();
      _calculateTotals();
    } catch (e) {
      Get.snackbar('Error', 'Failed to clear cart: $e');
    }
  }

  void _calculateTotals() {
    totalItems.value = cartItems.fold(0, (sum, item) => sum + item.quantity);
    totalPrice.value = cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  int getItemQuantity(String productId) {
    final item = cartItems.firstWhereOrNull((item) => item.productId == productId);
    return item?.quantity ?? 0;
  }

  bool isInCart(String productId) {
    return cartItems.any((item) => item.productId == productId);
  }
}