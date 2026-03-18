import 'package:dio/dio.dart';
import '../../constants/api_routes.dart';

class LocationServices {
  final Dio dio;

  LocationServices({required this.dio});

  Future<dynamic> getLocations() async {
    try {
      Response response = await dio.get(ApiRoutes.customerLocations);
      return response.data;
    } catch (e) {
      if (e is DioException && e.response != null) {
        return e.response!.data;
      }
      return {'status': false, 'message': e.toString()};
    }
  }

  Future<dynamic> addLocation({
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    bool isDefault = false,
  }) async {
    try {
      Response response = await dio.post(
        ApiRoutes.customerLocations,
        data: {
          'name': name,
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
          'is_default': isDefault ? 1 : 0,
        },
      );
      return response.data;
    } catch (e) {
      if (e is DioException && e.response != null) {
        return e.response!.data;
      }
      return {'status': false, 'message': e.toString()};
    }
  }

  Future<dynamic> updateLocation({
    required int id,
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    bool isDefault = false,
  }) async {
    try {
      Response response = await dio.put(
        ApiRoutes.customerLocationById(id),
        data: {
          'name': name,
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
          'is_default': isDefault ? 1 : 0,
        },
      );
      return response.data;
    } catch (e) {
      if (e is DioException && e.response != null) {
        return e.response!.data;
      }
      return {'status': false, 'message': e.toString()};
    }
  }

  Future<dynamic> deleteLocation(int id) async {
    try {
      Response response = await dio.delete(ApiRoutes.customerLocationById(id));
      return response.data;
    } catch (e) {
      if (e is DioException && e.response != null) {
        return e.response!.data;
      }
      return {'status': false, 'message': e.toString()};
    }
  }

  Future<dynamic> setDefaultLocation(int id) async {
    try {
      Response response = await dio.post(
        ApiRoutes.setDefaultCustomerLocation(id),
      );
      return response.data;
    } catch (e) {
      if (e is DioException && e.response != null) {
        return e.response!.data;
      }
      return {'status': false, 'message': e.toString()};
    }
  }
}
