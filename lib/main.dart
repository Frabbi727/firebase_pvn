import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';
import 'controllers/auth_controller.dart';
import 'views/phone_input_view.dart';
import 'views/otp_verify_view.dart';
import 'views/home_view.dart';
import 'views/register_info_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Firebase Phone Auth',
      debugShowCheckedModeBanner: false,
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController(), permanent: true);
      }),
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF8B5CF6),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF8B5CF6),
          secondary: Color(0xFFC084FC),
          surface: Color(0xFF1E1B4B),
        ),
        useMaterial3: true,
        fontFamily: 'Outfit', // Uses modern font styling if available, otherwise defaults gracefully
      ),
      // Let GetX routing handle initial redirects based on authStateChanges in controller
      initialRoute: '/phone-input',
      getPages: [
        GetPage(
          name: '/phone-input',
          page: () => PhoneInputView(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/otp-verify',
          page: () => OtpVerifyView(),
          transition: Transition.rightToLeftWithFade,
        ),
        GetPage(
          name: '/register-info',
          page: () => RegisterInfoView(),
          transition: Transition.downToUp,
        ),
        GetPage(
          name: '/home',
          page: () => const HomeView(),
          transition: Transition.zoom,
        ),
      ],
    );
  }
}
