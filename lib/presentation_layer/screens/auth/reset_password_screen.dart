import 'package:flutter/material.dart';
import 'package:flutter_application_11/business_logic_layer/cubit/auth/auth_cubit.dart';
import 'package:flutter_application_11/presentation_layer/widgets/auth/custom_auth_button.dart';
import 'package:flutter_application_11/presentation_layer/widgets/auth/custom_text_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../business_logic_layer/cubit/auth/auth_state.dart';
import '../../../../constants/strings.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String phone;
  final String code;

  const ResetPasswordScreen({
    super.key,
    required this.phone,
    required this.code,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  void _resetPassword() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().resetPassword(
        widget.phone,
        widget.code,
        _passwordController.text,
        _passwordConfirmController.text,
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
            if (state is AuthSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'تم تغيير كلمة المرور بنجاح! يرجى تسجيل الدخول.',
                  ),
                  backgroundColor: successColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(loginScreen, (route) => false);
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 48.0,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: successColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 60,
                            color: successColor,
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          "كلمة مرور جديدة",
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "أدخل كلمة المرور الجديدة لحسابك",
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 48),

                        CustomTextField(
                          label: "كلمة المرور الجديدة",
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
                        const SizedBox(height: 32),

                        CustomAuthButton(
                          text: "تغيير كلمة المرور",
                          isLoading: state is AuthLoading,
                          onPressed: _resetPassword,
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
