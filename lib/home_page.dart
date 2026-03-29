import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_scaffold.dart';          // <-- Import your reusable scaffold
import 'scanner_page.dart'; 


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(                 // <-- Use AppScaffold instead of Scaffold
      title: "SafePantry",
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [

                const SizedBox(height: 80),

                Text(
                  "SafePantry",
                  style: GoogleFonts.quattrocento(
                    color: const Color(0xFF1e3504),
                    fontSize: 45,
                    fontWeight: FontWeight.bold,
                    height: 1.1, 
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  "Scan food items instantly to check if they’ve been recalled. Powered by FDA data.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.questrial(fontSize: 16),
                ),

               // pushes the button to the bottom
                const SizedBox(height: 80),
                SizedBox(
                  width: 260,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScannerPage(),
                        ),
                      );
                    },
                    child: Text(
                      "Scan Your Item",
                      style: GoogleFonts.questrial(
                        fontSize: 18,
                        color: const Color(0xFF1e3504),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40), // bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }
}
