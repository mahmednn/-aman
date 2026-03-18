import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_11/business_logic_layer/cubit/suppliers_cubit.dart';
import 'package:flutter_application_11/business_logic_layer/cubit/cart/cart_cubit.dart';
import 'package:flutter_application_11/business_logic_layer/cubit/cart/cart_state.dart';
import 'package:flutter_application_11/data_layer/model/supplier.dart';
import 'package:flutter_application_11/presentation_layer/screens/supplier_profile_screen.dart';
import 'package:flutter_application_11/presentation_layer/widgets/custom_network_image.dart';
import 'package:flutter_application_11/presentation_layer/widgets/page_transitions.dart';
import 'package:flutter_application_11/presentation_layer/widgets/product_card.dart';
import 'package:flutter_application_11/presentation_layer/widgets/custom_back_button.dart';
import 'package:flutter_application_11/constants/strings.dart';
import 'package:flutter_application_11/presentation_layer/widgets/loading_and_empty_states.dart';
import 'package:flutter_application_11/presentation_layer/widgets/cart_summary_bar.dart';

class CategoryDetailsScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const CategoryDetailsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryDetailsScreen> createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  // ملاحظة: هذا مجرد محاكاة للسلة. في تطبيق حقيقي، يجب استخدام Cubit مخصص لإدارة حالة السلة.
  // List products
  List<_ProductWithSupplier> _productsWithSuppliers = [];
  bool _isProductListInitialized = false;

  @override
  void initState() {
    super.initState();
    // جلب المنتجات والموردين المرتبطين بهذه الفئة إذا لزم الأمر
    context.read<SuppliersCubit>().getAllSuppliers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainBgColor,
      appBar: AppBar(
        leading: const CustomBackButton(),
        title: Text(widget.categoryName),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: BlocListener<CartCubit, CartState>(
        listener: (context, cartState) {
          if (cartState is CartActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(cartState.message),
                backgroundColor: successColor,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 1),
              ),
            );
          } else if (cartState is CartActionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(cartState.error),
                backgroundColor: dangerColor,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: BlocBuilder<SuppliersCubit, SuppliersState>(
          builder: (context, state) {
            if (state is SuppliersLoaded) {
              /// فلترة الموردين حسب الفئة
              final filteredSuppliers = state.suppliers
                  .where(
                    (supplier) =>
                        supplier.supplierCategory?.id == widget.categoryId,
                  )
                  .toList();

              if (filteredSuppliers.isEmpty) {
                return const EmptyStateWidget(
                  message: 'لا يوجد موردين لهذه الفئة حالياً',
                  icon: Icons.store_outlined,
                );
              }

              // يتم تجهيز القائمة وخلطها مرة واحدة فقط لمنع إعادة ترتيبها عند كل إعادة بناء
              if (!_isProductListInitialized) {
                final allProducts = <_ProductWithSupplier>[];
                for (final supplier in filteredSuppliers) {
                  if (supplier.products != null) {
                    for (final product in supplier.products!) {
                      allProducts.add(_ProductWithSupplier(product, supplier));
                    }
                  }
                }
                allProducts.shuffle();
                _productsWithSuppliers = allProducts;
                _isProductListInitialized = true;
              }

              return RefreshIndicator(
                onRefresh: () async {
                  _isProductListInitialized = false;
                  context.read<SuppliersCubit>().getAllSuppliers();
                },
                color: primaryAccent,
                backgroundColor: cardColor,
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// عنوان الموردين
                          const Padding(
                            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Text(
                              "الموردين",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          /// ليست الموردين الأفقية (تم تصغيرها وإزالة الحدود)
                          SizedBox(
                            height: 140,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              scrollDirection: Axis.horizontal,
                              itemCount: filteredSuppliers.length,
                              itemBuilder: (context, index) {
                                final supplier = filteredSuppliers[index];
                                final heroTag = 'supplier_hero_${supplier.id}';

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      PageTransitions.fadeRoute(
                                        SupplierProfileScreen(
                                          supplier: supplier,
                                          heroTag: heroTag,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    margin: const EdgeInsets.only(left: 12),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        /// صورة المورد
                                        SizedBox(
                                          height: 80,
                                          width: 80,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                            child: Hero(
                                              tag: heroTag,
                                              child: CustomNetworkImage(
                                                imageUrl: supplier.logoUrl ?? '',
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),

                                        /// اسم المورد
                                        Text(
                                          supplier.user?.name ?? "مورد غير معروف",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 20),

                          /// عنوان المنتجات
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              "منتجات من الموردين",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          /// قائمة المنتجات بالتصميم الجديد
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _productsWithSuppliers.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.6,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                            itemBuilder: (context, index) {
                              final item = _productsWithSuppliers[index];
                              final product = item.product;
                              final supplier = item.supplier;
                              final productHeroTag = 'product_hero_${product.id}';

                              return ProductCard(
                                key: ValueKey(product.id),
                                product: product,
                                supplier: supplier,
                                heroTag: productHeroTag,
                                onAddToCart: () {
                                  context.read<CartCubit>().addToCart(
                                    product.id,
                                    1,
                                    product.pivotId ?? 0,
                                  );
                                },
                              );
                            },
                          ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                    const Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: CartSummaryBar(),
                    ),
                  ],
                ),
              );
            }

            if (state is SuppliersError) {
              return EmptyStateWidget(
                message: 'حدث خطأ: ${state.error}',
                icon: Icons.error_outline,
              );
            }

            return const CategoryDetailsShimmerSkeleton();
            },
          ),
        ),
      ),
    );
  }
}

/// كلاس مساعد لتجميع المنتج مع المورد الخاص به
class _ProductWithSupplier {
  final ProductModel product;
  final SupplierModel supplier;

  _ProductWithSupplier(this.product, this.supplier);
}

