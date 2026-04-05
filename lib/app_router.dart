import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_11/business_logic_layer/cubit/categories_cubit.dart';
import 'package:flutter_application_11/business_logic_layer/cubit/suppliers_cubit.dart';
import 'package:flutter_application_11/constants/strings.dart';
import 'package:flutter_application_11/data_layer/repository/category_repo.dart';
import 'package:flutter_application_11/data_layer/repository/supplier_repo.dart';
import 'package:flutter_application_11/data_layer/web_services/category_services.dart';
import 'package:flutter_application_11/data_layer/web_services/supplier_services.dart';
import 'package:flutter_application_11/presentation_layer/screens/home_screen.dart';
import 'package:flutter_application_11/presentation_layer/screens/splash_screen.dart';
import 'package:flutter_application_11/presentation_layer/screens/auth/login_screen.dart';
import 'package:flutter_application_11/presentation_layer/screens/auth/register_screen.dart';
import 'package:flutter_application_11/presentation_layer/screens/auth/otp_verification_screen.dart';
import 'package:flutter_application_11/presentation_layer/screens/auth/forgot_password_screen.dart';
import 'package:flutter_application_11/presentation_layer/screens/auth/reset_password_screen.dart';
import 'package:flutter_application_11/presentation_layer/screens/auth/profile_screen.dart';
import 'package:flutter_application_11/presentation_layer/screens/auth/map_selection_screen.dart';
import 'package:flutter_application_11/presentation_layer/screens/auth/saved_locations_screen.dart';
import 'package:flutter_application_11/presentation_layer/screens/wallet_screen.dart';
import 'package:flutter_application_11/data_layer/web_services/auth_services.dart';
import 'package:flutter_application_11/data_layer/repository/auth_repo.dart';
import 'package:flutter_application_11/business_logic_layer/cubit/auth/auth_cubit.dart';
import 'package:flutter_application_11/data_layer/web_services/location_services.dart';
import 'package:flutter_application_11/data_layer/repository/location_repo.dart';
import 'package:flutter_application_11/business_logic_layer/cubit/location/location_cubit.dart';
import 'package:flutter_application_11/data_layer/web_services/cart_services.dart';
import 'package:flutter_application_11/data_layer/repository/cart_repository.dart';
import 'package:flutter_application_11/business_logic_layer/cubit/cart/cart_cubit.dart';
import 'package:flutter_application_11/data_layer/web_services/product_services.dart';
import 'package:flutter_application_11/data_layer/repository/product_repository.dart';
import 'package:flutter_application_11/business_logic_layer/cubit/products/products_cubit.dart';


class AppRouter {
  late SupplierRepo supplierRepo;
  late SuppliersCubit supplierCubit;
  late CategoryRepo category;
  late CategoriesCubit categoriesCubit;
  late AuthRepository authRepository;
  late AuthCubit authCubit;
  late LocationRepository locationRepository;
  late LocationCubit locationCubit;
  late CartRepository cartRepository;
  late CartCubit cartCubit;
  late ProductRepository productRepository;
  late ProductsCubit productsCubit;

  AppRouter() {
    // 1. Create a single, shared Dio instance with base configuration
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl1,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // 2. Initialize AuthServices with the shared Dio
    // This will also add the AuthInterceptor to this shared instance
    final authServices = AuthServices(externalDio: dio);
    authRepository = AuthRepository(authServices);
    authCubit = AuthCubit(authRepository);

    // 3. Initialize other components using the same shared Dio
    supplierRepo = SupplierRepo(supplierServ: SupplierServices(dio: dio));
    supplierCubit = SuppliersCubit(supplierRepo: supplierRepo);

    locationRepository = LocationRepository(LocationServices(dio: dio));
    locationCubit = LocationCubit(locationRepository);

    category = CategoryRepo(categoryServices: CategoryServices(dio: dio));
    categoriesCubit = CategoriesCubit(categoryRepo: category);

    // Initialize Cart services with the shared Dio instance for consistency
    cartRepository = CartRepository(CartServices(dio: dio));
    cartCubit = CartCubit(cartRepository: cartRepository);

    productRepository = ProductRepository(ProductServices(dio));
    productsCubit = ProductsCubit(productRepository);
  }

  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashRoute:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SplashScreen(),
        );
      case loginScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LoginScreen(),
        );
      case registerScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const RegisterScreen(),
        );
      case otpScreen:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OtpVerificationScreen(
            phone: args['phone'],
            isPasswordReset: args['isPasswordReset'] ?? false,
          ),
        );
      case forgotPasswordScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ForgotPasswordScreen(),
        );
      case resetPasswordScreen:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ResetPasswordScreen(
            phone: args['phone'],
            code: args['code'],
          ),
        );
      case supplierScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const HomeScreen(),
        );
      case profileScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ProfileScreen(),
        );
      case mapSelectionScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const MapSelectionScreen(),
        );
      case savedLocationsScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SavedLocationsScreen(),
        );
      case walletScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const WalletScreen(),
        );
      default:
        return null;
    }
  }
}
