class AppConstants {
  static const String appName = "Inventory Admin";

  // API Base URL (Use 127.0.0.1 for Chrome/Web)
  static const String apiBaseUrl = "http://127.0.0.1:5000/api"; 

  // UI Constants <-- RESTORED SECTION
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0; // <-- THIS IS WHAT WAS MISSING

  // Animations
  static const Duration shortAnim = Duration(milliseconds: 250);
  static const Duration longAnim = Duration(milliseconds: 500);
}