import 'package:dio/dio.dart';
import '../model/customer_location_model.dart';
import '../model/selected_location.dart';
import '../web_services/location_services.dart';

class LocationRepository {
  final LocationServices locationServices;

  LocationRepository(this.locationServices);

  Future<LocationResponse> getLocations() async {
    return _handleApiCall(() => locationServices.getLocations());
  }

  Future<LocationResponse> addLocation(SelectedLocation location) async {
    return _handleApiCall(
      () => locationServices.addLocation(
        name: location.name ?? "موقع جديد",
        address: location.address ?? "",
        latitude: location.latitude,
        longitude: location.longitude,
      ),
    );
  }

  Future<LocationResponse> updateLocation({
    required int id,
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    bool isDefault = false,
  }) async {
    return _handleApiCall(
      () => locationServices.updateLocation(
        id: id,
        name: name,
        address: address,
        latitude: latitude,
        longitude: longitude,
        isDefault: isDefault,
      ),
    );
  }

  Future<LocationResponse> deleteLocation(int id) async {
    return _handleApiCall(() => locationServices.deleteLocation(id));
  }

  Future<LocationResponse> setDefaultLocation(int id) async {
    return _handleApiCall(() => locationServices.setDefaultLocation(id));
  }

  // Wrapper to catch Dio exceptions uniquely
  Future<LocationResponse> _handleApiCall(
    Future<dynamic> Function() apiCall,
  ) async {
    try {
      final response = await apiCall();
      if (response is List) {
        final List data = response;
        return LocationResponse(
          status: true,
          data: data
              .map(
                (e) =>
                    CustomerLocationModel.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
        );
      } else if (response is Map<String, dynamic>) {
        return LocationResponse.fromJson(response);
      }
      return LocationResponse(
        status: false,
        message: "استجابة غير متوقعة من الخادم",
      );
    } on DioException catch (e) {
      String robustMessage = "حدث خطأ غير متوقع بالاتصال";
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        robustMessage = "لا يوجد اتصال بالإنترنت أو الخادم غير متصل";
      } else if (e.response != null) {
        switch (e.response?.statusCode) {
          case 401:
            robustMessage = "جلستك منتهية، يرجى تسجيل الدخول مجدداً";
            break;
          case 403:
            robustMessage = "غير مصرح لك باتخاذ هذا الإجراء";
            break;
          case 422:
            robustMessage = "البيانات المدخلة غير صحيحة";
            break;
          case 500:
            robustMessage = "خطأ في خوادم النظام (500)";
            break;
        }
      }
      return LocationResponse(status: false, message: robustMessage);
    } catch (e, stackTrace) {
      print("LocationRepository _handleApiCall Exception: $e\n$stackTrace");
      return LocationResponse(
        status: false,
        message: "استجابة غير صالحة من الخادم",
      );
    }
  }
}
