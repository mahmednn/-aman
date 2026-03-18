import 'package:flutter/material.dart';
import 'package:flutter_application_11/business_logic_layer/cubit/auth/auth_cubit.dart';
import 'package:flutter_application_11/presentation_layer/widgets/auth/custom_auth_button.dart';
import 'package:flutter_application_11/presentation_layer/widgets/auth/custom_text_field.dart';
import 'package:flutter_application_11/presentation_layer/widgets/custom_back_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../business_logic_layer/cubit/auth/auth_state.dart';
import '../../../../constants/strings.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phone;
  final bool isPasswordReset;

  const OtpVerificationScreen({
    super.key,
    required this.phone,
    required this.isPasswordReset,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verifyOtp() {
    if (_formKey.currentState!.validate()) {
      if (widget.isPasswordReset) {
        context.read<AuthCubit>().verifyPasswordResetOtp(
          widget.phone,
          _otpController.text.trim(),
        );
      } else {
        context.read<AuthCubit>().verifyOtp(
          widget.phone,
          _otpController.text.trim(),
        );
      }
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
            if (state is AuthSuccess && !widget.isPasswordReset) {
              // Registration OTP is successful, logged in successfully
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم التحقق بنجاح! مرحباً بك'),
                  backgroundColor: successColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(supplierScreen, (route) => false);
            } else if (state is AuthResetCodeVerified &&
                widget.isPasswordReset) {
              // Password Reset OTP is successful, go to reset screen
              Navigator.pushReplacementNamed(
                context,
                resetPasswordScreen,
                arguments: {'phone': widget.phone, 'code': state.code},
              );
            } else if (state is AuthError) {
              print(state.error);
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
                            Icons.message_rounded,
                            size: 60,
                            color: primaryAccent,
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          "تأكيد الرمز",
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "أدخل الرمز المكون من 4 أرقام المرسل إلى ${widget.phone}",
                          style: const TextStyle(
                            color: textSecondary,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 48),

                        CustomTextField(
                          label: "رمز التحقق (OTP)",
                          prefixIcon: Icons.qr_code_rounded,
                          keyboardType: TextInputType.number,
                          controller: _otpController,
                          validator: (val) {
                            if (val == null || val.isEmpty)
                              return 'يرجى إدخال رمز التحقق';
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        CustomAuthButton(
                          text: "تأكيد",
                          isLoading: state is AuthLoading,
                          onPressed: _verifyOtp,
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
