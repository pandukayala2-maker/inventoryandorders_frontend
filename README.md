# frontend
 Inventory & Sales Management System – Flutter Frontend
This is the frontend of the Inventory & Sales Management System, built with Flutter. It connects to a Node.js + Express backend and provides screens for authentication, product management, and order management.
-----1
---- Tech Stack


Flutter SDK (latest stable)
Dart
Provider (State Management)
HTTP / Dio for API calls

Shared Preferences for storing JWT tokens

Flutter Widgets for UI
⚡ Features
Authentication

Login screen with email/employeeId and password

JWT token stored locally using shared_preferences

Authenticated API calls include the JWT token
Dashboard

Displays total number of products

Displays total number of orders

Product Screens

Product list with pagination and search by name/sku

Add new product

Edit existing product

Product details page

Handles loading, empty, and error states

Order Screens

Create new order:

Select/search products


Set quantity


Auto-calculate total amount




List all orders


Order details page


UI/UX


Clean, simple, and consistent UI


Proper form validation messages


Loading spinners and error messages where appropriate



🔧 Flutter Installation


Download Flutter SDK: Flutter Installation Guide


Extract to a folder (e.g., C:\src\flutter)


Add flutter\bin to your system PATH


Verify installation:


flutter doctor



Install a code editor: VS Code or Android Studio


Install Flutter and Dart plugins in the editor


Set up an Android Emulator or connect a physical device



📁 Project Setup


Clone the repository:


git clone <frontend-repo-url>
cd frontend



Install dependencies:


flutter pub get

Update the API base URL in lib/config/api.dart:
const String apiBase = "http://127.0.0.1:5000/api";

For web:


flutter run -d chrome



For desktop:


flutter run -d windows


📦 Folder Structure
lib/
 ├── config/             # API base and constants
 ├── models/             # Product, Order, User models
 ├── providers/          # State management using Provider
 ├── screens/
 │    ├── login_screen.dart
 │    ├── dashboard_screen.dart
 │    ├── products/
 │    │    ├── product_list_screen.dart
 │    │    ├── product_create_screen.dart
 │    │    └── product_detail_screen.dart
 │    ├── orders/
 │         ├── order_list_screen.dart
 │         ├── order_create_screen.dart
 │         └── order_detail_screen.dart
 ├── widgets/            # Reusable UI components
 └── main.dart


🔑 State Management


Provider is used for state management


AuthProvider handles login, logout, and token storage


ProductProvider manages product data


OrderProvider manages order data



📌 Notes


Ensure the backend is running before starting the frontend


JWT token must be included in headers for all protected API calls


Use flutter clean if encountering build errors

Run the app:


flutter run


