// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:provider/provider.dart';

// // // --- Providers ---
// // import './providers/auth_provider.dart';
// // import './providers/product_provider.dart';
// // import './providers/order_provider.dart';

// // // --- Auth & Dashboard Screens ---
// // import 'screens/login_screen.dart';
// // import 'screens/dashboard_screen.dart';

// // // --- Product Screens ---
// // import 'screens/products/product_list_screen.dart';

// // // --- Order Screens ---
// // import 'screens/orders/order_list_screen.dart';
// // import 'screens/orders/order_create_screen.dart';
// // import 'screens/orders/order_detail_screen.dart';

// // void main() {
// //   WidgetsFlutterBinding.ensureInitialized();

// //   // Lock app to portrait mode
// //   SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

// //   runApp(const InventoryApp());
// // }

// // class InventoryApp extends StatelessWidget {
// //   const InventoryApp({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return MultiProvider(
// //       providers: [
// //         // AUTH PROVIDER
// //         ChangeNotifierProvider(create: (_) => AuthProvider()),

// //         ChangeNotifierProxyProvider<AuthProvider, ProductProvider>(
// //           create: (_) => ProductProvider(),
// //           update: (_, auth, previous) => previous ?? ProductProvider(),
// //         ),
// //         ChangeNotifierProxyProvider<AuthProvider, OrderProvider>(
// //           create: (_) => OrderProvider(),
// //           update: (_, auth, previous) => previous ?? OrderProvider(),
// //         ),
// //       ],
// //       child: Consumer<AuthProvider>(
// //         builder: (context, auth, _) {
// //           return MaterialApp(
// //             title: 'Inventory & Order App',
// //             debugShowCheckedModeBanner: false,

// //             theme: ThemeData(
// //               primarySwatch: Colors.blue,
// //               primaryColor: const Color(0xFF1E3A5F),
// //               appBarTheme: const AppBarTheme(
// //                 backgroundColor: Color(0xFF1E3A5F),
// //                 foregroundColor: Colors.white,
// //               ),
// //             ),

// //             // Default screen (login or dashboard)
// //             home:
// //                 auth.isLoggedIn ? const DashboardScreen() : const LoginScreen(),

// //             routes: {
// //               // Auth
// //               '/login': (ctx) => const LoginScreen(),
// //               '/dashboard': (ctx) => const DashboardScreen(),

// //               // Products
// //               '/products': (ctx) => const ProductListScreen(),

// //               // Orders
// //               '/orders': (ctx) => const OrderListScreen(),
// //               '/create_order': (ctx) => CreateOrderScreen(),

// //               // Order Details (requires ID)
// //               '/order-details': (ctx) {
// //                 final id = ModalRoute.of(ctx)?.settings.arguments;
// //                 if (id is String) {
// //                   return OrderDetailScreen(orderId: id);
// //                 }
// //                 return const OrderListScreen();
// //               },
// //             },
// //           );
// //         },
// //       ),
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';

// // --- Providers ---
// import './providers/auth_provider.dart';
// import './providers/product_provider.dart';
// import './providers/order_provider.dart';

// // --- Auth & Dashboard Screens ---
// import './screens/login_screen.dart';
// import './screens/dashboard_screen.dart';

// // --- Product Screens ---
// import 'screens/products/product_list_screen.dart';

// // --- Order Screens ---
// import 'screens/orders/order_list_screen.dart';
// import 'screens/orders/order_create_screen.dart';
// import 'screens/orders/order_detail_screen.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Lock app to portrait mode
//   SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

//   runApp(const InventoryApp());
// }

// class InventoryApp extends StatelessWidget {
//   const InventoryApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => AuthProvider()),
//         ChangeNotifierProxyProvider<AuthProvider, ProductProvider>(
//           create: (_) => ProductProvider(),
//           update: (_, auth, previous) => previous ?? ProductProvider(),
//         ),
//         ChangeNotifierProxyProvider<AuthProvider, OrderProvider>(
//           create: (_) => OrderProvider(),
//           update: (_, auth, previous) => previous ?? OrderProvider(),
//         ),
//       ],
//       child: Consumer<AuthProvider>(
//         builder: (context, auth, _) {
//           return MaterialApp(
//             title: 'Inventory & Order App',
//             debugShowCheckedModeBanner: false,

