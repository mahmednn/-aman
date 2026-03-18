import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_application_11/business_logic_layer/cubit/suppliers_cubit.dart';
import 'package:flutter_application_11/data_layer/model/supplier.dart';
import 'package:flutter_application_11/constants/strings.dart';
import 'package:flutter_application_11/presentation_layer/screens/supplier_profile_screen.dart';
import 'package:flutter_application_11/presentation_layer/widgets/custom_network_image.dart';
import 'package:flutter_application_11/presentation_layer/widgets/custom_back_button.dart';
import 'package:flutter_application_11/presentation_layer/widgets/loading_and_empty_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

class SupplierScreen extends StatefulWidget {
  const SupplierScreen({super.key});

  @override
  State<SupplierScreen> createState() => _SupplierScreenState();
}

class _SupplierScreenState extends State<SupplierScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<SupplierModel> _filteredSuppliers = [];
  List<SupplierModel> _allSuppliers = [];

  @override
  void initState() {
    super.initState();
    context.read<SuppliersCubit>().getAllSuppliers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterSuppliers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSuppliers = _allSuppliers;
      } else {
        _filteredSuppliers = _allSuppliers.where((supplier) {
          final name = supplier.user?.name.toLowerCase() ?? '';
          final category = supplier.supplierCategory?.name.toLowerCase() ?? '';
          return name.contains(query.toLowerCase()) ||
              category.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: mainBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const CustomBackButton(),
        centerTitle: true,
        title: const Text(
          'الموردون',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: mainBackgroundGradient),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<SuppliersCubit>().getAllSuppliers();
            },
            color: primaryAccent,
            backgroundColor: cardColor,
            child: Column(
              children: [
                _buildSearchBar(),
                Expanded(
                  child: BlocBuilder<SuppliersCubit, SuppliersState>(
                    builder: (context, state) {
                      if (state is SuppliersLoading ||
                          state is SuppliersInitial) {
                        return _buildShimmerList();
                      } else if (state is SuppliersLoaded) {
                        _allSuppliers = state.suppliers;
                        if (_searchController.text.isEmpty) {
                          _filteredSuppliers = _allSuppliers;
                        }

                        if (_filteredSuppliers.isEmpty) {
                          return const EmptyStateWidget(
                            message: 'لا يوجد موردين متاحين حالياً',
                            icon: Icons.store_outlined,
                          );
                        }
                        return _buildSupplierList();
                      } else if (state is SuppliersError) {
                        return EmptyStateWidget(
                          message: 'حدث خطأ: ${state.error}',
                          icon: Icons.error_outline,
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: glassBackground,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: glassBorder),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _filterSuppliers,
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: 'ابحث عن مورد...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            prefixIcon: const Icon(Icons.search, color: primaryAccent),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSupplierList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _filteredSuppliers.length,
      itemBuilder: (context, index) {
        final supplier = _filteredSuppliers[index];
        return _buildSupplierItem(supplier);
      },
    );
  }

  Widget _buildSupplierItem(SupplierModel supplier) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SupplierProfileScreen(
              supplier: supplier,
              heroTag: 'list_supplier_hero_${supplier.id}',
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: glassBackground,
          borderRadius: BorderRadius.circular(defaultBorderRadius),
          border: Border.all(color: glassBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(defaultBorderRadius),
              ),
              child: Hero(
                tag: 'list_supplier_hero_${supplier.id}',
                child: CustomNetworkImage(
                  imageUrl: supplier.logoUrl ?? '',
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: Container(
                    height: 160,
                    color: Colors.white10,
                    child: const Icon(
                      Icons.store,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          supplier.user?.name ?? 'مورد غير معروف',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            supplier.rating?.toString() ?? '0.0',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.star, color: Colors.amber, size: 18),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  if (supplier.supplierCategory?.name != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          supplier.supplierCategory!.name,
                          style: const TextStyle(
                            fontSize: 13,
                            color: textSecondary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.category_outlined,
                          size: 14,
                          color: textSecondary,
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: primaryAccent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        supplier.address ?? 'ليبيا',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
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
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: cardColor,
          highlightColor: Colors.grey[700]!,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 240,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(defaultBorderRadius),
            ),
          ),
        );
      },
    );
  }
}
