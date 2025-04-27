import 'changepass.dart';
import 'doctor.dart';
import 'historypage.dart';
import 'orderpage.dart';
import 'profilepage.dart';
import 'refundpage.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  
  @override
  State<ProfilePage> createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {
  final Color primaryBlue = const Color(0xFF2F80ED); // Main blue
  final Color secondaryBlue =
      Color.fromARGB(255, 163, 232, 255); // Lighter blue
  final Color iconBgColor = const Color(0xFFE6F0FA); // Light icon background

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue,
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 90),
              const CircleAvatar(
                radius: 50,
                backgroundImage:
                    AssetImage('assets/profile.jpg'), // Profile image
              ),
              const SizedBox(height: 13),
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: "Good Morning, ",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    TextSpan(
                      text: "Prasanna 👋",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: secondaryBlue),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                '+918140234678',
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 50),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 245, 246, 253),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: ListView(
                    children: [
                      const Text(
                        "Account Overview",
                        style: TextStyle(
                            fontSize: 21, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 30),
                      profileTile(context, Icons.shopping_bag, "My Orders",
                          MyOrdersPage()),
                      profileTile(
                          context, Icons.cached, "Refund", RefundPage()),
                      profileTile(context, Icons.lock, "Change Password",
                          ResetPasswordPage()),
                      profileTile(
                          context, Icons.language, "Meetings", HistoryPage()),
                      profileTile(context, Icons.medical_services,
                          "Act as Doctor", DoctorForm()),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Edit Icon at Top-Right
          Positioned(
            top: 40,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => profiledit()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget profileTile(
      BuildContext context, IconData icon, String title, Widget targetPage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconBgColor,
          child: Icon(icon, color: primaryBlue),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => targetPage),
          );
        },
      ),
    );
  }
}
//act as doctor