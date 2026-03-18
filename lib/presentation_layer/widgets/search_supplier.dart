import 'package:flutter/material.dart';
import 'package:flutter_application_11/data_layer/model/supplier.dart';

class SearchSupplier extends StatefulWidget {
  const SearchSupplier({
    super.key,
    required this.allsuppliers,
    required this.isSearching,
    required this.searchController,
  });

  final bool isSearching;
  final TextEditingController searchController;
  final List<SupplierModel> allsuppliers;

  @override
  State<SearchSupplier> createState() => _SearchSupplierState();
}

class _SearchSupplierState extends State<SearchSupplier> {
  late List<SupplierModel> searchsuppliers;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.searchController,
      onChanged: (value) {
        addSearchedSuppliers(value);
      },
      decoration: InputDecoration(
        hintText: 'ابحث عن مورد',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.shade200,
      ),
    );
  }

  void addSearchedSuppliers(String value) {
    searchsuppliers = widget.allsuppliers
        .where(
          (supplier) =>
              supplier.user?.name.toLowerCase().startsWith(
                value.toLowerCase(),
              ) ??
              false,
        )
        .toList();
  }
}
