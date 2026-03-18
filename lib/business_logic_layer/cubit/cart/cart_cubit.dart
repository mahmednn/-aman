import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data_layer/repository/cart_repository.dart';
import '../../../data_layer/model/cart.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartRepository cartRepository;
  static const Set<String> _openStatuses = {'pending', 'active'};

  CartCubit({required this.cartRepository}) : super(CartInitial());

  List<CartModel> currentCarts = [];

  // Getters for UI counts
  int get totalItemsCount {
    int count = 0;
    for (var cart in currentCarts) {
      if (_openStatuses.contains(cart.status)) {
        for (var item in cart.items) {
          count += item.quantity;
        }
      }
    }
    return count;
  }

  double get totalAmount {
    double total = 0;
    for (var cart in currentCarts) {
      if (_openStatuses.contains(cart.status)) {
        total += cart.subtotal.toDouble();
      }
    }
    return total;
  }

  int get pendingCartsCount {
    return currentCarts.where((c) => _openStatuses.contains(c.status)).length;
  }

  int get confirmedCartsCount {
    return currentCarts.where((c) => !_openStatuses.contains(c.status)).length;
  }


  Future<void> loadCarts() async {
    emit(CartLoading());
    try {
      final carts = await cartRepository.getCarts();
      currentCarts = carts;
      emit(CartLoaded(carts: carts));
    } catch (e) {
      emit(CartError(error: e.toString()));
    }
  }

  Future<void> loadCartBySupplier(int supplierId) async {
    emit(CartLoading());
    try {
      final cart = await cartRepository.getCartBySupplier(supplierId);
      if (cart != null) {
        currentCarts = [cart];
        emit(CartLoaded(carts: currentCarts));
      } else {
        // Return empty list if no cart for this supplier
        currentCarts = [];
        emit(CartLoaded(carts: currentCarts));
      }
    } catch (e) {
      emit(CartError(error: e.toString()));
    }
  }

  Future<void> addToCart(int productId, int quantity, int productSupplierId) async {
    if (productSupplierId <= 0) {
      emit(CartActionError(error: 'تعذر إضافة المنتج: معرف ربط المورد/المنتج غير صالح (product_supplier_id غير متوفر).'));
      return;
    }

    emit(CartActionLoading());
    try {
      final response = await cartRepository.addToCart(productId, quantity, productSupplierId);
      emit(CartActionSuccess(message: response['message']));
      // Refresh carts automatically in the background
      await loadCarts();
    } catch (e) {
      emit(CartActionError(error: e.toString()));
      // We still want to reload just in case the UI is stuck
      await loadCarts();
    }
  }

  Future<void> updateCartItemQuantity(int cartItemId, int quantity) async {
    emit(CartActionLoading());
    try {
      final response = await cartRepository.updateCartItem(cartItemId, quantity);
      emit(CartActionSuccess(message: response['message']));
      await loadCarts();
    } catch (e) {
      emit(CartActionError(error: e.toString()));
      await loadCarts();
    }
  }

  Future<void> removeCartItem(int cartItemId) async {
    emit(CartActionLoading());
    try {
      final response = await cartRepository.removeCartItem(cartItemId);
      emit(CartActionSuccess(message: response['message']));
      await loadCarts();
    } catch (e) {
      emit(CartActionError(error: e.toString()));
      await loadCarts();
    }
  }

  Future<void> clearCart(int cartId) async {
    emit(CartActionLoading());
    try {
      final response = await cartRepository.clearCart(cartId);
      emit(CartActionSuccess(message: response['message']));
      await loadCarts();
    } catch (e) {
      emit(CartActionError(error: e.toString()));
      await loadCarts();
    }
  }
}
