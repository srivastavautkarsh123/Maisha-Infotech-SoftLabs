import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'utils/myntra_theme.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/checkout_viewmodel.dart';
import 'viewmodels/location_viewmodel.dart';
import 'viewmodels/product_viewmodel.dart';
import 'viewmodels/wishlist_viewmodel.dart';
import 'views/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize push notifications
  await NotificationService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ProductViewModel()),
        ChangeNotifierProvider(create: (_) => LocationViewModel()),
        ChangeNotifierProvider(create: (_) => CheckoutViewModel()),
        ChangeNotifierProvider(create: (_) => WishlistViewModel()),
      ],
      child: MaterialApp(
        title: 'Maisha Infotech',
        debugShowCheckedModeBanner: false,
        theme: MyntraTheme.theme,
        home: const AuthWrapper(),
      ),
    );
  }
}
