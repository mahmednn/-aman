import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_application_11/data_layer/model/supplier.dart';
import 'package:flutter_application_11/data_layer/repository/supplier_repo.dart';

part 'suppliers_state.dart';

class SuppliersCubit extends Cubit<SuppliersState> {
  final SupplierRepo supplierRepo;
  List<SupplierModel> suppliers = [];

  SuppliersCubit({required this.supplierRepo}) : super(SuppliersInitial());

  void getAllSuppliers() async {
    print("SuppliersCubit: getAllSuppliers called. Emitting Loading...");
    emit(SuppliersLoading(const []));
    try {
      final suppliersList = await supplierRepo.getSuppliers();
      print("SuppliersCubit: Data fetched. Count: ${suppliersList.length}");
      emit(SuppliersLoaded(suppliersList));
      suppliers = suppliersList;
    } catch (error) {
      print("SuppliersCubit: Error fetching data: $error");
      emit(SuppliersError(error.toString()));
    }
  }
}
