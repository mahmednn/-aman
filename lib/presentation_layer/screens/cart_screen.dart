import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_11/business_logic_layer/cubit/cart/cart_cubit.dart';
import 'package:flutter_application_11/business_logic_layer/cubit/cart/cart_state.dart';
import 'package:flutter_application_11/constants/strings.dart';
import 'package:flutter_application_11/data_layer/model/cart.dart';
import 'package:flutter_application_11/presentation_layer/widgets/custom_network_image.dart';
import 'package:flutter_application_11/presentation_layer/widgets/loading_and_empty_states.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    // Load carts when the screen initializes
    context.read<CartCubit>().loadCarts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainBgColor,
      appBar: AppBar(
        title: const Text('السلة'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocConsumer<CartCubit, CartState>(
          listener: (context, state) {
            if (state is CartActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: successColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is CartActionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: dangerColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is CartLoading) {
              return const ListLoadingSkeleton(itemCount: 4);
            }

            if (state is CartError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    EmptyStateWidget(
                      message: 'حدث خطأ أثناء تحميل السلة:\n${state.error}',
                      icon: Icons.error_outline,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => context.read<CartCubit>().loadCarts(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('إعادة المحاولة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryAccent,
                        foregroundColor: textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }

            final carts = context.read<CartCubit>().currentCarts;

            if (carts.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async => await context.read<CartCubit>().loadCarts(),
                color: primaryAccent,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: const EmptyStateWidget(
                      message: 'السلة فارغة حالياً.\nأضف منتجات من الموردين للبدء.',
                      icon: Icons.remove_shopping_cart_outlined,
                    ),
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                await context.read<CartCubit>().loadCarts();
              },
              color: primaryAccent,
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: carts.length,
                      itemBuilder: (context, index) {
                        final cart = carts[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: glassBackground,
                            borderRadius: BorderRadius.circular(cardBorderRadius),
                            border: Border.all(color: glassBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // اسم المورد
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.white10,
                                      child: cart.supplierLogo != null
                                          ? ClipOval(
                                              child: CustomNetworkImage(
                                                imageUrl: cart.supplierLogo!,
                                                width: 40,
                                                height: 40,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : const Icon(Icons.store, color: Colors.white, size: 20),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        cart.supplierName ?? 'مورد غير معروف',
                                        style: const TextStyle(
                                          color: textPrimary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${cart.subtotal} د.ل',
                                      style: const TextStyle(
                                        color: primaryAccent,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(color: Colors.white12, height: 1),
                              // قائمة منتجات السلة لهذا المورد
                              ...cart.items.map((item) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: CustomNetworkImage(
                                          imageUrl: item.productImage ?? '',
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.productName ?? 'منتج غير معروف',
                                              style: const TextStyle(
                                                color: textPrimary,
                                                fontSize: 14,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${item.currentPrice} د.ل',
                                              style: const TextStyle(
                                                color: textSecondary,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // أزرار تعديل الكمية
                                      Row(
                                        children: [
                                          IconButton(
                                            onPressed: state is CartActionLoading
                                                ? null
                                                : () {
                                                    if (item.quantity > 1) {
                                                      context.read<CartCubit>().updateCartItemQuantity(item.id, item.quantity - 1);
                                                    } else {
                                                      context.read<CartCubit>().removeCartItem(item.id);
                                                    }
                                                  },
                                            icon: const Icon(Icons.remove_circle_outline, color: dangerColor, size: 24),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            '${item.quantity}',
                                            style: const TextStyle(
                                              color: textPrimary,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          IconButton(
                                            onPressed: state is CartActionLoading
                                                ? null
                                                : () {
                                                    context.read<CartCubit>().updateCartItemQuantity(item.id, item.quantity + 1);
                                                  },
                                            icon: const Icon(Icons.add_circle_outline, color: successColor, size: 24),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              // أزرار تفريغ وشراء السلة
                              const Divider(color: Colors.white12, height: 1),
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: state is CartActionLoading
                                          ? null
                                          : () {
                                              context.read<CartCubit>().clearCart(cart.id);
                                            },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        alignment: Alignment.center,
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            left: BorderSide(color: Colors.white12),
                                          ),
                                        ),
                                        child: state is CartActionLoading 
                                            ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                            : const Text(
                                              'تفريغ السلة',
                                              style: TextStyle(
                                                color: dangerColor,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: state is CartActionLoading
                                          ? null
                                          : () {
                                              _showCheckoutBottomSheet(context, cart);
                                            },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        alignment: Alignment.center,
                                        child: const Text(
                                              'الشراء الآن',
                                              style: TextStyle(
                                                color: successColor,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showCheckoutBottomSheet(BuildContext context, CartModel cart) {
    showModalBottomSheet(
      context: context,
      backgroundColor: mainBgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (BottomSheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: _CheckoutBottomSheetContent(cart: cart),
        );
      },
    );
  }
}

class _CheckoutBottomSheetContent extends StatefulWidget {
  final CartModel cart;
  const _CheckoutBottomSheetContent({required this.cart});

  @override
  State<_CheckoutBottomSheetContent> createState() => _CheckoutBottomSheetContentState();
}

class _CheckoutBottomSheetContentState extends State<_CheckoutBottomSheetContent> {
  String selectedPaymentMethod = 'cash';
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'تأكيد الطلب - ${widget.cart.supplierName}',
            style: const TextStyle(
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Location Confirmation
          const Text(
            'معلومات التوصيل',
            style: TextStyle(color: textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: glassBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: glassBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: primaryAccent),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'المنزل',
                        style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'طرابلس - حي الأندلس، الشارع الرئيسي',
                        style: TextStyle(color: textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('تغيير', style: TextStyle(color: primaryAccent)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Payment Method
          const Text(
            'وسيلة الدفع',
            style: TextStyle(color: textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _buildPaymentOption('cash', 'الدفع عند الاستلام', Icons.money),
          const SizedBox(height: 8),
          _buildPaymentOption('card', 'بطاقة مصرفية', Icons.credit_card),
          const SizedBox(height: 8),
          _buildPaymentOption('bank_transfer', 'تحويل بنكي', Icons.account_balance),
          
          const SizedBox(height: 24),
          
          // Total and Confirm button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('المجموع الكلي', style: TextStyle(color: textSecondary, fontSize: 12)),
                  Text(
                    '${widget.cart.subtotal} د.ل',
                    style: const TextStyle(color: primaryAccent, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم تأكيد الطلب بنجاح'),
                      backgroundColor: successColor,
                    )
                  );
                },
                child: const Text('تأكيد الطلب', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String value, String title, IconData icon) {
    bool isSelected = selectedPaymentMethod == value;
    return InkWell(
      onTap: () {
        setState(() {
          selectedPaymentMethod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? primaryAccent.withValues(alpha: 0.1) : glassBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? primaryAccent : glassBorder),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? primaryAccent : textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? primaryAccent : textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: primaryAccent),
          ],
        ),
      ),
    );
  }
}
