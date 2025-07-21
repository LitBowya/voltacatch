// lib/features/home/controllers/home_controller.dart
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../admin/products/models/product_model.dart';

class HomeController extends GetxController {
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('products')
          .get();

      products.value = snapshot.docs
          .map((doc) => ProductModel.fromJson(
          doc.data() as Map<String, dynamic>,
          doc.id
      ))
          .toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch products: $e');
      print('Error fetching products: $e');
    } finally {
      isLoading.value = false;
    }
  }
}