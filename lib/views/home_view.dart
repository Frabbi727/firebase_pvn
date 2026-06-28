import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class HomeView extends GetView<AuthController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E1B4B), // Dark Indigo
              Color(0xFF0F172A), // Slate Dark
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Success Badge/Icon
                const Center(
                  child: CircleAvatar(
                    radius: 44,
                    backgroundColor: Color(0xFF10B981), // Emerald Green
                    child: Icon(
                      Icons.check_circle_outline_rounded,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Title
                const Text(
                  "Registration Success!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Your profile has been saved in Firestore. You can sign in using this phone number in the future.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 32),
                // User details card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "FIRESTORE PROFILE DATA",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFC084FC),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const Divider(color: Colors.white24, height: 20),
                      // Name
                      const Text(
                        "Full Name",
                        style: TextStyle(fontSize: 13, color: Colors.white38),
                      ),
                      const SizedBox(height: 2),
                      Obx(() => Text(
                            controller.userModel?.name ?? "Fetching name...",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )),
                      const SizedBox(height: 14),
                      // Email
                      const Text(
                        "Email Address",
                        style: TextStyle(fontSize: 13, color: Colors.white38),
                      ),
                      const SizedBox(height: 2),
                      Obx(() => Text(
                            controller.userModel?.email ?? "Fetching email...",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )),
                      const SizedBox(height: 14),
                      // Phone Number
                      const Text(
                        "Phone Number",
                        style: TextStyle(fontSize: 13, color: Colors.white38),
                      ),
                      const SizedBox(height: 2),
                      Obx(() => Text(
                            controller.userModel?.phoneNumber ??
                                controller.user?.phoneNumber ??
                                "N/A",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )),
                      const SizedBox(height: 14),
                      // UID
                      const Text(
                        "UID",
                        style: TextStyle(fontSize: 13, color: Colors.white38),
                      ),
                      const SizedBox(height: 2),
                      Obx(() => Text(
                            controller.user?.uid ?? "N/A",
                            style: const TextStyle(
                              fontSize: 13,
                              fontFamily: 'monospace',
                              color: Colors.white60,
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Logout Button
                Obx(() {
                  final isLoading = controller.isLoading.value;
                  return ElevatedButton.icon(
                    onPressed: isLoading ? null : () => controller.logout(),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text(
                      "Log Out / Exit",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
