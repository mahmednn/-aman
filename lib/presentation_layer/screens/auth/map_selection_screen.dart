import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_11/presentation_layer/widgets/custom_back_button.dart';

import 'package:flutter_application_11/business_logic_layer/cubit/auth/auth_cubit.dart';
import 'package:flutter_application_11/business_logic_layer/cubit/auth/auth_state.dart';
import '../../../constants/strings.dart';
import '../../../data_layer/model/selected_location.dart';

class MapSelectionScreen extends StatefulWidget {
  const MapSelectionScreen({super.key});

  @override
  State<MapSelectionScreen> createState() => _MapSelectionScreenState();
}

class _MapSelectionScreenState extends State<MapSelectionScreen> {
  GoogleMapController? controller;
  LatLng? _selectedPoint;
  List<SelectedLocation> _selectedPoints = [];
  final Set<Marker> _markers = {};
  bool _isRegisterFlow = false;
  bool _allowMultiple = false;

  final List<List<double>> allowedArea = [
    [33.5, 9.0],
    [33.5, 25.5],
    [19.0, 25.5],
    [19.0, 9.0],
    [33.5, 9.0],
  ];

  bool _isPointInPolygon(LatLng point, List<List<double>> polygon) {
    int intersectCount = 0;
    for (int j = 0; j < polygon.length - 1; j++) {
      double vertex1Lat = polygon[j][0];
      double vertex1Lon = polygon[j][1];
      double vertex2Lat = polygon[j + 1][0];
      double vertex2Lon = polygon[j + 1][1];

      if (((vertex1Lon > point.longitude) != (vertex2Lon > point.longitude)) &&
          (point.latitude <
              (vertex2Lat - vertex1Lat) *
                      (point.longitude - vertex1Lon) /
                      (vertex2Lon - vertex1Lon) +
                  vertex1Lat)) {
        intersectCount++;
      }
    }
    return intersectCount % 2 == 1;
  }

