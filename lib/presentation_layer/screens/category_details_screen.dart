import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_11/business_logic_layer/cubit/suppliers_cubit.dart';
import 'package:flutter_application_11/business_logic_layer/cubit/cart/cart_cubit.dart';
import 'package:flutter_application_11/business_logic_layer/cubit/cart/cart_state.dart';
import 'package:flutter_application_11/business_logic_layer/cubit/products/products_cubit.dart';
import 'package:flutter_application_11/business_logic_layer/cubit/products/products_state.dart';
import 'package:flutter_application_11/data_layer/model/product.dart' as np;
import 'package:flutter_application_11/presentation_layer/screens/supplier_profile_screen.dart';
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
  List<np.ProductWithSupplier>? _allProductSupplies;
  
  @override
  void initState() {
    super.initState();
    // جلب المنتجات والموردين المرتبطين بهذه الفئة إذا لزم الأمر
    context.read<SuppliersCubit>().getAllSuppliers();
    context.read<ProductsCubit>().getAllProducts();
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

              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _allProductSupplies = null;
                  });
                  context.read<SuppliersCubit>().getAllSuppliers();
                  context.read<ProductsCubit>().getAllProducts();
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
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: filteredSuppliers.length,
                              itemBuilder: (context, index) {
                                final supplier = filteredSuppliers[index];
                                final heroTag = 'supplier_${supplier.id}';
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      PageTransitions.slideRoute(
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
                                      children: [
                                        Hero(
                                          tag: heroTag,
                                          child: Container(
                                            width: 80,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: supplier.logoUrl != null
                                                  ? DecorationImage(
                                                      image: NetworkImage(
                                                          supplier.logoUrl!),
                                                      fit: BoxFit.cover,
                                                    )
                                                  : null,
                                            ),
                                            child: supplier.logoUrl == null
                                                ? Icon(
                                                    Icons.store,
                                                    size: 40,
                                                    color: Colors.white
                                                        .withValues(alpha: 0.5),
                                                  )
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          supplier.user?.name ?? 'بدون اسم',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          supplier.address ?? '',
                                          style: TextStyle(
                                            color: Colors.white
                                                .withValues(alpha: 0.6),
                                            fontSize: 10,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

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
                          BlocBuilder<ProductsCubit, ProductsState>(
                            builder: (context, productsState) {
                              if (productsState is ProductsLoading) {
                                return const Center(child: CircularProgressIndicator(color: primaryAccent));
                              } else if (productsState is ProductsLoaded) {
                                if (_allProductSupplies == null) {
                                  final categoryProducts = productsState.products
                                      .where((p) => p.productCategoryId == widget.categoryId)
                                      .toList();
                                  
                                  _allProductSupplies = [];
                                  for (final product in categoryProducts) {
                                    for (final supplierInfo in product.suppliers) {
                                      _allProductSupplies!.add(np.ProductWithSupplier(
                                        product: product,
                                        supplierInfo: supplierInfo,
                                        prefix: 'category_product',
                                      ));
                                    }
                                  }
                                  
                                  _allProductSupplies!.shuffle();
                                }

                                if (_allProductSupplies!.isEmpty) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20.0),
                                      child: Text('لا توجد منتجات', style: TextStyle(color: Colors.white)),
                                    ),
                                  );
                                }

                                return GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: _allProductSupplies!.length,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        childAspectRatio: 0.6,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
                                      ),
                                  itemBuilder: (context, index) {
                                    final item = _allProductSupplies![index];
                                    final product = item.product;
                                    final supplierInfo = item.supplierInfo;
                                    final productHeroTag = item.heroTag;

                                    return ProductCard(
                                      key: ValueKey('${product.id}_${supplierInfo.productSupplierId}'),
                                      product: product,
                                      supplierInfo: supplierInfo,
                                      heroTag: productHeroTag,
                                      onAddToCart: () {
                                        context.read<CartCubit>().addToCart(
                                          product.id,
                                          1,
                                          supplierInfo.productSupplierId,
                                        );
                                      },
                                    );
                                  },
                                );
                              }
                              return const SizedBox();
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
