part of 'suppliers_cubit.dart';

sealed class SuppliersState extends Equatable {
  const SuppliersState();

  @override
  List<Object> get props => [];
}

final class SuppliersInitial extends SuppliersState {}

class SuppliersLoading extends SuppliersState {
  final List<SupplierModel> suppliers;
  const SuppliersLoading(this.suppliers);
  @override
  List<Object> get props => [suppliers];
}

class SuppliersLoaded extends SuppliersState {
  final List<SupplierModel> suppliers;
  const SuppliersLoaded(this.suppliers);

  @override
  List<Object> get props => [suppliers];
}

class SuppliersError extends SuppliersState {
  final String error;
  const SuppliersError(this.error);
  @override
  List<Object> get props => [error];
}
