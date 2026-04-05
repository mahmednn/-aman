import 'package:flutter/material.dart';
import 'package:flutter_application_11/data_layer/model/supplier.dart';
import 'package:flutter_application_11/constants/strings.dart';
import 'package:flutter_application_11/presentation_layer/screens/supplier_profile_screen.dart';
import 'package:flutter_application_11/presentation_layer/widgets/custom_network_image.dart';
import 'package:flutter_application_11/presentation_layer/widgets/page_transitions.dart';

class SupplierCard extends StatelessWidget {
  final SupplierModel supplier;
  final String heroTag;

  const SupplierCard({
    super.key,
    required this.supplier,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageTransitions.slideRoute(
            SupplierProfileScreen(
              supplier: supplier,
              heroTag: heroTag,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: glassBackground,
          borderRadius: BorderRadius.circular(defaultBorderRadius),
          border: Border.all(color: glassBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(defaultBorderRadius),
              ),
              child: Hero(
                tag: heroTag,
                child: CustomNetworkImage(
                  imageUrl: supplier.logoUrl ?? '',
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: Container(
                    height: 160,
                    color: Colors.white10,
                    child: const Icon(
                      Icons.store,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          supplier.user?.name ?? 'مورد غير معروف',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            supplier.rating?.toString() ?? '0.0',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (supplier.supplierCategory?.name != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          supplier.supplierCategory!.name,
                          style: const TextStyle(
                            fontSize: 13,
                            color: textSecondary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.category_outlined,
                          size: 14,
                          color: textSecondary,
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: primaryAccent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        supplier.address ?? 'ليبيا',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
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
