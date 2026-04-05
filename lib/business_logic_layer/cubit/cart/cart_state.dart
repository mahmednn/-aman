import '../../../data_layer/model/cart.dart';
import '../../../data_layer/model/vehicle.dart';
import '../../../data_layer/model/checkout_preview.dart';

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

class CheckoutPreviewLoaded extends CartState {
  final CheckoutPreviewModel checkoutPreview;
  
  CheckoutPreviewLoaded({required this.checkoutPreview});
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

class CartVehicleTypesLoading extends CartState {}

class CartVehicleTypesLoaded extends CartState {
  final List<VehicleModel> vehicles;

  CartVehicleTypesLoaded({required this.vehicles});
}

class CartVehicleTypesError extends CartState {
  final String error;

  CartVehicleTypesError({required this.error});
}

class CheckoutConfirmLoading extends CartState {}

class CheckoutConfirmSuccess extends CartState {
  final String message;
  final String? url;

  CheckoutConfirmSuccess({required this.message, this.url});
}

class CheckoutConfirmError extends CartState {
  final String error;

  CheckoutConfirmError({required this.error});
}
