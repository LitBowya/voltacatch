// lib/features/checkout/widgets/shipping_address_form.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../controllers/checkout_controller.dart';
import '../models/shipping_model.dart';

class ShippingAddressForm extends StatefulWidget {
  final Function(ShippingAddressModel)? onAddressSaved;
  final ShippingAddressModel? initialAddress;

  const ShippingAddressForm({
    super.key,
    this.onAddressSaved,
    this.initialAddress,
  });

  @override
  State<ShippingAddressForm> createState() => _ShippingAddressFormState();
}

class _ShippingAddressFormState extends State<ShippingAddressForm> {
  final _formKey = GlobalKey<FormState>();
  final CheckoutController _controller = Get.find<CheckoutController>();

  late final TextEditingController _nameController;
  late final TextEditingController _regionController;
  late final TextEditingController _cityController;
  late final TextEditingController _townController;
  late final TextEditingController _address1Controller;
  late final TextEditingController _address2Controller;
  late final TextEditingController _contactController;

  bool _isDefault = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialAddress?.name ?? '');
    _regionController = TextEditingController(text: widget.initialAddress?.region ?? '');
    _cityController = TextEditingController(text: widget.initialAddress?.city ?? '');
    _townController = TextEditingController(text: widget.initialAddress?.town ?? '');
    _address1Controller = TextEditingController(text: widget.initialAddress?.address1 ?? '');
    _address2Controller = TextEditingController(text: widget.initialAddress?.address2 ?? '');
    _contactController = TextEditingController(text: widget.initialAddress?.contact ?? '');
    _isDefault = widget.initialAddress?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _regionController.dispose();
    _cityController.dispose();
    _townController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Shipping Address',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Form
            Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person_outline,
                      validator: (value) => value?.isEmpty == true ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _regionController,
                            label: 'Region',
                            icon: Icons.map_outlined,
                            validator: (value) => value?.isEmpty == true ? 'Region is required' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _cityController,
                            label: 'City',
                            icon: Icons.location_city_outlined,
                            validator: (value) => value?.isEmpty == true ? 'City is required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _townController,
                      label: 'Town',
                      icon: Icons.home_outlined,
                      validator: (value) => value?.isEmpty == true ? 'Town is required' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _address1Controller,
                      label: 'Address Line 1',
                      icon: Icons.location_on_outlined,
                      validator: (value) => value?.isEmpty == true ? 'Address is required' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _address2Controller,
                      label: 'Address Line 2 (Optional)',
                      icon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _contactController,
                      label: 'Contact Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) => value?.isEmpty == true ? 'Contact is required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Set as Default
                    Row(
                      children: [
                        Checkbox(
                          value: _isDefault,
                          onChanged: (value) => setState(() => _isDefault = value ?? false),
                          activeColor: TColors.primary,
                        ),
                        const Expanded(
                          child: Text(
                            'Set as default address',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveAddress,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : const Text(
                          'Save Address',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: TColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: TColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final addressId = await _controller.saveShippingAddress(
      name: _nameController.text.trim(),
      region: _regionController.text.trim(),
      city: _cityController.text.trim(),
      town: _townController.text.trim(),
      address1: _address1Controller.text.trim(),
      address2: _address2Controller.text.trim(),
      contact: _contactController.text.trim(),
      isDefault: _isDefault,
    );

    setState(() => _isSaving = false);

    if (addressId != null && widget.onAddressSaved != null) {
      final savedAddress = _controller.savedAddresses.firstWhere(
            (address) => address.id == addressId,
      );
      widget.onAddressSaved!(savedAddress);
    }
  }
}