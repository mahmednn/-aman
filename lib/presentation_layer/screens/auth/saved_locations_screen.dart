import 'package:flutter/material.dart';

import 'package:flutter_application_11/business_logic_layer/cubit/location/location_cubit.dart';
import 'package:flutter_application_11/business_logic_layer/cubit/location/location_state.dart';
import 'package:flutter_application_11/constants/strings.dart';
import 'package:flutter_application_11/data_layer/model/customer_location_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_11/data_layer/model/selected_location.dart';

class SavedLocationsScreen extends StatefulWidget {
  const SavedLocationsScreen({super.key});

  @override
  State<SavedLocationsScreen> createState() => _SavedLocationsScreenState();
}

class _SavedLocationsScreenState extends State<SavedLocationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LocationCubit>().getLocations();
  }

  Future<void> _addNewAddress() async {
    final result = await Navigator.pushNamed(
      context,
      mapSelectionScreen,
      arguments: {'isRegisterFlow': false, 'allowMultiple': false},
    );

    if (result != null && result is SelectedLocation && mounted) {
      context.read<LocationCubit>().addLocation(result);
    }
  }

  void _deleteAddress(int? id) {
    if (id != null) {
      context.read<LocationCubit>().deleteLocation(id);
    }
  }

  void _setDefaultAddress(int? id) {
    if (id != null) {
      context.read<LocationCubit>().setDefaultLocation(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainBgColor,
      appBar: AppBar(
        title: const Text(
          "عناويني المسجلة",
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.black45,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewAddress,
        backgroundColor: primaryAccent,
        icon: const Icon(Icons.add, color: Colors.white, size: 24),
        label: const Text(
          "عنوان جديد",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: mainBackgroundGradient),
        child: SafeArea(
          child: BlocConsumer<LocationCubit, LocationState>(
            listener: (context, state) {
              if (state.status == LocationStatus.success) {
                if (state.action == LocationAction.add) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("تم إضافة الموقع بنجاح"),
                      backgroundColor: successColor,
                    ),
                  );
                } else if (state.action == LocationAction.delete) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("تم حذف الموقع بنجاح"),
                      backgroundColor: successColor,
                    ),
                  );
                } else if (state.action == LocationAction.setDefault) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("تم تعيين الموقع الافتراضي بنجاح"),
                      backgroundColor: successColor,
                    ),
                  );
                }
              } else if (state.status == LocationStatus.failure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage ?? "حدث خطأ"),
                    backgroundColor: dangerColor,
                  ),
                );
              }
            },
            builder: (context, state) {
              List<CustomerLocationModel> locations = state.locations;

              if (state.status == LocationStatus.loading &&
                  state.action == LocationAction.fetch) {
                return const Center(
                  child: CircularProgressIndicator(color: primaryAccent),
                );
              }

              return Stack(
                children: [
                  if (locations.isEmpty)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_off_rounded,
                            size: 80,
                            color: textSecondary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "لا يوجد عناوين مسجلة بعد",
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      padding: const EdgeInsets.all(16.0).copyWith(bottom: 80),
                      itemCount: locations.length,
                      itemBuilder: (context, index) {
                        final CustomerLocationModel addr = locations[index];
                        final name = addr.name ?? "موقع غير مسمى";
                        final desc = addr.address ?? "";
                        final lat = addr.latitude ?? 0.0;
                        final lng = addr.longitude ?? 0.0;
                        final isDefault = addr.isDefault == 1;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: secondaryBgColor.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: isDefault ? primaryAccent : glassBorder,
                              width: isDefault ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(15),
                              onTap: () {
                                if (!isDefault) {
                                  _setDefaultAddress(addr.id);
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: dangerColor,
                                        size: 22,
                                      ),
                                      onPressed: () => _deleteAddress(addr.id),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        color: textSecondary,
                                        size: 22,
                                      ),
                                      onPressed: () {},
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              if (isDefault) ...[
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: primaryAccent
                                                        .withValues(alpha: 0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  child: const Text(
                                                    "الافتراضي",
                                                    style: TextStyle(
                                                      color: primaryAccent,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                              ],
                                              Flexible(
                                                child: Text(
                                                  name,
                                                  style: const TextStyle(
                                                    color: textPrimary,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (desc.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              desc,
                                              style: const TextStyle(
                                                color: textSecondary,
                                                fontSize: 14,
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ],
                                          const SizedBox(height: 4),
                                          Text(
                                            "${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}",
                                            style: TextStyle(
                                              color: textSecondary.withValues(
                                                alpha: 0.7,
                                              ),
                                              fontSize: 12,
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    GestureDetector(
                                      onTap: () {
                                        if (!isDefault) {
                                          _setDefaultAddress(addr.id);
                                        }
                                      },
                                      child: Icon(
                                        isDefault
                                            ? Icons.check_circle
                                            : Icons.circle_outlined,
                                        color: isDefault
                                            ? primaryAccent
                                            : textSecondary.withValues(
                                                alpha: 0.3,
                                              ),
                                        size: 26,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  if (state.status == LocationStatus.loading &&
                      state.action != LocationAction.fetch)
                    const Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(color: primaryAccent),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
