import 'package:flutter/material.dart';

import 'scanner_page.dart';
import 'past_scans_page.dart';
import 'recent_recalls_page.dart';
import 'home_page.dart';

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
                            MaterialPageRoute(
                              builder: (context) => const HomePage(),
                            ),
                          );
                        },
                      ),


            ListTile(
              title: const Text("Scan Your Item"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScannerPage(),
                  ),
                );
              },
            ),

            ListTile(
              title: const Text("Past Scans"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PastScansPage(),
                  ),
                );
              },
            ),

            ListTile(
              title: const Text("Recent Recalls"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RecentRecallsPage(),
                  ),
                );
              },
            ),

          const ListTile(title: Text("How It Works")),
          ],
        ),
      ),

      body: body,
    );
  }
}