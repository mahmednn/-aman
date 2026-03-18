import '../../../data_layer/model/cart.dart';

abstract class CartState {}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<CartModel> carts;

  CartLoaded({required this.carts});
}

class CartError extends CartState {
  final String error;

  CartError({required this.error});
}

class CartActionLoading extends CartState {}

class CartActionSuccess extends CartState {
  final String message;

  CartActionSuccess({required this.message});
}

class CartActionError extends CartState {
  final String error;

  CartActionError({required this.error});
}
