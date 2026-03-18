class ApiRoutes {
  // Public
  static const publicSuppliers = 'public/suppliers';
  static const publicProducts = 'public/products';
  static const publicSupplierCategories = 'public/supplier-categories';
  static const publicProductCategories = 'public/product-categories';

  // Customer Auth
  static const customerRegister = 'auth/customer/register';
  static const verifyOtp = 'auth/verify-otp';
  static const customerLogin = 'auth/customer/login';
  static const resendOtp = 'auth/resend-otp';

  // Password Reset
  static const passwordResetRequest = 'auth/password-reset/request';
  static const passwordResetVerify = 'auth/password-reset/verify';
  static const passwordResetReset = 'auth/password-reset/reset';

  // Authenticated
  static const customerProfile = 'customer/profile';
  static const me = 'me';
  static const logout = 'logout';

  // Customer Locations
  static const customerLocations = 'customer/locations';

  static String customerLocationById(int id) => 'customer/locations/$id';
  static String setDefaultCustomerLocation(int id) =>
      'customer/locations/$id/set-default';

  static String publicSupplierById(int id) => 'public/suppliers/$id';
}
