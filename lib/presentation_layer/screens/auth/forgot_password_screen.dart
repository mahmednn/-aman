import 'package:flutter/material.dart';
import 'package:flutter_application_11/presentation_layer/widgets/auth/custom_auth_button.dart';
import 'package:flutter_application_11/presentation_layer/widgets/auth/custom_text_field.dart';
import 'package:flutter_application_11/presentation_layer/widgets/custom_back_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../business_logic_layer/cubit/auth/auth_cubit.dart';
import '../../../../business_logic_layer/cubit/auth/auth_state.dart';
import '../../../../constants/strings.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _requestReset() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().requestPasswordReset(
        _phoneController.text.trim(),
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
        leading: const CustomBackButton(),
      ),
      extendBodyBehindAppBar: true,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthOtpSent && state.isPasswordReset) {
              Navigator.pushNamed(
                context,
                otpScreen,
                arguments: {'phone': state.phone, 'isPasswordReset': true},
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
                            color: primaryAccent.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock_reset_rounded,
                            size: 60,
                            color: primaryAccent,
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          "نسيت كلمة المرور؟",
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "أدخل رقم هاتفك وسنرسل لك رمزاً لإعادة تعيين كلمة المرور",
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 48),

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
                        const SizedBox(height: 32),

                        CustomAuthButton(
                          text: "إرسال الرمز",
                          isLoading: state is AuthLoading,
                          onPressed: _requestReset,
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
