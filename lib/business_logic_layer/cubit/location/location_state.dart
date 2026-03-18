import '../../../data_layer/model/customer_location_model.dart';

enum LocationStatus { initial, loading, success, failure }

enum LocationAction { none, fetch, add, delete, update, setDefault }

class LocationState {
  final LocationStatus status;
  final LocationAction action;
  final List<CustomerLocationModel> locations;
  final String? errorMessage;

  LocationState({
    this.status = LocationStatus.initial,
    this.action = LocationAction.none,
    this.locations = const [],
    this.errorMessage,
  });

  LocationState copyWith({
    LocationStatus? status,
    LocationAction? action,
    List<CustomerLocationModel>? locations,
    String? errorMessage,
  }) {
    return LocationState(
      status: status ?? this.status,
      action: action ?? this.action,
      locations: locations ?? this.locations,
      errorMessage:
          errorMessage ??
          (status == LocationStatus.failure ? this.errorMessage : null),
    );
  }
}
