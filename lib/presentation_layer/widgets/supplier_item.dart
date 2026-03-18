import 'package:flutter/material.dart';
import 'package:flutter_application_11/data_layer/model/supplier.dart';
import 'package:flutter_application_11/constants/strings.dart';
import 'package:flutter_application_11/presentation_layer/screens/supplier_profile_screen.dart';
import 'package:flutter_application_11/presentation_layer/widgets/custom_network_image.dart';

class SupplierItem extends StatelessWidget {
  final List<SupplierModel> suppliers;

  const SupplierItem({
    super.key,
    required this.suppliers,
    required SupplierModel supplier,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        // إضافة shrinkWrap لضمان عملها داخل Column دون مشاكل في الارتفاع
        shrinkWrap: true,
        // منع التمرير الخاص بالـ ListView إذا كانت الصفحة ككل قابلة للتمرير
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: suppliers.length,
        itemBuilder: (context, index) {
          final supplier = suppliers[index];
          return GestureDetector(
            key: ValueKey(supplier.id),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SupplierProfileScreen(supplier: supplier),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: glassBackground,
                borderRadius: BorderRadius.circular(cardBorderRadius),
                border: Border.all(color: glassBorder),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // قسم الصورة
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Hero(
                      tag: 'supplier_hero_${supplier.id}',
                      child: CustomNetworkImage(
                        imageUrl: supplier.logoUrl ?? '',
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          supplier.products?[index].name ?? 'اسم المنتج',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18, // خط أوضح للعرض العريض
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          ' ${supplier.rating ?? 0} ⭐',
                          style: TextStyle(
                            color: Colors.blue[200],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
