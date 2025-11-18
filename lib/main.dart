import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
//auth screens
import 'screens/auth/role_selection_screen.dart';
import 'screens/auth/admin_auth_screen.dart';
import 'screens/auth/staff_auth_screen.dart';
//dashboard screens
import 'screens/admin/admin_dashboard.dart';
import 'screens/staff/staff_dashboard.dart'; 
import 'screens/dishes/add_dish_screen_new.dart';
import 'screens/inventory/add_ingredient_screen.dart';
//providers
import 'providers/auth_provider.dart';
import 'providers/inventory_provider.dart';
import 'providers/order_provider.dart';
import 'providers/theme_provider.dart';
//theme
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Chefventory',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: '/',
          routes: {
            '/': (context) => RoleSelectionScreen(),
            '/admin-auth': (context) => AdminAuthScreen(),
            '/staff-auth': (context) => StaffAuthScreen(),
            '/admin-dashboard': (context) => const AdminDashboard(),
            '/staff-dashboard': (context) => const ModernStaffDashboard(),
            '/add-dish': (context) => const AddDishScreenNew(),
            '/add-ingredient': (context) => const AddIngredientScreen(),
          },
        );
      },
    );
  }
}