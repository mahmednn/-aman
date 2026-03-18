import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_11/business_logic_layer/cubit/categories_cubit.dart';
import 'package:flutter_application_11/business_logic_layer/cubit/suppliers_cubit.dart';
import 'package:flutter_application_11/business_logic_layer/cubit/cart/cart_cubit.dart';
import 'package:flutter_application_11/data_layer/model/category.dart';
import 'package:flutter_application_11/data_layer/model/supplier.dart';
import 'package:flutter_application_11/presentation_layer/screens/category_details_screen.dart';
import 'package:flutter_application_11/presentation_layer/screens/supplier_profile_screen.dart';
import 'package:flutter_application_11/presentation_layer/screens/cart_screen.dart';
import 'package:flutter_application_11/presentation_layer/widgets/custom_network_image.dart';
import 'package:flutter_application_11/presentation_layer/widgets/page_transitions.dart';
import 'package:flutter_application_11/presentation_layer/widgets/cart_summary_bar.dart';

import 'package:flutter_application_11/presentation_layer/screens/supplier_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_11/constants/strings.dart';
import 'package:flutter_application_11/business_logic_layer/cubit/auth/auth_cubit.dart';
import 'package:flutter_application_11/presentation_layer/screens/auth/profile_screen.dart';
import 'package:flutter_application_11/business_logic_layer/cubit/location/location_cubit.dart';
import 'package:flutter_application_11/business_logic_layer/cubit/location/location_state.dart';
import 'package:flutter_application_11/data_layer/model/selected_location.dart';
import 'package:flutter_application_11/presentation_layer/widgets/loading_and_empty_states.dart';
import 'package:flutter_application_11/business_logic_layer/cubit/cart/cart_state.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _navIndex = 0;
  bool _isAddressPromptOpen = false;

  // صور تجريبية للسلايدر (يمكن استبدالها بصور من الـ API أو Assets)
  final List<String> _sliderImages = [
    'assets/images/back1.png',
    'assets/images/back2.png',
  ];

  @override
  void initState() {
    super.initState();
    print("HomeScreen: initState called. Fetching data...");
    // طلب البيانات عند فتح الشاشة
    context.read<SuppliersCubit>().getAllSuppliers();
    context.read<CategoriesCubit>().getAllCategories();
    context.read<LocationCubit>().getLocations();
    // Load carts to ensure counts are current
    context.read<CartCubit>().loadCarts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic> && args.containsKey('index')) {
      final index = args['index'] as int;
      if (_navIndex != index) {
        setState(() {
          _navIndex = index;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: mainBgColor,
      bottomNavigationBar: _buildModernNavBar(),
      body: Container(
        decoration: const BoxDecoration(gradient: mainBackgroundGradient),
        child: MultiBlocListener(
          listeners: [
            BlocListener<LocationCubit, LocationState>(
              listener: (context, state) {
                if (state.status == LocationStatus.success &&
                    state.locations.isEmpty &&
                    state.action == LocationAction.fetch &&
                    !_isAddressPromptOpen) {
                  _showAddressSelectionPopup();
                }
              },
            ),
          ],
          child: Stack(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                switchInCurve: Curves.easeOutQuart,
                switchOutCurve: Curves.easeInQuart,
                child: _buildBody(),
              ),
              if (_navIndex != 2) // Don't show floating bar on the cart screen itself
                const Positioned(
                  bottom: 110, // Above the bottom nav bar
                  left: 0,
                  right: 0,
                  child: CartSummaryBar(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    // التنقل بين الصفحات (يمكن فصل الصفحات في ملفات مستقلة لاحقاً)
    switch (_navIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return BlocProvider.value(
          value: context.read<SuppliersCubit>(),
          child: const SupplierScreen(),
        );
      case 2:
        return BlocProvider.value(
          value: context.read<CartCubit>(),
          child: const CartScreen(),
        );
      case 3:
        return const Center(child: Text("طلباتي"));
      case 4:
        return BlocProvider.value(
          value: context.read<AuthCubit>(),
          child: const ProfileScreen(),
        );
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return SafeArea(
      // 1. نبدأ ببناء حالة الموردين (الأساسية للشاشة)
      child: BlocBuilder<SuppliersCubit, SuppliersState>(
        builder: (context, supplierState) {
          print("HomeScreen: Suppliers state is: $supplierState");
          if (supplierState is SuppliersLoading ||
              supplierState is SuppliersInitial) {
            return const HomeShimmerSkeleton();
          } else if (supplierState is SuppliersLoaded) {
            final suppliers = supplierState.suppliers;
            return RefreshIndicator(
              onRefresh: () async {
                context.read<SuppliersCubit>().getAllSuppliers();
                context.read<CategoriesCubit>().getAllCategories();
                context.read<LocationCubit>().getLocations();
                context.read<CartCubit>().loadCarts();
              },
              color: primaryAccent,
              backgroundColor: cardColor,
              child: SingleChildScrollView(
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopHeader(),
                  const SizedBox(height: 12),
                  _buildModernSlider(),
                  const SizedBox(height: 10),
                  _buildIndicator(),
                  const SizedBox(height: 24),

                  // 2. هنا نضع عنوان الفئات ثم الـ BlocBuilder الخاص بها
                  _sectionTitle('الفئات المميزة'),
                  const SizedBox(height: 12),
                  BlocBuilder<CategoriesCubit, CategoriesState>(
                    builder: (context, categoryState) {
                      if (categoryState is CategoriesLoading) {
                        return SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            itemCount: 4,
                            itemBuilder: (context, index) => Shimmer.fromColors(
                              baseColor: cardColor,
                              highlightColor: Colors.grey[700]!,
                              child: Container(
                                width: 140,
                                margin: const EdgeInsets.only(left: 10),
                                child: Column(
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Center(
                                        child: Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: 80,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      } else if (categoryState is CategoriesLoaded) {
                        return _buildCategoriesGrid(
                          categoryState.categories,
                          suppliers,
                        );
                      } else if (categoryState is CategoriesError) {
                        return EmptyStateWidget(
                          message: 'خطأ: ${categoryState.error}',
                          icon: Icons.error_outline,
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  const SizedBox(height: 24),

                  // 3. عرض الموردين (الذين تم تحميلهم في الـ Builder الخارجي)
                  _sectionTitle('أهم الموردين'),
                  const SizedBox(height: 12),
                  _buildSupplierList(suppliers),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
          } else if (supplierState is SuppliersError) {
            return EmptyStateWidget(
              message: 'خطأ: ${supplierState.error}',
              icon: Icons.error_outline,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // زر الموقع
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, savedLocationsScreen);
            },
            borderRadius: BorderRadius.circular(15),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 3),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: glassBackground,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: dangerColor,
                    size: 20,
                  ),
                ),
                SizedBox(width: 5),
                BlocBuilder<LocationCubit, LocationState>(
                  builder: (context, state) {
                    String displayTitle = "جاري التحديد...";

                    if (state.locations.isNotEmpty) {
                      final defaultLoc = state.locations.firstWhere(
                        (loc) => loc.isDefault == 1,
                        orElse: () => state.locations.first,
                      );
                      displayTitle =
                          defaultLoc.name ??
                          "${defaultLoc.latitude?.toStringAsFixed(4)}, ${defaultLoc.longitude?.toStringAsFixed(4)}";
                    } else if (state.status == LocationStatus.success) {
                      displayTitle = "اختر موقع التوصيل";
                    }

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        Text(
                          "التوصيل إلى",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 150),
                          child: Text(
                            displayTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(width: 10),
                
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Text(
                  "0 د.ل",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.blueAccent,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernSlider() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 180,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.79,
        autoPlayInterval: const Duration(seconds: 4),
        onPageChanged: (index, reason) {
          setState(() => _currentIndex = index);
        },
      ),
      items: _sliderImages.map((imagePath) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.grey.withValues(
              alpha: 0.05,
            ), // لون خلفية مؤقت في حال عدم وجود الصورة
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            // استخدام صورة افتراضية أو من الشبكة إذا توفرت
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _sliderImages.asMap().entries.map((entry) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _currentIndex == entry.key ? 18 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: _currentIndex == entry.key
                ? secondaryAccent
                : primaryAccent.withValues(alpha: 0.5),
          ),
        );
      }).toList(),
    );
  }

  Widget _sectionTitle(String title) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid(
    List<CategoryModel> categories,
    List<SupplierModel> suppliers,
  ) {
    if (categories.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد فئات متاحة',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SizedBox(
        height: 340, // Increased height significantly for safety
        child: GridView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2 / 2.5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return InkWell(
              onTap: () {
                // Navigate to category details screen

                Navigator.push(
                  context,
                  PageTransitions.slideFromLeft(
                    CategoryDetailsScreen(
                      categoryId: category.id,
                      categoryName: category.name,
                    ),
                  ),
                );

                /* Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(
                      milliseconds: 300,
                    ), // سرعة الانتقال
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        MultiBlocProvider(
                          providers: [
                            BlocProvider.value(
                              value: BlocProvider.of<CategoriesCubit>(context),
                            ),
                            BlocProvider.value(
                              value: BlocProvider.of<SuppliersCubit>(context),
                            ),
                          ],
                          child: CategoryDetailsScreen(
                            category: category,
                            suppliers: categorySuppliers,
                          ),
                        ),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                          // انميشن التلاشي (Fade) يجعله يبدو احترافياً وسريعاً جداً
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                  ),
                );*/
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
          },
        ),

        /*ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: suppliers.length,
          itemBuilder: (context, index) {
            final supplier = suppliers[index];
            return Container(
              width: 140,
              margin: const EdgeInsets.only(left: 15),
              decoration: BoxDecoration(
                color: const Color(0xFF0B162C).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 80,
                    width: 80,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: CachedNetworkImage(
                        imageUrl: supplier.supplierCategory?.imageUrl ?? '',
                        placeholder: (context, url) =>
                            const Icon(Icons.image, color: Colors.grey),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.business,
                          color: Colors.white54,
                          size: 40,
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      supplier.supplierCategory?.name ?? 'Unknown',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),*/
      ),
    );
  }

  Widget _buildSupplierList(List<SupplierModel> suppliers) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        // إضافة shrinkWrap لضمان عملها داخل Column دون مشاكل في الارتفاع
        shrinkWrap: true,
        // منع التمرير الخاص بالـ ListView إذا كانت الصفحة ككل قابلة للتمرير
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: suppliers.length,
        itemBuilder: (context, index) {
          final supplier = suppliers[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SupplierProfileScreen(
                    supplier: supplier,
                    heroTag: 'home_supplier_hero_${supplier.id}',
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
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(defaultBorderRadius),
                    ),
                    child: Hero(
                      tag: 'home_supplier_hero_${supplier.id}',
                      child: CustomNetworkImage(
                        imageUrl: supplier.logoUrl ?? '',
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        memCacheWidth: 600,
                        errorWidget: Container(
                          height: 150,
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                supplier.user?.name ?? 'مورد غير معروف',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (supplier.supplierCategory?.name != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.category_outlined,
                                      size: 14,
                                      color: textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      supplier.supplierCategory!.name,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              supplier.rating?.toString() ?? '0.0',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
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
        },
      ),
    );
  }

  Widget _buildModernNavBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      height:
          85, // INCREASED height to prevent vertical overflow with large font sizes
      decoration: BoxDecoration(
        color: secondaryBgColor.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: glassBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.home_rounded, 'الرئيسية'),
                  _buildNavItem(1, Icons.business_rounded, 'الموردون'),
                  _buildNavItem(2, Icons.shopping_cart_rounded, 'السلة'),
                  _buildNavItem(3, Icons.receipt_long_rounded, 'الطلبات'),
                  _buildNavItem(4, Icons.person_rounded, 'حسابي'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _navIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _navIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutQuart,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 10,
          vertical:
              6, // Reduced vertical padding so inner children have more height
        ),
        decoration: isSelected
            ? BoxDecoration(
                color: primaryAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primaryAccent.withValues(alpha: 0.3)),
              )
            : const BoxDecoration(color: Colors.transparent),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isSelected ? primaryAccent : textSecondary,
                  size: 26,
                ),
                if (index == 2) // Cart Badge
                  BlocBuilder<CartCubit, CartState>(
                    builder: (context, state) {
                      final cartCubit = context.read<CartCubit>();
                      final pending = cartCubit.pendingCartsCount;
                      final confirmed = cartCubit.confirmedCartsCount;
                      
                      if (pending == 0 && confirmed == 0) return const SizedBox();
                      
                      return Positioned(
                        top: -10,
                        right: -15,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: pending > 0 ? primaryAccent : successColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: secondaryBgColor, width: 2),
                          ),
                          child: Text(
                            '$pending | $confirmed',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: primaryAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddressSelectionPopup() async {
    setState(() => _isAddressPromptOpen = true);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: secondaryBgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              const Text(
                "تحديد موقع المتجر",
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "يرجى تحديد موقع متجرك على الخريطة لتتمكن من استخدام التطبيق",
                style: TextStyle(color: textSecondary, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Stack(
                    children: [
                      // Using a simple navigation for now as embedding
                      // the full map logic here would duplicate too much code.
                      // Instead, we show a placeholder/preview and a button.
                      Container(
                        color: Colors.white10,
                        child: const Center(
                          child: Icon(
                            Icons.map_rounded,
                            color: textSecondary,
                            size: 60,
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              final result = await Navigator.pushNamed(
                                context,
                                mapSelectionScreen,
                                arguments: {
                                  'isRegisterFlow': false,
                                  'allowMultiple': false,
                                },
                              );
                              if (result != null &&
                                  result is SelectedLocation) {
                                if (Navigator.canPop(context))
                                  Navigator.pop(context, result);
                              }
                            },
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.touch_app_rounded,
                                    color: primaryAccent,
                                    size: 40,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "اضغط لفتح الخريطة وتحديد الموقع",
                                    style: TextStyle(
                                      color: primaryAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      // If they close without selecting, we keep the flag true
                      // for a while to avoid immediate re-prompting
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "إغلاق",
                      style: TextStyle(color: textSecondary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).then((result) {
      if (result != null && result is SelectedLocation) {
        context.read<LocationCubit>().addLocation(result);
      }

      // Reset flag after a delay to ensure state has time to sync
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _isAddressPromptOpen = false);
      });
    });
  }
}
