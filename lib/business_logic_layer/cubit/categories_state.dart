part of 'categories_cubit.dart';

sealed class CategoriesState extends Equatable {
  const CategoriesState();

  @override
  List<Object> get props => [];
}

final class CategoriesInitial extends CategoriesState {}

class CategoriesLoading extends CategoriesState {
  final List<CategoryModel> categories;
  const CategoriesLoading(this.categories);
  @override
  List<Object> get props => [categories];
}

class CategoriesLoaded extends CategoriesState {
  final List<CategoryModel> categories;
  const CategoriesLoaded(this.categories);
  @override
  List<Object> get props => [categories];
}

class CategoriesError extends CategoriesState {
  final String error;
  const CategoriesError(this.error);
  @override
  List<Object> get props => [error];
}