//             // -----------------------
//             // THEME SETTINGS (Dark)
//             // -----------------------
//             theme: ThemeData(
//               scaffoldBackgroundColor: Colors.black, // background
//               primaryColor: Colors.pink.shade400, // primary color
//               brightness: Brightness.dark,

//               // AppBar
//               appBarTheme: const AppBarTheme(
//                 backgroundColor: Colors.grey,
//                 foregroundColor: Colors.white,
//               ),

//               // Buttons
//               elevatedButtonTheme: ElevatedButtonThemeData(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.pink.shade400,
//                   foregroundColor: Colors.white,
//                   textStyle: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//               ),

//               // Cards
//               cardColor: Colors.grey.shade900,

//               // Text
//               textTheme: const TextTheme(
//                 bodyMedium: TextStyle(color: Colors.white),
//                 bodyLarge: TextStyle(color: Colors.white),
//                 titleMedium: TextStyle(color: Colors.white),
//               ),

//               // Input Decorations
//               inputDecorationTheme: const InputDecorationTheme(
//                 hintStyle: TextStyle(color: Colors.white70),
//                 prefixIconColor: Colors.white70,
//                 border: InputBorder.none,
//               ),
//             ),

//             // -----------------------
//             // HOME SCREEN
//             // -----------------------
//             home: auth.isLoggedIn
//                 ? const DashboardScreen()
//                 : const LoginScreen(),

//             // -----------------------
//             // ROUTES
//             // -----------------------
//             routes: {
//               // Auth
//               '/login': (ctx) => const LoginScreen(),
//               '/dashboard': (ctx) => const DashboardScreen(),

//               // Products
//               '/products': (ctx) => const ProductListScreen(),

//               // Orders
//               '/orders': (ctx) => const OrderListScreen(),
//               '/create_order': (ctx) => const CreateOrderScreen(),

//               // Order Details (requires ID)
//               '/order-details': (ctx) {
//                 final id = ModalRoute.of(ctx)?.settings.arguments;
//                 if (id is String) {
//                   return OrderDetailScreen(orderId: id);
//                 }
//                 return const OrderListScreen();
//               },
//             },
//           );
//         },
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import './providers/auth_provider.dart';
import './providers/product_provider.dart';
import './providers/order_provider.dart';

import './screens/login_screen.dart';
import './screens/dashboard_screen.dart';
import './screens/products/product_list_screen.dart';
import './screens/orders/order_list_screen.dart';
import './screens/orders/order_create_screen.dart';
import './screens/orders/order_detail_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const InventoryApp());
}

class InventoryApp extends StatelessWidget {
  const InventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, ProductProvider>(
          create: (_) => ProductProvider(),
          update: (_, auth, previous) => previous ?? ProductProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, OrderProvider>(
          create: (_) => OrderProvider(),
          update: (_, auth, previous) => previous ?? OrderProvider(),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Inventory & Orders',

            // -------------------
            // DARK THEME
            // -------------------
            theme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: Colors.black,
              primaryColor: Colors.pink.shade400,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              cardColor: Colors.grey.shade900,
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink.shade400,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              textTheme: const TextTheme(
                bodyMedium: TextStyle(color: Color.fromARGB(255, 175, 8, 139)),
                bodyLarge: TextStyle(color: Color.fromARGB(255, 90, 9, 171)),
                titleMedium: TextStyle(color: Color.fromARGB(255, 208, 11, 11)),
              ),
              inputDecorationTheme: const InputDecorationTheme(
                hintStyle: TextStyle(color: Color.fromARGB(179, 197, 12, 12)),
                prefixIconColor: Colors.white70,
                border: InputBorder.none,
              ),
            ),

            // -------------------
            // HOME / ROUTES
            // -------------------
            home: auth.isLoggedIn
                ? const DashboardScreen()
                : const LoginScreen(),
            routes: {
              '/login': (ctx) => const LoginScreen(),
              '/dashboard': (ctx) => const DashboardScreen(),
              '/products': (ctx) => const ProductListScreen(),
              '/orders': (ctx) => const OrderListScreen(),
              '/create_order': (ctx) => const CreateOrderScreen(),
              '/order-details': (ctx) {
                final id = ModalRoute.of(ctx)?.settings.arguments;
                if (id is String) return OrderDetailScreen(orderId: id);
                return const OrderListScreen();
              },
            },
          );
        },
      ),
    );
  }
}
