import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_11/business_logic_layer/cubit/cart/cart_cubit.dart';
import 'package:flutter_application_11/business_logic_layer/cubit/cart/cart_state.dart';
import 'package:flutter_application_11/constants/strings.dart';
import 'package:flutter_application_11/data_layer/model/cart.dart';
import 'package:flutter_application_11/data_layer/model/supplier.dart';
import 'package:flutter_application_11/data_layer/model/vehicle.dart';
import 'package:flutter_application_11/presentation_layer/screens/supplier_profile_screen.dart';
import 'package:flutter_application_11/business_logic_layer/cubit/location/location_cubit.dart';
import 'package:flutter_application_11/data_layer/model/checkout_preview.dart';
import 'package:flutter_application_11/presentation_layer/widgets/custom_network_image.dart';
import 'package:flutter_application_11/presentation_layer/widgets/loading_and_empty_states.dart';
import 'package:flutter_application_11/presentation_layer/screens/payment_screen.dart';

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
              return const CartLoadingSkeleton(itemCount: 3);
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
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: secondaryBgColor, // Sleeker background
                            borderRadius: BorderRadius.circular(cardBorderRadius),
                            border: Border.all(color: Colors.white.withOpacity(0.08)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // القسم العلوي: معلومات المورد والحذف
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // صورة المورد
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white24, width: 1.5),
                                      ),
                                      child: ClipOval(
                                        child: cart.supplierLogo != null
                                            ? CustomNetworkImage(
                                                imageUrl: cart.supplierLogo!,
                                                fit: BoxFit.cover,
                                              )
                                            : const Icon(Icons.store, color: Colors.white, size: 28),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    // اسم المورد والتقييم
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            cart.supplierName ?? 'مورد غير معروف',
                                            style: const TextStyle(
                                              color: textPrimary,
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: const [
                                              Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                                              SizedBox(width: 4),
                                              Text(
                                                '4.5',
                                                style: TextStyle(color: textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    // أيقونة الحذف على اليسار (بتنسيق أحمر ناعم)
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 24),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              backgroundColor: glassBackground,
                                              title: const Text('تأكيد تفريغ السلة', style: TextStyle(color: textPrimary)),
                                              content: const Text('هل أنت متأكد من أنك تريد تفريغ كل المنتجات من هذه السلة؟', style: TextStyle(color: textSecondary)),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(ctx),
                                                  child: const Text('إلغاء', style: TextStyle(color: textSecondary)),
                                                ),
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(backgroundColor: dangerColor),
                                                  onPressed: () {
                                                    context.read<CartCubit>().clearCart(cart.id);
                                                    Navigator.pop(ctx);
                                                  },
                                                  child: const Text('تفريغ', style: TextStyle(color: Colors.white)),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const Divider(color: Colors.white12, height: 1, indent: 16, endIndent: 16),
                              
                              // شريط صور المنتجات وزر الإضافة
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: SizedBox(
                                  height: 65, // Slightly sleeker height
                                  child: Row(
                                    children: [
                                      // قائمة المنتجات
                                      if (cart.items.isNotEmpty) ...[
                                        Expanded(
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: cart.items.length,
                                            itemBuilder: (context, itemIndex) {
                                              final item = cart.items[itemIndex];
                                              return Container(
                                                margin: const EdgeInsets.only(left: 10),
                                                width: 65,
                                                height: 65,
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.03),
                                                  borderRadius: BorderRadius.circular(14),
                                                  border: Border.all(color: Colors.white10),
                                                ),
                                                child: Stack(
                                                  fit: StackFit.expand,
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius: BorderRadius.circular(14),
                                                      child: CustomNetworkImage(
                                                        imageUrl: item.productImage ?? '',
                                                        fit: BoxFit.cover,
                                                        errorWidget: const Icon(Icons.inventory, color: Colors.white54, size: 20),
                                                      ),
                                                    ),
                                                    // Badge
                                                    Positioned(
                                                      bottom: 4,
                                                      left: 4,
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: Colors.black87,
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        child: Text(
                                                          'x${item.quantity}',
                                                          style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 11,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                      ],
                                      
                                      // زر إضافة منتجات 
                                      InkWell(
                                        onTap: () {
                                          final mockSupplier = SupplierModel(
                                            id: cart.supplierId,
                                            isActive: true,
                                            logoUrl: cart.supplierLogo,
                                            user: UserModel(
                                              id: 0,
                                              name: cart.supplierName ?? 'مورد',
                                              email: '',
                                              phone: '',
                                            ),
                                          );
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => SupplierProfileScreen(supplier: mockSupplier),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width: 65,
                                          height: 65,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.05),
                                            borderRadius: BorderRadius.circular(14),
                                            border: Border.all(color: Colors.white12),
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: const [
                                              Icon(Icons.add, color: textSecondary, size: 24),
                                              SizedBox(height: 2),
                                              Text('إضافة', style: TextStyle(color: textSecondary, fontSize: 11)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 4),

                              // زر عرض السلة الكامل
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: InkWell(
                                  onTap: () {
                                    _showCartDetailsBottomSheet(context, cart);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                    decoration: BoxDecoration(
                                      color: primaryAccent, // Using app's primary blue theme color
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${cart.items.length}', // Items count on the Right side in RTL
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Text(
                                          'عرض السلة', // Center
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${cart.subtotal} د.ل', // Price on the Left side in RTL
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
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

}

void _showCartDetailsBottomSheet(BuildContext context, CartModel cart) {
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
        child: _CartDetailsBottomSheetContent(cart: cart),
      );
    },
  );
}

class _CartDetailsBottomSheetContent extends StatefulWidget {
  final CartModel cart;
  const _CartDetailsBottomSheetContent({required this.cart});

  @override
  State<_CartDetailsBottomSheetContent> createState() => _CartDetailsBottomSheetContentState();
}

class _CartDetailsBottomSheetContentState extends State<_CartDetailsBottomSheetContent> {
  @override
  Widget build(BuildContext context) {
    // Re-fetch cart items logic is better if tied to state, but we can read from cubit logic to track real-time.
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        // Find the fresh cart if it exists
        final cubit = context.read<CartCubit>();
        final currentCart = cubit.currentCarts.firstWhere(
          (c) => c.id == widget.cart.id,
          orElse: () => widget.cart,
        );

        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10),
                  child: Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'تفاصيل السلة',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: textSecondary),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white12),
                
                // Body
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      // المنتجات
                      const Text(
                        'المنتجات',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (currentCart.items.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: Text('السلة فارغة', style: TextStyle(color: textSecondary))),
                        )
                      else
                        ...currentCart.items.map((item) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: glassBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: glassBorder),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CustomNetworkImage(
                                    imageUrl: item.productImage ?? '',
                                    width: 60,
                                    height: 60,
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
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${item.currentPrice} د.ل',
                                        style: const TextStyle(
                                          color: primaryAccent,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Quantity and Remove
                                Column(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        cubit.removeCartItem(item.id);
                                      },
                                      icon: const Icon(Icons.delete_outline, color: dangerColor),
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            if (item.quantity > 1) {
                                              cubit.updateCartItemQuantity(item.id, item.quantity - 1);
                                            }
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white10,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            padding: const EdgeInsets.all(2),
                                            child: const Icon(Icons.remove, size: 20, color: textPrimary),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          child: Text(
                                            '${item.quantity}',
                                            style: const TextStyle(
                                              color: textPrimary,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            cubit.updateCartItemQuantity(item.id, item.quantity + 1);
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: primaryAccent,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            padding: const EdgeInsets.all(2),
                                            child: const Icon(Icons.add, size: 20, color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                      
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryAccent,
                          side: const BorderSide(color: primaryAccent),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          // إغلاق الشيت أولاً
                          Navigator.pop(context);
                          // إنشاء كائن مورد وهمي لأننا نحتاج للذهاب لشاشة المورد
                          final mockSupplier = SupplierModel(
                            id: currentCart.supplierId,
                            isActive: true,
                            logoUrl: currentCart.supplierLogo,
                            user: UserModel(
                              id: 0,
                              name: currentCart.supplierName ?? 'مورد',
                              email: '',
                              phone: '',
                            ),
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SupplierProfileScreen(supplier: mockSupplier),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('إضافة منتجات من نفس المورد'),
                      ),
                      const SizedBox(height: 24),
                      
                      // الفاتورة
                      const Text(
                        'الفاتورة',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: glassBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: glassBorder),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('المجموع الفرعي', style: TextStyle(color: textSecondary)),
                                Text('${currentCart.subtotal} د.ل', style: const TextStyle(color: textPrimary)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('رسوم التوصيل', style: TextStyle(color: textSecondary)),
                                Text('تحدد لاحقاً', style: TextStyle(color: textPrimary)),
                              ],
                            ),
                            const Divider(color: Colors.white12, height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'المجموع الكلي',
                                  style: TextStyle(
                                    color: textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${currentCart.subtotal} د.ل',
                                  style: const TextStyle(
                                    color: primaryAccent,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // زر الاستمرار والمقاطعة
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: mainBgColor,
                    border: Border(top: BorderSide(color: Colors.white12)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: dangerColor,
                            side: const BorderSide(color: dangerColor),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: glassBackground,
                                title: const Text('تأكيد تفريغ السلة', style: TextStyle(color: textPrimary)),
                                content: const Text('هل أنت متأكد من أنك تريد تفريغ كل المنتجات من هذه السلة؟', style: TextStyle(color: textSecondary)),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('إلغاء', style: TextStyle(color: textSecondary)),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: dangerColor),
                                    onPressed: () {
                                      cubit.clearCart(currentCart.id);
                                      Navigator.pop(ctx); // close dialog
                                      Navigator.pop(context); // close bottom sheet
                                    },
                                    child: const Text('تفريغ', style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Text('تفريغ السلة', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryAccent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: currentCart.items.isEmpty ? null : () {
                            Navigator.pop(context); // Close cart details
                            _showVehicleSelectionBottomSheet(context, currentCart); // Open vehicles
                          },
                          child: const Text('الاستمرار', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}


void _showVehicleSelectionBottomSheet(BuildContext context, CartModel cart) {
  showModalBottomSheet(
    context: context,
    backgroundColor: mainBgColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isScrollControlled: true,
    builder: (BuildContext ctx) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: _VehicleSelectionContent(cart: cart),
      );
    },
  );
}

class _VehicleSelectionContent extends StatefulWidget {
  final CartModel cart;
  const _VehicleSelectionContent({required this.cart});

  @override
  State<_VehicleSelectionContent> createState() => _VehicleSelectionContentState();
}

class _VehicleSelectionContentState extends State<_VehicleSelectionContent> {
  int? selectedVehicleId;
  bool isFetchingLocation = false;

  @override
  void initState() {
    super.initState();
    // Fetch vehicles
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartCubit>().loadVehicleTypes();
    });
    
    // Try to pre-fetch locations if they are empty
    final locationState = context.read<LocationCubit>().state;
    if (locationState.locations.isEmpty) {
      context.read<LocationCubit>().getLocations();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
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
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showCartDetailsBottomSheet(context, widget.cart);
                },
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: textSecondary, size: 20),
              ),
              const Expanded(
                child: Text(
                  'اختيار مركبة التوصيل',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48), // Placeholder to center title
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'يرجى اختيار نوع المركبة المناسبة لشحنتك',
            style: TextStyle(color: textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 20),
          
          Expanded(
            child: BlocBuilder<CartCubit, CartState>(
              buildWhen: (previous, current) =>
                  current is CartVehicleTypesLoading ||
                  current is CartVehicleTypesLoaded ||
                  current is CartVehicleTypesError,
              builder: (context, state) {
                if (state is CartVehicleTypesLoading && context.read<CartCubit>().vehicleTypes.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: primaryAccent));
                }
                
                final vehicles = context.read<CartCubit>().vehicleTypes;
                
                if (vehicles.isEmpty && state is CartVehicleTypesError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: dangerColor, size: 48),
                        const SizedBox(height: 16),
                        Text(state.error, style: const TextStyle(color: textSecondary), textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.read<CartCubit>().loadVehicleTypes(),
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  );
                }

                if (vehicles.isEmpty) {
                  return const Center(child: Text('لا توجد مركبات متاحة حالياً', style: TextStyle(color: textSecondary)));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: vehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = vehicles[index];
                    final isSelected = selectedVehicleId == vehicle.id;
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedVehicleId = vehicle.id;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? primaryAccent.withOpacity(0.1) : glassBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? primaryAccent : glassBorder,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CustomNetworkImage(
                                imageUrl: vehicle.imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    vehicle.name,
                                    style: const TextStyle(
                                      color: textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'السعر الأساسي: ${vehicle.basePrice} د.ل',
                                    style: const TextStyle(
                                      color: primaryAccent,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                              color: isSelected ? primaryAccent : textSecondary,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          const SizedBox(height: 20),
          SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: BlocConsumer<CartCubit, CartState>(
                listener: (context, state) {
                  if (state is CheckoutPreviewLoaded) {
                    Navigator.pop(context); // إغلاق نافذة اختيار المركبة
                    
                    final locationState = context.read<LocationCubit>().state;
                    if (locationState.locations.isEmpty) return;

                    final defaultLocation = locationState.locations.firstWhere(
                      (loc) => loc.isDefault == 1,
                      orElse: () => locationState.locations.first,
                    );

                    _showCheckoutPreviewBottomSheet(
                      context,
                      state.checkoutPreview,
                      defaultLocation.id!,
                      [widget.cart.id],
                      selectedVehicleId!,
                      'cash',
                    );
                  } else if (state is CartActionError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.error), backgroundColor: dangerColor),
                    );
                  }
                },
                builder: (context, state) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: selectedVehicleId == null || state is CartActionLoading || isFetchingLocation
                        ? null
                        : () async {
                            final locationCubit = context.read<LocationCubit>();
                            var locations = locationCubit.state.locations;
                            
                            if (locations.isEmpty) {
                              setState(() => isFetchingLocation = true);
                              await locationCubit.getLocations();
                              setState(() => isFetchingLocation = false);
                              locations = locationCubit.state.locations;
                            }

                            if (locations.isEmpty) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('يرجى إضافة موقع توصيل من حسابك أولاً لإتمام الطلب'),
                                  backgroundColor: warningColor,
                                ),
                              );
                              return;
                            }

                            final defaultLocation = locations.firstWhere(
                              (loc) => loc.isDefault == 1,
                              orElse: () => locations.first,
                            );

                            if (defaultLocation.id == null) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('هناك مشكلة في عنوان التوصيل الخاص بك'),
                                  backgroundColor: dangerColor,
                                ),
                              );
                              return;
                            }

                            if (!context.mounted) return;
                            context.read<CartCubit>().previewCheckout(
                              locationId: defaultLocation.id!,
                              cartIds: [widget.cart.id],
                              vehicleTypeId: selectedVehicleId!,
                              paymentMethod: 'cash',
                            );
                          },
                    child: (state is CartActionLoading || isFetchingLocation)
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'الاستمرار والدفع',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _showCheckoutPreviewBottomSheet(
  BuildContext context,
  CheckoutPreviewModel preview,
  int locationId,
  List<int> cartIds,
  int vehicleTypeId,
  String paymentMethod,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: mainBgColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isScrollControlled: true,
    builder: (BuildContext ctx) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: _CheckoutPreviewContent(
          preview: preview,
          locationId: locationId,
          cartIds: cartIds,
          vehicleTypeId: vehicleTypeId,
          paymentMethod: paymentMethod,
        ),
      );
    },
  );
}

class _CheckoutPreviewContent extends StatelessWidget {
  final CheckoutPreviewModel preview;
  final int locationId;
  final List<int> cartIds;
  final int vehicleTypeId;
  final String paymentMethod;

  const _CheckoutPreviewContent({
    required this.preview,
    required this.locationId,
    required this.cartIds,
    required this.vehicleTypeId,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        // Use the preview from state if available (after changing location)
        final currentPreview = (state is CheckoutPreviewLoaded) ? state.checkoutPreview : preview;
        final currentLocationId = (state is CheckoutPreviewLoaded) ? (state.checkoutPreview.location.id ?? locationId) : locationId;
        final isLoading = state is CartActionLoading;

        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return Stack(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 10),
                      child: Center(
                        child: Container(
                          width: 50,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                              final cart = context.read<CartCubit>().currentCarts.firstWhere((c) => c.id == cartIds[0]);
                              _showVehicleSelectionBottomSheet(context, cart);
                            },
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: textSecondary, size: 20),
                          ),
                          const Expanded(
                            child: Text(
                              'مراجعة الطلب',
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 48), // Placeholder to center title
                        ],
                      ),
                    ),
                    const Divider(color: Colors.white12),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: [
                          // بيانات التوصيل
                          const Text('موقع التوصيل', style: TextStyle(color: textSecondary, fontSize: 14)),
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
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        currentPreview.location.name,
                                        style: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        currentPreview.location.address,
                                        style: const TextStyle(color: textSecondary, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => _showLocationSelector(context, cartIds, vehicleTypeId, paymentMethod),
                                  child: const Text('تغيير', style: TextStyle(color: primaryAccent, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // المركبة المختارة
                          if (currentPreview.vehicleType != null) ...[
                            const Text('مركبة التوصيل', style: TextStyle(color: textSecondary, fontSize: 14)),
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
                                  const Icon(Icons.local_shipping, color: primaryAccent),
                                  const SizedBox(width: 12),
                                  Text(
                                    currentPreview.vehicleType!.name,
                                    style: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // الطلبات (Orders)
                          const Text('الطلبات', style: TextStyle(color: textSecondary, fontSize: 14)),
                          const SizedBox(height: 8),
                          ...currentPreview.orders.map((order) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: glassBackground,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: glassBorder),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        order.supplierName,
                                        style: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      Text(
                                        '${order.total} د.ل',
                                        style: const TextStyle(color: primaryAccent, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const Divider(color: Colors.white12),
                                  ...order.items.map((item) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Row(
                                        children: [
                                          Text('${item.quantity}x', style: const TextStyle(color: primaryAccent, fontWeight: FontWeight.bold)),
                                          const SizedBox(width: 8),
                                          Expanded(child: Text(item.productName, style: const TextStyle(color: textPrimary))),
                                          const Spacer(),
                                          Text('${item.lineTotal} د.ل', style: const TextStyle(color: textSecondary)),
                                        ],
                                      ),
                                    );
                                  }),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('رسوم التوصيل:', style: TextStyle(color: textSecondary, fontSize: 12)),
                                      Text('${order.deliveryFee} د.ل', style: const TextStyle(color: textSecondary, fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 20),

                          // ملخص الفاتورة
                          const Text('ملخص الدفع', style: TextStyle(color: textSecondary, fontSize: 14)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: glassBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: glassBorder),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('المجموع الفرعي', style: TextStyle(color: textSecondary)),
                                    Text('${currentPreview.summary.subtotal} د.ل', style: const TextStyle(color: textPrimary)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('إجمالي التوصيل', style: TextStyle(color: textSecondary)),
                                    Text('${currentPreview.summary.deliveryFee} د.ل', style: const TextStyle(color: textPrimary)),
                                  ],
                                ),
                                if (currentPreview.summary.walletDeduction > 0) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('خصم المحفظة', style: TextStyle(color: successColor)),
                                      Text('-${currentPreview.summary.walletDeduction} د.ل', style: const TextStyle(color: successColor)),
                                    ],
                                  ),
                                ],
                                const Divider(color: Colors.white12, height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('المطلوب دفعه', style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                                    Text(
                                      '${currentPreview.summary.cashRemaining} د.ل',
                                      style: const TextStyle(color: primaryAccent, fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: mainBgColor,
                        border: Border(top: BorderSide(color: Colors.white12)),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: BlocConsumer<CartCubit, CartState>(
                          listener: (context, state) {
                            if (state is CheckoutConfirmSuccess) {
                              Navigator.pop(context); // Close bottom sheet
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PaymentScreen(),
                                ),
                              );
                            } else if (state is CheckoutConfirmError) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(state.error),
                                  backgroundColor: dangerColor,
                                ),
                              );
                            }
                          },
                          builder: (context, state) {
                            final isConfirming = state is CheckoutConfirmLoading;
                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryAccent,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: isConfirming
                                  ? null
                                  : () {
                                      // Disabled as per user request
                                    },
                              child: isConfirming
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Text(
                                      'تأكيد الطلب',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                if (isLoading)
                  Container(
                    color: Colors.black26,
                    child: const Center(
                      child: CircularProgressIndicator(color: primaryAccent),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

void _showLocationSelector(BuildContext context, List<int> cartIds, int vehicleTypeId, String paymentMethod) {
  final locations = context.read<LocationCubit>().state.locations;
  
  showModalBottomSheet(
    context: context,
    backgroundColor: mainBgColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'اختر عنوان التوصيل',
                style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (locations.isEmpty)
                const Center(child: Text('لا يوجد مواقع مسجلة', style: TextStyle(color: textSecondary)))
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: locations.length,
                    itemBuilder: (ctx, index) {
                      final location = locations[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.location_on_outlined, color: primaryAccent),
                        title: Text(location.name ?? '', style: const TextStyle(color: textPrimary)),
                        subtitle: Text(location.address ?? '', style: const TextStyle(color: textSecondary, fontSize: 12)),
                        onTap: () {
                          Navigator.pop(ctx);
                          context.read<CartCubit>().previewCheckout(
                            locationId: location.id!,
                            cartIds: cartIds,
                            vehicleTypeId: vehicleTypeId,
                            paymentMethod: paymentMethod,
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}
