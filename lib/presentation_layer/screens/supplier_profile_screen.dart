import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_11/business_logic_layer/cubit/cart/cart_cubit.dart';
import 'package:flutter_application_11/business_logic_layer/cubit/cart/cart_state.dart';
import 'package:flutter_application_11/data_layer/model/supplier.dart';
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
                // عرض المنتجات كقائمة
                if (widget.supplier.products?.isEmpty ?? true)
                  const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Text(
                          "لا توجد منتجات متوفرة حالياً",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.6,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final product = widget.supplier.products![index];
                        final productHeroTag =
                            'supplier_product_hero_${product.id}';

                        return ProductCard(
                          key: ValueKey(product.id),
                          product: product,
                          supplier: widget.supplier,
                          heroTag: productHeroTag,
                          onAddToCart: () {
                             context.read<CartCubit>().addToCart(product.id, 1, product.pivotId ?? 0);
                          },
                        );
                      }, childCount: widget.supplier.products?.length ?? 0),
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

