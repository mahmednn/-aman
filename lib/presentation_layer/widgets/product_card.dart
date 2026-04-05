import 'package:flutter/material.dart';
import 'package:flutter_application_11/constants/strings.dart';
import 'package:flutter_application_11/data_layer/model/product.dart';
import 'package:flutter_application_11/presentation_layer/screens/product_details_screen.dart';
import 'package:flutter_application_11/presentation_layer/widgets/custom_network_image.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final ProductSupplierModel supplierInfo;
  final String heroTag;
  final VoidCallback onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.supplierInfo,
    required this.heroTag,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(
              product: product,
              supplierInfo: supplierInfo,
              heroTag: heroTag,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: glassBackground,
          borderRadius: BorderRadius.circular(cardBorderRadius),
          border: Border.all(color: glassBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 1, // Changed from 5 to 1 to give image 50% height
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(cardBorderRadius),
                ),
                child: Hero(
                  tag: heroTag,
                  child: CustomNetworkImage(
                    imageUrl: product.img,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1, // Changed from 4 to 1 to give text 50% height
              child: Padding(
                padding: const EdgeInsets.all(8.0), // Reduced from 10 to 8
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14, // Reduced slightly
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            supplierInfo.supplierName,
                            style: const TextStyle(
                              color: textSecondary,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Text(
                            "${supplierInfo.price} د.ل",
                            style: const TextStyle(
                              color: primaryAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: double.infinity,
                      height: 36, // Fixed smaller height for button
                      child: ElevatedButton.icon(
                        onPressed: onAddToCart,
                        icon: const Icon(
                          Icons.shopping_cart_outlined,
                          size: 16,
                        ),
                        label: const Text(
                          "إضافة للسلة",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryAccent.withValues(alpha: 0.1),
                          foregroundColor: primaryAccent,
                          elevation: 0,
                          padding: EdgeInsets.zero, // Removed vertical padding
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: primaryAccent.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
