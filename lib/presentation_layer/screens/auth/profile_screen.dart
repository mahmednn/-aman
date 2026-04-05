import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../business_logic_layer/cubit/auth/auth_cubit.dart';
import '../../../business_logic_layer/cubit/auth/auth_state.dart';
import '../../../constants/strings.dart';
import 'package:shimmer/shimmer.dart';
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().getProfile();
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: secondaryBgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
        ),
        title: const Text(
          "تسجيل الخروج",
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
          textAlign: TextAlign.right,
        ),
        content: const Text(
          "هل أنت متأكد من أنك تريد تسجيل الخروج؟",
          style: TextStyle(color: textSecondary),
          textAlign: TextAlign.right,
        ),
        actionsAlignment: MainAxisAlignment.start,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("إلغاء", style: TextStyle(color: primaryAccent)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: dangerColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthCubit>().logout();
            },
            child: const Text("نعم", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainBgColor,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is ProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: dangerColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is LogoutSuccess) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                loginScreen,
                (route) => false,
              );
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const _ProfileShimmerSkeleton();
            }

            final user = state is ProfileLoaded ? state.response.user : null;

            return Container(
              height: double.infinity,
              width: double.infinity,
              decoration: const BoxDecoration(gradient: mainBackgroundGradient),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeader(user),
                      const SizedBox(height: 24),
                      _buildQuickActions(),
                      const SizedBox(height: 32),
                      _buildSectionTitle("الحساب"),
                      const SizedBox(height: 12),
                      _buildSectionCard([
                        _buildActionTile(
                          Icons.location_on_outlined,
                          "عناويني",
                          () {
                            Navigator.pushNamed(context, savedLocationsScreen);
                          },
                        ),
                        _buildDivider(),
                        _buildActionTile(
                          Icons.person_outline_rounded,
                          "المعلومات الشخصية",
                          () {},
                        ),
                      ]),
                      const SizedBox(height: 32),
                      _buildSectionTitle("الإعدادات"),
                      const SizedBox(height: 12),
                      _buildSectionCard([
                        _buildActionTile(
                          Icons.language_rounded,
                          "الدولة",
                          () {},
                          trailingText: "ليبيا",
                        ),
                        _buildDivider(),
                        _buildActionTile(
                          Icons.translate_rounded,
                          "اللغة",
                          () {},
                          trailingText: "العربية",
                        ),
                        _buildDivider(),
                        _buildActionTile(
                          Icons.logout_rounded,
                          "تسجيل الخروج",
                          _logout,
                          iconColor: dangerColor,
                          textColor: dangerColor,
                        ),
                      ]),
                      const SizedBox(height: 120), // Height for nav bar
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(dynamic user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: glassBorder, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: secondaryBgColor,
                      child: const Icon(
                        Icons.person_rounded,
                        size: 45,
                        color: textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? "اسم المستخدم",
                        style: const TextStyle(
                          color: textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.phone ?? "+218-XXXXXXXXX",
                        style: TextStyle(
                          color: textSecondary.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ],
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () {},
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Icon(
                      Icons.qr_code_scanner_rounded,
                      color: primaryAccent,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildQuickCard("المفضلة", Icons.favorite_rounded, Colors.redAccent),
          _buildQuickCard("الطلبات", Icons.assignment_rounded, Colors.amber),
          _buildQuickCard(
            "المحفظة",
            Icons.account_balance_wallet_rounded,
            Colors.blueAccent,
            onTap: () => Navigator.pushNamed(context, walletScreen),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCard(String label, IconData icon, Color color, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: (MediaQuery.of(context).size.width - 60) / 3,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: glassBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: glassBorder),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          style: const TextStyle(
            color: textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: glassBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: glassBorder),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildActionTile(
    IconData icon,
    String title,
    VoidCallback onTap, {
    String? trailingText,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? primaryAccent).withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor ?? primaryAccent, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(
              trailingText,
              style: const TextStyle(color: textSecondary, fontSize: 14),
            ),
          const SizedBox(width: 8),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: textSecondary,
            size: 14,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: glassBorder, indent: 20, endIndent: 20);
  }
}

class _ProfileShimmerSkeleton extends StatelessWidget {
  const _ProfileShimmerSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: const BoxDecoration(gradient: mainBackgroundGradient),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeaderShimmer(),
              const SizedBox(height: 24),
              _buildQuickActionsShimmer(context),
              const SizedBox(height: 32),
              _buildSectionTitleShimmer(),
              const SizedBox(height: 12),
              _buildSectionCardShimmer(2),
              const SizedBox(height: 32),
              _buildSectionTitleShimmer(),
              const SizedBox(height: 12),
              _buildSectionCardShimmer(3),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderShimmer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Shimmer.fromColors(
                baseColor: cardColor,
                highlightColor: Colors.grey[800]!,
                child: const CircleAvatar(radius: 35, backgroundColor: Colors.white),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Shimmer.fromColors(
                    baseColor: cardColor,
                    highlightColor: Colors.grey[800]!,
                    child: Container(
                      width: 120,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Shimmer.fromColors(
                    baseColor: cardColor,
                    highlightColor: Colors.grey[800]!,
                    child: Container(
                      width: 100,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Shimmer.fromColors(
            baseColor: cardColor,
            highlightColor: Colors.grey[800]!,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsShimmer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(3, (index) => 
          Shimmer.fromColors(
            baseColor: cardColor,
            highlightColor: Colors.grey[800]!,
            child: Container(
              width: (MediaQuery.of(context).size.width - 60) / 3,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitleShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Align(
        alignment: Alignment.centerRight,
        child: Shimmer.fromColors(
          baseColor: cardColor,
          highlightColor: Colors.grey[800]!,
          child: Container(
            width: 80,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCardShimmer(int itemCount) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: glassBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: glassBorder),
      ),
      child: Column(
        children: List.generate(
          itemCount * 2 - 1,
          (index) {
            if (index.isOdd) {
              return Divider(height: 1, color: glassBorder, indent: 20, endIndent: 20);
            }
            return _buildShimmerTile();
          },
        ),
      ),
    );
  }

  Widget _buildShimmerTile() {
    return ListTile(
      leading: Shimmer.fromColors(
        baseColor: cardColor,
        highlightColor: Colors.grey[800]!,
        child: Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
        ),
      ),
      title: Shimmer.fromColors(
        baseColor: cardColor,
        highlightColor: Colors.grey[800]!,
        child: Container(
          width: 120,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
      trailing: Shimmer.fromColors(
        baseColor: cardColor,
        highlightColor: Colors.grey[800]!,
        child: const Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.white,
          size: 14,
        ),
      ),
    );
  }
}

