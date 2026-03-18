import 'package:flutter/material.dart';

/// زر رجوع مخصص مع خلفية دائرية رمادية شفافة
/// يُستخدم في جميع شاشات التطبيق لضمان ظهوره بوضوح على مختلف ألوان الخلفيات
class CustomBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color iconColor;

  const CustomBackButton({
    super.key,
    this.onPressed,
    this.backgroundColor = Colors.black45,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: IconButton(
        icon: Icon(Icons.arrow_back, color: iconColor),
        // إذا لم يتم تمرير دالة، يتم إغلاق الشاشة الحالية افتراضياً
        onPressed: onPressed ?? () => Navigator.maybePop(context),
      ),
    );
  }
}
