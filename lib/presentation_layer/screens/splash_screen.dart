import 'package:flutter/material.dart';
import 'package:flutter_application_11/business_logic_layer/cubit/auth/auth_cubit.dart';
import 'package:flutter_application_11/business_logic_layer/cubit/auth/auth_state.dart';
import 'package:flutter_application_11/constants/strings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // نتحقق من حالة الجلسة (Token) فور بدء التطبيق
    context.read<AuthCubit>().checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          // إذا وجدنا جلسة صالحة، انتقل مباشرة للواجهة الرئيسية وامسح تاريخ الشاشات
          Navigator.pushNamedAndRemoveUntil(
            context,
            supplierScreen,
            (route) => false,
          );
        } else if (state is AuthInitial || state is AuthError) {
          // إذا لم تكن هناك جلسة أو كان التوكن منتهي الصلاحية، انتقل لشاشة تسجيل الدخول
          Navigator.pushNamedAndRemoveUntil(
            context,
            loginScreen,
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: mainBgColor,
        body: Container(
          decoration: const BoxDecoration(gradient: mainBackgroundGradient),
          child: const Center(
            child: CircularProgressIndicator(color: primaryAccent),
          ),
        ),
      ),
    );
  }
}
