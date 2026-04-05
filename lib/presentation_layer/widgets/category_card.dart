import 'package:flutter/material.dart';
import 'package:flutter_application_11/data_layer/model/category.dart';
import 'package:flutter_application_11/constants/strings.dart';
import 'package:flutter_application_11/presentation_layer/screens/category_details_screen.dart';
import 'package:flutter_application_11/presentation_layer/widgets/custom_network_image.dart';
import 'package:flutter_application_11/presentation_layer/widgets/page_transitions.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category;

  const CategoryCard({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          PageTransitions.slideFromLeft(
            CategoryDetailsScreen(
              categoryId: category.id,
              categoryName: category.name,
            ),
          ),
        );
      },
      child: Column(
        children: [
          Expanded(
            flex: 4,
            child: SizedBox(
              width: double.infinity,
              child: CustomNetworkImage(
                imageUrl: category.imageUrl ?? '',
                fit: BoxFit.contain,
                errorWidget: const Icon(
                  Icons.business,
                  color: Colors.white54,
                  size: 40,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: Text(
              category.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
