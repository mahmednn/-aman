import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_11/data_layer/repository/product_repository.dart';
import 'package:flutter_application_11/business_logic_layer/cubit/products/products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  final ProductRepository productRepository;

  ProductsCubit(this.productRepository) : super(ProductsInitial());

  Future<void> getAllProducts() async {
    try {
      emit(ProductsLoading());
      final products = await productRepository.getAllProducts();
      emit(ProductsLoaded(products));
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }
}
