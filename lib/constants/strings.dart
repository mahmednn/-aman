import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final baseUrl1 = dotenv.env['API_BASE_URL'] ?? 'http://102.203.200.14/api/';

// --- Modern Deep Blue / Glassmorphism Palette ---

// Background Colors
const Color mainBgColor = Color(0xFF0F172A); // Slate 900
const Color secondaryBgColor = Color(0xFF1E293B); // Slate 800

// Surface Colors (Cards, Dialogs)
const Color cardColor = Color(0xFF1E293B);
final Color glassBackground = Colors.white.withValues(alpha: 0.05);
final Color glassBorder = Colors.white.withValues(alpha: 0.1);

// Accents
const Color primaryAccent = Color(0xFF3B82F6); // Blue 500
const Color secondaryAccent = Color(0xFF60A5FA); // Blue 400
const Color successColor = Color(0xFF10B981); // Emerald 500
const Color warningColor = Color(0xFFF59E0B); // Amber 500
const Color dangerColor = Color(0xFFEF4444); // Red 500

// Text Colors
const Color textPrimary = Colors.white;
const Color textSecondary = Color(0xFF94A3B8); // Slate 400

// Gradients
const LinearGradient mainBackgroundGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [mainBgColor, Color(0xFF0B1120)],
);

// Constants
const double defaultPadding = 16.0;
const double defaultBorderRadius = 20.0;
const double cardBorderRadius = 15.0;

// Cart Routes Constants
const String getCartsEndpoint = 'customer/carts';
const String getCartBySupplierEndpoint = 'customer/carts/'; // append {supplier_id}
const String addToCartEndpoint = 'customer/carts/items';
const String updateCartItemEndpoint = 'customer/carts/items/'; // append {cart_item_id}
const String removeCartItemEndpoint = 'customer/carts/items/'; // append {cart_item_id}
const String clearCartEndpoint = 'customer/carts/'; // append {cart_id}/clear
const String checkoutPreviewEndpoint = 'customer/checkout/preview';

// Routes
const String splashRoute = '/';
const String loginScreen = '/login';
const String registerScreen = '/register';
const String otpScreen = '/otp';
const String forgotPasswordScreen = '/forgot-password';
const String resetPasswordScreen = '/reset-password';
const String supplierScreen = '/home';
const String profileScreen = '/profile';
const String mapSelectionScreen = '/map_selection';
const String savedLocationsScreen = '/saved_locations';
const String walletScreen = '/wallet';
const String prouductSupplierScreen = '/product_supplier';
