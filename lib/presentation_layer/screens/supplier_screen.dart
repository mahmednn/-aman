import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_application_11/business_logic_layer/cubit/suppliers_cubit.dart';
import 'package:flutter_application_11/business_logic_layer/cubit/categories_cubit.dart';
import 'package:flutter_application_11/data_layer/model/supplier.dart';
import 'package:flutter_application_11/data_layer/model/category.dart';
import 'package:flutter_application_11/constants/strings.dart';
import 'package:flutter_application_11/presentation_layer/widgets/loading_and_empty_states.dart';
import 'package:flutter_application_11/presentation_layer/widgets/supplier_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SupplierScreen extends StatefulWidget {
  const SupplierScreen({super.key});

  @override
  State<SupplierScreen> createState() => _SupplierScreenState();
}

class _SupplierScreenState extends State<SupplierScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<SupplierModel> _filteredSuppliers = [];
  List<SupplierModel> _allSuppliers = [];
  int? _selectedCategoryId;
  List<dynamic> _categories = [];

  @override
  void initState() {
    super.initState();
    final suppliersCubit = context.read<SuppliersCubit>();
    final categoriesCubit = context.read<CategoriesCubit>();

    if (suppliersCubit.state is SuppliersLoaded) {
      _allSuppliers = (suppliersCubit.state as SuppliersLoaded).suppliers;
      _applyFilters();
    }
    
    if (categoriesCubit.state is CategoriesLoaded) {
      _categories = (categoriesCubit.state as CategoriesLoaded).categories;
    }

    suppliersCubit.getAllSuppliers();
    categoriesCubit.getAllCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    _filteredSuppliers = _allSuppliers.where((supplier) {
      final matchesQuery = query.isEmpty ||
          (supplier.user?.name.toLowerCase().contains(query) ?? false) ||
          (supplier.supplierCategory?.name.toLowerCase().contains(query) ?? false);

      final matchesCategory = _selectedCategoryId == null ||
          supplier.supplierCategoryId == _selectedCategoryId;

      return matchesQuery && matchesCategory;
    }).toList();
  }

  void _filterSuppliers() {
    setState(() {
      _applyFilters();
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
        automaticallyImplyLeading: false,
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
                _buildCategoryFilters(),
                Expanded(
                  child: MultiBlocListener(
                    listeners: [
                      BlocListener<SuppliersCubit, SuppliersState>(
                        listener: (context, state) {
                          if (state is SuppliersLoaded) {
                            _allSuppliers = state.suppliers;
                            _applyFilters();
                          }
                        },
                      ),
                      BlocListener<CategoriesCubit, CategoriesState>(
                        listener: (context, state) {
                          if (state is CategoriesLoaded) {
                            setState(() {
                              _categories = state.categories;
                            });
                          }
                        },
                      ),
                    ],
                    child: BlocBuilder<SuppliersCubit, SuppliersState>(
                      builder: (context, state) {
                        if (state is SuppliersLoading ||
                            state is SuppliersInitial) {
                          return _buildShimmerList();
                        } else if (state is SuppliersLoaded) {
                          if (_filteredSuppliers.isEmpty &&
                              _searchController.text.isEmpty &&
                              _selectedCategoryId == null) {
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
          onChanged: (_) => _filterSuppliers(),
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

  Widget _buildCategoryFilters() {
    if (_categories.isEmpty && _selectedCategoryId == null) {
      return const SizedBox.shrink();
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: 50,
        margin: const EdgeInsets.only(bottom: 8),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _categories.length + 1,
          reverse: false, // In RTL, this starts from the right
          itemBuilder: (context, index) {
            final isSelected = index == 0
                ? _selectedCategoryId == null
                : _selectedCategoryId == _categories[index - 1].id;
      
            final categoryName = index == 0 ? 'الكل' : _categories[index - 1].name;
      
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: ChoiceChip(
                label: Text(
                  categoryName,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategoryId =
                        index == 0 ? null : _categories[index - 1].id;
                    _filterSuppliers();
                  });
                },
                selectedColor: primaryAccent,
                backgroundColor: Colors.white.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? primaryAccent : Colors.white24,
                  ),
                ),
                showCheckmark: false,
              ),
            );
          },
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
        return SupplierCard(
          supplier: supplier,
          heroTag: 'list_supplier_hero_${supplier.id}',
        );
      },
    );
  }

  Widget _buildShimmerList() {
    return const SupplierListLoadingSkeleton(itemCount: 5);
  }
}