  Future<String> _getAddressFromLatLng(LatLng point) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        // Combine available fields for a readable address
        List<String> addressParts = [];
        if (place.street != null && place.street!.isNotEmpty)
          addressParts.add(place.street!);
        if (place.subLocality != null && place.subLocality!.isNotEmpty)
          addressParts.add(place.subLocality!);
        if (place.locality != null && place.locality!.isNotEmpty)
          addressParts.add(place.locality!);
        return addressParts.join(', ');
      }
    } catch (e) {
      debugPrint("Geocoding failed: $e");
    }
    return '';
  }

  Future<Map<String, String>?> _showNameAndDescDialog({
    String? initialDesc,
  }) async {
    String name = "";
    String desc = initialDesc ?? "";
    TextEditingController descController = TextEditingController(text: desc);

    return showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: secondaryBgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            "تسمية الموقع",
            style: TextStyle(color: textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                decoration: InputDecoration(
                  labelText: "اسم الموقع",
                  labelStyle: TextStyle(color: primaryAccent),
                  hintText: "مثال: المنزل، العمل...",
                  hintStyle: TextStyle(color: textSecondary),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: glassBorder),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: primaryAccent),
                  ),
                ),
                style: TextStyle(color: textPrimary),
                onChanged: (val) => name = val,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: InputDecoration(
                  labelText: "عنوان الموقع",
                  labelStyle: TextStyle(color: primaryAccent),
                  hintText: "الشارع، المنطقة...",
                  hintStyle: TextStyle(color: textSecondary),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: glassBorder),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: primaryAccent),
                  ),
                ),
                style: TextStyle(color: textPrimary),
                onChanged: (val) => desc = val,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "إلغاء",
                style: TextStyle(color: textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                final n = name.trim().isEmpty ? "موقع جديد" : name.trim();
                Navigator.pop(context, {'name': n, 'description': desc.trim()});
              },
              child: const Text(
                "حفظ",
                style: TextStyle(
                  color: primaryAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _handleLocationPermission() async {
    debugPrint("LOCATION_DEBUG: _handleLocationPermission called");
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    debugPrint("LOCATION_DEBUG: isLocationServiceEnabled: $serviceEnabled");
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("يرجى تفعيل خدمة GPS للحصول على موقعك الدقيق"),
            backgroundColor: dangerColor,
          ),
        );
      }
      return false;
    }

    permission = await Geolocator.checkPermission();
    debugPrint("LOCATION_DEBUG: initial permission check: $permission");
    if (permission == LocationPermission.denied) {
      debugPrint("LOCATION_DEBUG: Requesting permission...");
      permission = await Geolocator.requestPermission();
      debugPrint("LOCATION_DEBUG: permission request result: $permission");
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("تم رفض صلاحيات الموقع"),
              backgroundColor: dangerColor,
            ),
          );
        }
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("الرجاء تفعيل صلاحيات الموقع من إعدادات الهاتف"),
            backgroundColor: dangerColor,
          ),
        );
      }
      return false;
    }
    return true;
  }

  void _updateMarkers() {
    _markers.clear();

    if (_allowMultiple) {
      for (int i = 0; i < _selectedPoints.length; i++) {
        final point = _selectedPoints[i];
        _markers.add(
          Marker(
            markerId: MarkerId('point_$i'),
            position: LatLng(point.latitude, point.longitude),
            infoWindow: InfoWindow(title: point.name, snippet: point.address),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
          ),
        );
      }
    } else if (_selectedPoint != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('selected_point'),
          position: _selectedPoint!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }
    setState(() {});
  }

  void _onMapTap(LatLng point) async {
    if (!_isPointInPolygon(point, allowedArea)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("هذا الموقع خارج النطاق المسموح به"),
            backgroundColor: dangerColor,
          ),
        );
      }
      return;
    }

    if (_allowMultiple) {
      String addressPreview = await _getAddressFromLatLng(point);
      Map<String, String>? details = await _showNameAndDescDialog(
        initialDesc: addressPreview,
      );
      if (details != null) {
        setState(() {
          _selectedPoints.add(
            SelectedLocation(
              name: details['name'],
              address: details['description'],
              latitude: point.latitude,
              longitude: point.longitude,
            ),
          );
        });
        _updateMarkers();
      }
    } else {
      setState(() {
        _selectedPoint = point;
      });
      _updateMarkers();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _isRegisterFlow = args['isRegisterFlow'] ?? false;
      _allowMultiple = args['allowMultiple'] ?? false;
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> _handleInitialLocation() async {
    debugPrint("LOCATION_DEBUG: _handleInitialLocation started");
    final hasPermission = await _handleLocationPermission();
    debugPrint("LOCATION_DEBUG: hasPermission: $hasPermission");
    if (!hasPermission) {
      return;
    }

    try {
      debugPrint("LOCATION_DEBUG: Fetching current position (with 10s timeout)...");
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: AndroidSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: const Duration(seconds: 10),
            forceLocationManager: true,
          ),
        );
      } catch (e) {
        debugPrint("LOCATION_DEBUG: getCurrentPosition error or timeout: $e");
      }

      if (position == null) {
        debugPrint("LOCATION_DEBUG: Trying getLastKnownPosition as fallback...");
        position = await Geolocator.getLastKnownPosition();
      }

      if (position != null) {
        debugPrint(
          "LOCATION_DEBUG: Position determined: ${position.latitude}, ${position.longitude}",
        );

        LatLng myLoc = LatLng(position.latitude, position.longitude);

        bool isInPolygon = _isPointInPolygon(myLoc, allowedArea);
        debugPrint("LOCATION_DEBUG: isWithinAllowedArea: $isInPolygon");

        if (isInPolygon) {
          controller?.animateCamera(CameraUpdate.newLatLngZoom(myLoc, 15));
          if (!_allowMultiple) {
            setState(() {
              _selectedPoint = myLoc;
            });
            _updateMarkers();
          }
        } else {
          controller?.animateCamera(
            CameraUpdate.newLatLngZoom(const LatLng(32.8872, 13.1913), 12),
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("موقعك الحالي خارج النطاق المسموح به"),
                backgroundColor: dangerColor,
              ),
            );
          }
        }
      } else {
        debugPrint("LOCATION_DEBUG: Could not determine location at all.");
        controller?.animateCamera(
          CameraUpdate.newLatLngZoom(const LatLng(32.8872, 13.1913), 12),
        );
      }
    } catch (e) {
      debugPrint("LOCATION_DEBUG: Error in _handleInitialLocation: $e");
      controller?.animateCamera(
        CameraUpdate.newLatLngZoom(const LatLng(32.8872, 13.1913), 12),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainBgColor,
      appBar: AppBar(
        title: const Text(
          "اختر الموقع",
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const CustomBackButton(),
      ),
      extendBodyBehindAppBar: true,
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is UpdateLocationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("تم حفظ الموقع بنجاح"),
                backgroundColor: successColor,
              ),
            );
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(supplierScreen, (route) => false);
          } else if (state is UpdateLocationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: dangerColor,
              ),
            );
          }
        },
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(32.8872, 13.1913),
                zoom: 12,
              ),
              onMapCreated: (GoogleMapController c) {
                controller = c;
                _handleInitialLocation();
              },
              onTap: _onMapTap,
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              compassEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
            ),
            IgnorePointer(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Icon(
                    Icons.location_searching_rounded,
                    color: primaryAccent.withValues(alpha: 0.8),
                    size: 40,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () async {
                            try {
                              if (controller == null) return;

                              LatLngBounds bounds = await controller!
                                  .getVisibleRegion();
                              LatLng centerPoint = LatLng(
                                (bounds.northeast.latitude +
                                        bounds.southwest.latitude) /
                                    2,
                                (bounds.northeast.longitude +
                                        bounds.southwest.longitude) /
                                    2,
                              );

                              if (!_isPointInPolygon(
                                centerPoint,
                                allowedArea,
                              )) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "هذا الموقع خارج النطاق المسموح به",
                                      ),
                                      backgroundColor: dangerColor,
                                    ),
                                  );
                                }
                                return;
                              }
                              if (_allowMultiple) {
                                String generatedDesc =
                                    await _getAddressFromLatLng(centerPoint);
                                Map<String, String>? details =
                                    await _showNameAndDescDialog(
                                      initialDesc: generatedDesc,
                                    );
                                if (details != null) {
                                  setState(() {
                                    _selectedPoints.add(
                                      SelectedLocation(
                                        name: details['name'],
                                        address: details['description'],
                                        latitude: centerPoint.latitude,
                                        longitude: centerPoint.longitude,
                                      ),
                                    );
                                  });
                                  _updateMarkers();
                                }
                              } else {
                                setState(() {
                                  _selectedPoint = centerPoint;
                                });
                                _updateMarkers();
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("تعذر تحديد المركز الحالي"),
                                    backgroundColor: dangerColor,
                                  ),
                                );
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: secondaryBgColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: glassBorder),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add_location_alt_rounded,
                              color: successColor,
                              size: 28,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () async {
                            debugPrint("LOCATION_DEBUG: LocateMe button pressed");
                            final hasPermission = await _handleLocationPermission();
                            debugPrint("LOCATION_DEBUG: hasPermission: $hasPermission");
                            if (!hasPermission) return;

                            try {
                              debugPrint(
                                "LOCATION_DEBUG: Fetching current position (with 10s timeout)...",
                              );
                              Position? position;
                              try {
                                position = await Geolocator.getCurrentPosition(
                                  locationSettings: AndroidSettings(
                                    accuracy: LocationAccuracy.high,
                                    timeLimit: const Duration(seconds: 10),
                                    forceLocationManager: true,
                                  ),
                                );
                              } catch (e) {
                                debugPrint(
                                  "LOCATION_DEBUG: getCurrentPosition error or timeout: $e",
                                );
                              }

                              if (position == null) {
                                debugPrint(
                                  "LOCATION_DEBUG: Trying getLastKnownPosition as fallback...",
                                );
                                position = await Geolocator.getLastKnownPosition();
                              }

                              if (position != null) {
                                debugPrint(
                                  "LOCATION_DEBUG: Position determined: ${position.latitude}, ${position.longitude}",
                                );
                                LatLng userPoint = LatLng(
                                  position.latitude,
                                  position.longitude,
                                );

                                bool isInPolygon = _isPointInPolygon(
                                  userPoint,
                                  allowedArea,
                                );
                                debugPrint(
                                  "LOCATION_DEBUG: isWithinAllowedArea: $isInPolygon",
                                );

                                if (!isInPolygon) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "موقعك الحالي خارج النطاق المسموح به",
                                        ),
                                        backgroundColor: dangerColor,
                                      ),
                                    );
                                  }
                                  controller?.animateCamera(
                                    CameraUpdate.newLatLngZoom(userPoint, 15),
                                  );
                                  return;
                                }

                                if (_allowMultiple) {
                                  String generatedDesc =
                                      await _getAddressFromLatLng(userPoint);
                                  Map<String, String>? details =
                                      await _showNameAndDescDialog(
                                        initialDesc: generatedDesc,
                                      );
                                  if (details != null) {
                                    setState(() {
                                      _selectedPoints.add(
                                        SelectedLocation(
                                          name: details['name'],
                                          address: details['description'],
                                          latitude: userPoint.latitude,
                                          longitude: userPoint.longitude,
                                        ),
                                      );
                                    });
                                    _updateMarkers();
                                  }
                                } else {
                                  setState(() {
                                    _selectedPoint = userPoint;
                                  });
                                  _updateMarkers();
                                }
                                controller?.animateCamera(
                                  CameraUpdate.newLatLngZoom(userPoint, 15),
                                );
                              } else {
                                debugPrint(
                                  "LOCATION_DEBUG: Could not determine location at all.",
                                );
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "تعذر تحديد موقعك الحالي. تأكد من تفعيل GPS و الصلاحيات",
                                      ),
                                      backgroundColor: dangerColor,
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              debugPrint(
                                "LOCATION_DEBUG: Unexpected error in LocateMe onTap: $e",
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: secondaryBgColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: glassBorder),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.my_location_rounded,
                              color: primaryAccent,
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: secondaryBgColor.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: glassBorder),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: primaryAccent),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "حرك الخريطة لتضع النيشان على موقعك، أو اضغط مطولاً للتحديد",
                            style: TextStyle(color: textPrimary, fontSize: 13),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: state is UpdateLocationLoading
                              ? null
                              : () async {
                                  if (_allowMultiple) {
                                    if (_selectedPoints.isEmpty) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "يرجى تحديد موقع واحد على الأقل",
                                            ),
                                            backgroundColor: dangerColor,
                                          ),
                                        );
                                      }
                                      return;
                                    }
                                    Navigator.pop(context, _selectedPoints);
                                    return;
                                  }

                                  LatLng? point = _selectedPoint;
                                  if (point == null && controller != null) {
                                    try {
                                      LatLngBounds bounds = await controller!
                                          .getVisibleRegion();
                                      point = LatLng(
                                        (bounds.northeast.latitude +
                                                bounds.southwest.latitude) /
                                            2,
                                        (bounds.northeast.longitude +
                                                bounds.southwest.longitude) /
                                            2,
                                      );
                                    } catch (e) {
                                      debugPrint(
                                        "Error getting map center: $e",
                                      );
                                    }
                                  }

                                  if (point == null) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "يرجى تحديد موقع على الخريطة أولاً",
                                          ),
                                          backgroundColor: dangerColor,
                                        ),
                                      );
                                    }
                                    return;
                                  }

                                  if (!_isPointInPolygon(point, allowedArea)) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "الموقع المحدد خارج النطاق المسموح به",
                                          ),
                                          backgroundColor: dangerColor,
                                        ),
                                      );
                                    }
                                    return;
                                  }

                                  if (_isRegisterFlow) {
                                    if (context.mounted) {
                                      Navigator.pop(context, point);
                                    }
                                  } else {
                                    String generatedDesc =
                                        await _getAddressFromLatLng(point);
                                    Map<String, String>? details =
                                        await _showNameAndDescDialog(
                                          initialDesc: generatedDesc,
                                        );
                                    if (details != null && context.mounted) {
                                      Navigator.pop(
                                        context,
                                        SelectedLocation(
                                          name: details['name'],
                                          address: details['description'],
                                          latitude: point.latitude,
                                          longitude: point.longitude,
                                        ),
                                      );
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 8,
                          ),
                          child: state is UpdateLocationLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  _isRegisterFlow
                                      ? "حفظ هذا الموقع"
                                      : "تأكيد هذا الموقع",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
