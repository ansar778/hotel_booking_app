import 'package:bookingapp/auth_wrapper.dart';
import 'package:bookingapp/pages/bottomnav.dart';
import 'package:bookingapp/pages/onboarding.dart';
import 'package:bookingapp/services/constant.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorWidget.builder = (FlutterErrorDetails details) => Container();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Load Stripe keys from environment or fallback to constants
  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? publishedKey;
  // For security, don't initialize secretKey in the app. Use it only on server-side.
  // final secretKey = dotenv.env['STRIPE_SECRET_KEY'] ?? secretKey;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ghureashi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: AuthWrapper(),
    );
  }
}
