import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_11/business_logic_layer/cubit/cart/cart_cubit.dart';
import 'package:flutter_application_11/business_logic_layer/cubit/cart/cart_state.dart';
import 'package:flutter_application_11/business_logic_layer/cubit/products/products_cubit.dart';
import 'package:flutter_application_11/business_logic_layer/cubit/products/products_state.dart';
import 'package:flutter_application_11/data_layer/model/supplier.dart';
import 'package:flutter_application_11/data_layer/model/product.dart' as np;
import 'package:flutter_application_11/presentation_layer/widgets/custom_network_image.dart';
import 'package:flutter_application_11/presentation_layer/widgets/product_card.dart';
import 'package:flutter_application_11/presentation_layer/widgets/custom_back_button.dart';
import 'package:flutter_application_11/presentation_layer/widgets/cart_summary_bar.dart';
import 'package:flutter_application_11/constants/strings.dart';

class SupplierProfileScreen extends StatefulWidget {
  final SupplierModel supplier;
  final String? heroTag;
  const SupplierProfileScreen({
    super.key,
    required this.supplier,
    this.heroTag,
  });

  @override
  State<SupplierProfileScreen> createState() => _SupplierProfileScreenState();
}

class _SupplierProfileScreenState extends State<SupplierProfileScreen> {
  @override
  void initState() {
    super.initState();
    final productsState = context.read<ProductsCubit>().state;
    if (productsState is! ProductsLoaded) {
      context.read<ProductsCubit>().getAllProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainBgColor,
      body: BlocListener<CartCubit, CartState>(
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
        child: Stack(
          children: [
            Directionality(
              textDirection: TextDirection.rtl,
              child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 300.0,
                  pinned: true,
                  stretch: true,
                  backgroundColor: mainBgColor,
                  leading: const CustomBackButton(),
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      widget.supplier.user?.name ?? 'اسم المورد',
                      style: const TextStyle(
                        color: textPrimary,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                      ),
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Hero(
                          tag:
                              widget.heroTag ??
                              'supplier_hero_${widget.supplier.id}',
                          child: CustomNetworkImage(
                            imageUrl: widget.supplier.logoUrl ?? '',
                            fit: BoxFit.cover,
                          ),
                        ),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black54],
                              stops: [0.6, 1.0],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star, color: warningColor, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              "${widget.supplier.rating ?? '0.0'} (تقييم العملاء)",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "المنتجات المتوفرة",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                
                // عرض المنتجات كقائمة باستخدام ProductsCubit
                SliverToBoxAdapter(
                  child: BlocBuilder<ProductsCubit, ProductsState>(
                    builder: (context, productsState) {
                      if (productsState is ProductsLoading) {
                        return const Center(child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: CircularProgressIndicator(),
                        ));
                      } else if (productsState is ProductsLoaded) {
                        final supplierProducts = <np.ProductWithSupplier>[];
                        for (final product in productsState.products) {
                          for (final supplierInfo in product.suppliers) {
                            if (supplierInfo.supplierId == widget.supplier.id) {
                              supplierProducts.add(np.ProductWithSupplier(
                                product: product,
                                supplierInfo: supplierInfo,
                                prefix: 'supplier_product',
                              ));
                            }
                          }
                        }
                        
                        if (supplierProducts.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Text(
                                "لا توجد منتجات متوفرة حالياً",
                                style: TextStyle(color: Colors.white70, fontSize: 16),
                              ),
                            ),
                          );
                        }
                        
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: supplierProducts.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.6,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemBuilder: (context, index) {
                            final item = supplierProducts[index];
                            final productHeroTag = item.heroTag;
                            
                            return ProductCard(
                              key: ValueKey('${item.product.id}_${item.supplierInfo.productSupplierId}'),
                              product: item.product,
                              supplierInfo: item.supplierInfo,
                              heroTag: productHeroTag,
                              onAddToCart: () {
                                context.read<CartCubit>().addToCart(
                                  item.product.id, 
                                  1, 
                                  item.supplierInfo.productSupplierId
                                );
                              },
                            );
                          },
                        );
                      } else if (productsState is ProductsError) {
                        return Center(child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Text(productsState.message, style: const TextStyle(color: dangerColor)),
                        ));
                      }
                      return const SizedBox();
                    },
                  ),
                ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
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
      ),
    );
  }
}
