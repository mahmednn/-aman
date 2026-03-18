import 'package:flutter/material.dart';
import 'package:flutter_application_11/business_logic_layer/cubit/auth/auth_cubit.dart';
import 'package:flutter_application_11/business_logic_layer/cubit/auth/auth_state.dart';
import 'package:flutter_application_11/presentation_layer/widgets/auth/custom_auth_button.dart';
import 'package:flutter_application_11/presentation_layer/widgets/auth/custom_text_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../constants/strings.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  // Removed latitude and longitude as they will be added after login

  void _register() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _passwordConfirmController.text,
        // latitude and longitude are no longer required during registration
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthOtpSent && !state.isPasswordReset) {
              Navigator.pushNamed(
                context,
                otpScreen,
                arguments: {'phone': state.phone, 'isPasswordReset': false},
              );
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: dangerColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            return Container(
              height: double.infinity,
              decoration: const BoxDecoration(gradient: mainBackgroundGradient),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "إنشاء حساب جديد",
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "أدخل بياناتك للاستمرار",
                          style: TextStyle(color: textSecondary, fontSize: 16),
                        ),
                        const SizedBox(height: 48),

                        CustomTextField(
                          label: "الاسم الكامل",
                          prefixIcon: Icons.person_rounded,
                          controller: _nameController,
                          validator: (val) {
                            if (val == null || val.isEmpty)
                              return 'يرجى إدخال الاسم';
                            return null;
                          },
                        ),
                        CustomTextField(
                          label: "البريد الإلكتروني",
                          prefixIcon: Icons.email_rounded,
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
                          validator: (val) {
                            if (val == null || val.isEmpty)
                              return 'يرجى إدخال البريد الإلكتروني';
                            return null;
                          },
                        ),
                        CustomTextField(
                          label: "رقم الهاتف",
                          prefixIcon: Icons.phone_android_rounded,
                          keyboardType: TextInputType.phone,
                          controller: _phoneController,
                          validator: (val) {
                            if (val == null || val.isEmpty)
                              return 'يرجى إدخال رقم الهاتف';
                            return null;
                          },
                        ),
                        CustomTextField(
                          label: "كلمة المرور",
                          prefixIcon: Icons.lock_outline_rounded,
                          isPassword: true,
                          controller: _passwordController,
                          validator: (val) {
                            if (val == null || val.isEmpty)
                              return 'يرجى إدخال كلمة المرور';
                            if (val.length < 6)
                              return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                            return null;
                          },
                        ),
                        CustomTextField(
                          label: "تأكيد كلمة المرور",
                          prefixIcon: Icons.lock_rounded,
                          isPassword: true,
                          controller: _passwordConfirmController,
                          validator: (val) {
                            if (val == null || val.isEmpty)
                              return 'يرجى تأكيد كلمة المرور';
                            if (val != _passwordController.text)
                              return 'كلمات المرور غير متطابقة';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Removed location selection container
                        const SizedBox(height: 32),

                        CustomAuthButton(
                          text: "إنشاء حساب",
                          isLoading: state is AuthLoading,
                          onPressed: _register,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "لديك حساب بالفعل؟",
                              style: TextStyle(color: textSecondary),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                "تسجيل الدخول",
                                style: TextStyle(
                                  color: primaryAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
