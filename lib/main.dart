import 'package:ecommerce/pages/auth.dart';
import 'package:ecommerce/providers/cart_provider.dart';
import 'package:ecommerce/providers/wishlist_provider.dart';
import 'package:ecommerce/themes/dark.dart';
import 'package:ecommerce/themes/light.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
      ],
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (_, ThemeMode currentMode, __) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: const AuthPage(),
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: currentMode,
          );
        },
      ),
    );
  }
}
