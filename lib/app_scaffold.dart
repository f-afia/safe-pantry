import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';
import 'scanner_page.dart';
import 'past_scans_page.dart';
import 'recent_recalls_page.dart';
import 'home_page.dart';
import 'login_page.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;

  const AppScaffold({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFeedfd7),
      appBar: AppBar(title: Text(title)),

      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text("Menu")),

            ListTile(
              title: const Text("Home"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
            ),

            ListTile(
              title: const Text("Login"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),

            ListTile(
              title: const Text("Scan Your Item"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScannerPage()),
                );
              },
            ),

            ListTile(
              title: const Text("Past Scans"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PastScansPage()),
                );
              },
            ),

            ListTile(
              title: const Text("Recent Recalls"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RecentRecallsPage()),
                );
              },
            ),

            const ListTile(title: Text("How It Works")),

            // ✅ LOGOUT BUTTON (added)
            ListTile(
              title: const Text("Logout"),
              onTap: () async {
  final prefs = await SharedPreferences.getInstance();

  // ✅ clear scans too
  await DatabaseHelper().clearAllScans();

  await prefs.clear();

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const LoginPage()),
    (route) => false,
  );
},
            ),
          ],
        ),
      ),

      body: body,
    );
  }
}