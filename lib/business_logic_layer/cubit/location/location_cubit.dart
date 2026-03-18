import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data_layer/repository/location_repo.dart';
import '../../../data_layer/model/selected_location.dart';
import 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  final LocationRepository repository;

  LocationCubit(this.repository) : super(LocationState());

  Future<void> getLocations() async {
    emit(
      state.copyWith(
        status: LocationStatus.loading,
        action: LocationAction.fetch,
      ),
    );
    try {
      final response = await repository.getLocations();
      if (response.status) {
        emit(
          state.copyWith(
            status: LocationStatus.success,
            locations: response.data ?? [],
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: LocationStatus.failure,
            errorMessage: response.message ?? "فشل جلب المواقع",
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: LocationStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> addLocation(SelectedLocation location) async {
    emit(
      state.copyWith(
        status: LocationStatus.loading,
        action: LocationAction.add,
      ),
    );
    try {
      final response = await repository.addLocation(location);
      if (response.status) {
        final fetchResp = await repository.getLocations();
        final updatedList = fetchResp.status
            ? (fetchResp.data ?? [])
            : state.locations;
        emit(
          state.copyWith(
            status: LocationStatus.success,
            locations: updatedList,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: LocationStatus.failure,
            errorMessage: response.message ?? "فشل إضافة الموقع",
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: LocationStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> deleteLocation(int id) async {
    emit(
      state.copyWith(
        status: LocationStatus.loading,
        action: LocationAction.delete,
      ),
    );
    try {
      final response = await repository.deleteLocation(id);
      if (response.status) {
        final fetchResp = await repository.getLocations();
        final updatedList = fetchResp.status
            ? (fetchResp.data ?? [])
            : state.locations;
        emit(
          state.copyWith(
            status: LocationStatus.success,
            locations: updatedList,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: LocationStatus.failure,
            errorMessage: response.message,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: LocationStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> setDefaultLocation(int id) async {
    emit(
      state.copyWith(
        status: LocationStatus.loading,
        action: LocationAction.setDefault,
      ),
    );
    try {
      final response = await repository.setDefaultLocation(id);
      if (response.status) {
        final fetchResp = await repository.getLocations();
        final updatedList = fetchResp.status
            ? (fetchResp.data ?? [])
            : state.locations;
        emit(
          state.copyWith(
            status: LocationStatus.success,
            locations: updatedList,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: LocationStatus.failure,
            errorMessage: response.message,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: LocationStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
