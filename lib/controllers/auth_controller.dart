import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../data/models/user_model.dart';
import '../data/services/auth_service.dart';
import '../data/services/database_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();

  // Reactive variables
  final Rxn<User> rxUser = Rxn<User>();
  final Rxn<UserModel> rxUserModel = Rxn<UserModel>();
  
  final RxBool isLoading = false.obs;
  final RxString verificationId = ''.obs;
  final RxString errorMessage = ''.obs;
  final RxInt resendTimeout = 60.obs;

  Timer? _timer;
  StreamSubscription<User?>? _authSubscription;

  User? get user => rxUser.value;
  UserModel? get userModel => rxUserModel.value;

  @override
  void onInit() {
    super.onInit();
    // Bind current user to auth state changes and load database profile
    rxUser.value = _authService.currentUser;
    
    _authSubscription = _authService.authStateChanges.listen((User? firebaseUser) async {
      rxUser.value = firebaseUser;
      
      // Delay routing until the widget tree has built and GetMaterialApp navigation is ready
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (firebaseUser != null) {
          isLoading.value = true;
          try {
            // Check if user has a profile document in Firestore
            UserModel? profile = await _dbService.getUser(firebaseUser.uid);
            rxUserModel.value = profile;
            
            if (profile != null) {
              // Already registered, go directly to Home
              Get.offAllNamed('/home');
            } else {
              // New user, go to Complete Profile view
              Get.offAllNamed('/register-info');
            }
          } catch (e) {
            // In case Firestore fails (e.g. database not created yet), go to registration view
            debugPrint("Firestore fetch profile failed: $e");
            Get.offAllNamed('/register-info');
          } finally {
            isLoading.value = false;
          }
        } else {
          // Logged out
          rxUserModel.value = null;
          Get.offAllNamed('/phone-input');
        }
      });
    });
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    _timer?.cancel();
    super.onClose();
  }

  // Start OTP countdown timer
  void _startTimer() {
    resendTimeout.value = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendTimeout.value > 0) {
        resendTimeout.value--;
      } else {
        _timer?.cancel();
      }
    });
  }

  // Send OTP code to the provided phone number
  Future<void> sendOtp(String phoneNumber) async {
    if (phoneNumber.trim().isEmpty) {
      errorMessage.value = "Phone number cannot be empty";
      return;
    }

    isLoading.value = true;
    errorMessage.value = "";

    try {
      await _authService.verifyPhoneNumber(
        phoneNumber: phoneNumber.trim(),
        onVerificationCompleted: (PhoneAuthCredential credential) async {
          await _authService.signInWithCredential(credential);
          // Flow redirection handled in the authStateChanges listener
        },
        onVerificationFailed: (FirebaseAuthException e) {
          isLoading.value = false;
          errorMessage.value = e.message ?? "Verification failed";
          Get.snackbar(
            "Verification Failed",
            errorMessage.value,
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        onCodeSent: (String verId, int? resendToken) {
          verificationId.value = verId;
          isLoading.value = false;
          errorMessage.value = "";
          _startTimer();
          // Navigate to OTP verification screen
          Get.toNamed('/otp-verify');
        },
        onCodeAutoRetrievalTimeout: (String verId) {
          verificationId.value = verId;
        },
      );
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
    }
  }

  // Verify OTP and complete sign in
  Future<void> verifyOtp(String smsCode) async {
    if (smsCode.trim().length != 6) {
      errorMessage.value = "Please enter a valid 6-digit code";
      return;
    }

    isLoading.value = true;
    errorMessage.value = "";

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: smsCode.trim(),
      );

      await _authService.signInWithCredential(credential);
      // Success will trigger authStateChanges listener and route the user
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      errorMessage.value = e.message ?? "Invalid OTP code";
      Get.snackbar(
        "Error",
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
    }
  }

  // Save new user profile information to Firestore
  Future<void> registerUser(String name, String email) async {
    final firebaseUser = _authService.currentUser;
    if (firebaseUser == null) {
      Get.offAllNamed('/phone-input');
      return;
    }

    isLoading.value = true;
    errorMessage.value = "";

    try {
      UserModel profile = UserModel(
        uid: firebaseUser.uid,
        phoneNumber: firebaseUser.phoneNumber ?? "",
        name: name,
        email: email,
        createdAt: DateTime.now(),
      );

      await _dbService.saveUser(profile);
      rxUserModel.value = profile;
      isLoading.value = false;
      Get.offAllNamed('/home');
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
      Get.snackbar(
        "Error",
        "Failed to save profile: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Sign out the current user
  Future<void> logout() async {
    isLoading.value = true;
    try {
      await _authService.signOut();
    } catch (e) {
      Get.snackbar("Error", "Logout failed: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
