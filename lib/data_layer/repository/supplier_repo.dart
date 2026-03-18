import 'package:flutter_application_11/data_layer/model/supplier.dart';
import 'package:flutter_application_11/data_layer/web_services/supplier_services.dart';

class SupplierRepo {
  final SupplierServices supplierServ;

  SupplierRepo({required this.supplierServ});

  Future<List<SupplierModel>> getSuppliers() async {
    final response = await supplierServ.getSuppliers();

    return response
        .map((supplierJson) => SupplierModel.fromJson(supplierJson))
        .toList();
  }
}
