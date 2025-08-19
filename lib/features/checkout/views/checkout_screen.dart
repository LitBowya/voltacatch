// lib/features/checkout/views/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../controllers/checkout_controller.dart';
import '../widgets/shipping_address_form.dart';
import '../widgets/address_selection_card.dart';
import '../../cart/models/cart_model.dart';
import 'confirmation_screen.dart';

class CheckoutScreen extends StatelessWidget {
  final List<CartModel> cartItems;
  final bool isFromCart;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    this.isFromCart = false,
  });

  @override
  Widget build(BuildContext context) {
    final CheckoutController checkoutController = Get.put(CheckoutController());

    // Initialize checkout with items
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkoutController.initializeCheckout(cartItems, isFromCart);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: TColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (checkoutController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Summary Section
                    _buildOrderSummary(checkoutController),
                    const SizedBox(height: 24),

                    // Shipping Address Section
                    _buildShippingSection(checkoutController),
                    const SizedBox(height: 24),

                    // Price Breakdown
                    _buildPriceBreakdown(checkoutController),
                  ],
                ),
              ),
            ),

            // Continue Button
            _buildContinueButton(checkoutController),
          ],
        );
      }),
    );
  }

  Widget _buildOrderSummary(CheckoutController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.08 * 255).toInt()),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shopping_bag_outlined, color: TColors.primary),
              const SizedBox(width: 8),
              const Text(
                'Order Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Order Items
          Obx(() => Column(
            children: controller.checkoutItems.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    // Product Image
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[100],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: item.product.images.isNotEmpty
                            ? Image.network(
                          item.product.images.first,
                          fit: BoxFit.cover,
                        )
                            : Icon(Icons.local_grocery_store_outlined,
                            color: Colors.grey[400]),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Product Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Qty: ${item.quantity}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Price
                    Text(
                      'GHS ${item.totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: TColors.primary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          )),
        ],
      ),
    );
  }

  Widget _buildShippingSection(CheckoutController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.08 * 255).toInt()),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on_outlined, color: TColors.primary),
                  const SizedBox(width: 8),
                  const Text(
                    'Shipping Address',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => _showAddAddressForm(controller),
                child: const Text('Add New'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Selected Address or Address Selection
          Obx(() {
            if (controller.selectedAddress.value != null) {
              return AddressSelectionCard(
                address: controller.selectedAddress.value!,
                isSelected: true,
                onTap: () => _showAddressSelection(controller),
              );
            } else {
              return _buildNoAddressState(controller);
            }
          }),
        ],
      ),
    );
  }

  Widget _buildNoAddressState(CheckoutController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.location_off_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'No shipping address selected',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please add a shipping address to continue',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _showAddAddressForm(controller),
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add Address'),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown(CheckoutController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.08 * 255).toInt()),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_outlined, color: TColors.primary),
              const SizedBox(width: 8),
              const Text(
                'Price Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Obx(() => Column(
            children: [
              _buildPriceRow(
                'Subtotal',
                'GHS ${controller.subtotal.value.toStringAsFixed(2)}',
              ),
              const SizedBox(height: 8),
              _buildPriceRow(
                'Shipping Fee',
                'GHS ${controller.shippingFee.value.toStringAsFixed(2)}',
              ),
              const Divider(height: 24),
              _buildPriceRow(
                'Total',
                'GHS ${controller.totalPrice.value.toStringAsFixed(2)}',
                isTotal: true,
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
            color: isTotal ? const Color(0xFF2D3748) : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            color: isTotal ? TColors.primary : const Color(0xFF2D3748),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton(CheckoutController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).toInt()),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Obx(() => ElevatedButton(
            onPressed: controller.selectedAddress.value != null
                ? () => Get.to(() => ConfirmationScreen(
              checkoutItems: controller.checkoutItems,
              shippingAddress: controller.selectedAddress.value!,
              subtotal: controller.subtotal.value,
              shippingFee: controller.shippingFee.value,
              totalPrice: controller.totalPrice.value,
              isFromCart: isFromCart,
            ))
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: Colors.grey[300],
            ),
            child: const Text(
              'Continue to Confirmation',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          )),
        ),
      ),
    );
  }

  void _showAddAddressForm(CheckoutController controller) {
    Get.bottomSheet(
      ShippingAddressForm(
        onAddressSaved: (address) {
          controller.selectAddress(address);
          Get.back();
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showAddressSelection(CheckoutController controller) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Address',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.back();
                      _showAddAddressForm(controller);
                    },
                    child: const Text('Add New'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            Flexible(
              child: Obx(() => ListView.builder(
                shrinkWrap: true,
                itemCount: controller.savedAddresses.length,
                itemBuilder: (context, index) {
                  final address = controller.savedAddresses[index];
                  return AddressSelectionCard(
                    address: address,
                    isSelected: controller.selectedAddress.value?.id == address.id,
                    onTap: () {
                      controller.selectAddress(address);
                      Get.back();
                    },
                  );
                },
              )),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}