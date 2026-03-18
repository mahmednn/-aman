import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_11/presentation_layer/widgets/custom_back_button.dart';
import 'package:flutter_application_11/business_logic_layer/cubit/cart/cart_cubit.dart';
import 'package:flutter_application_11/business_logic_layer/cubit/cart/cart_state.dart';
import 'package:flutter_application_11/data_layer/model/supplier.dart';
import 'package:flutter_application_11/presentation_layer/widgets/custom_network_image.dart';
import 'package:flutter_application_11/presentation_layer/widgets/product_card.dart';
import 'package:flutter_application_11/constants/strings.dart';
import 'package:flutter_application_11/presentation_layer/widgets/cart_summary_bar.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;
  final SupplierModel? supplier;
  final String? heroTag;

  const ProductDetailsScreen({
    super.key,
    required this.product,
    this.supplier,
    this.heroTag,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    // تصفية المنتجات المشابهة (استبعاد المنتج الحالي)
    final similarProducts =
        widget.supplier?.products
            ?.where((p) => p.id != widget.product.id)
            .toList() ??
        [];

    return Scaffold(
      backgroundColor: mainBgColor,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 400,
                  pinned: true,
                  backgroundColor: mainBgColor,
                  leading: const CustomBackButton(),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Hero(
                      tag: widget.heroTag ?? 'product_${widget.product.id}',
                      child: CustomNetworkImage(
                        imageUrl: widget.product.img ?? '',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: mainBgColor,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(defaultBorderRadius),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(defaultPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.product.name,
                                  style: const TextStyle(
                                    color: textPrimary,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                "${widget.product.price ?? '0'} د.ل",
                                style: const TextStyle(
                                  color: primaryAccent,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (widget.supplier != null)
                            Row(
                              children: [
                                const Icon(
                                  Icons.storefront,
                                  color: textSecondary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  widget.supplier?.user?.name ?? "مورد غير معروف",
                                  style: const TextStyle(
                                    color: textSecondary,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 20),
                          Divider(color: glassBorder),
                          const SizedBox(height: 20),
                          const Text(
                            "الوصف",
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.product.description ??
                                "لا يوجد وصف متاح لهذا المنتج.",
                            style: const TextStyle(
                              color: textSecondary,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                          if (similarProducts.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            const SizedBox(height: 24),
                            Divider(color: glassBorder),
                            const SizedBox(height: 16),
                            const Text(
                              "منتجات مشابهة",
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.6,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                              itemCount: similarProducts.length,
                              itemBuilder: (context, index) {
                                final similarProduct = similarProducts[index];
                                return ProductCard(
                                  product: similarProduct,
                                  supplier: widget.supplier,
                                  heroTag:
                                      'similar_product_from_${widget.product.id}_to_${similarProduct.id}',
                                   onAddToCart: () {
                                     context.read<CartCubit>().addToCart(
                                       similarProduct.id,
                                       1,
                                       similarProduct.pivotId ?? 0,
                                     );
                                   },
                                );
                              },
                            ),
                          ],
                          const SizedBox(height: 120), // Extra space for floating bar
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: CartSummaryBar(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(defaultPadding),
        decoration: BoxDecoration(
          color: secondaryBgColor.withValues(alpha: 0.95),
          border: Border(top: BorderSide(color: glassBorder)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
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
              return ElevatedButton(
                onPressed: state is CartActionLoading
                    ? null
                    : () {
                         // إضافة منتج واحد افتراضياً، يمكن للمستخدم زيادة الكمية من شاشة السلة
                          context.read<CartCubit>().addToCart(
                            widget.product.id,
                            1,
                            widget.product.pivotId ?? 0,
                          );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(cardBorderRadius),
                  ),
                  elevation: 0,
                ),
                child: state is CartActionLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "إضافة للسلة",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
              );
            },
          ),
        ),
      ),
    );
  }
}

