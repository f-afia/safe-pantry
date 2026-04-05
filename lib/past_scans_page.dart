import 'package:flutter/material.dart';
import 'app_scaffold.dart';
import 'scan_history.dart';
import 'database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PastScansPage extends StatefulWidget {
  const PastScansPage({super.key});

  @override
  State<PastScansPage> createState() => _PastScansPageState();
}

class _PastScansPageState extends State<PastScansPage> {
  List<Map<String, String>> displayScans = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadScans();
  }

  /// Load scans either from database (logged-in) or local scanHistory (guest)
  Future<void> loadScans() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (isLoggedIn) {
      final email = prefs.getString('user_email');
      if (email != null) {
        final dbScans = await DatabaseHelper().getScansByUser(email);
        setState(() {
          displayScans = dbScans.map((scan) => <String, String>{
  "name": (scan['product_name'] ?? "Unknown Product").toString(),
  "barcode": (scan['barcode'] ?? "").toString(),
  "status": (scan['status'] ?? "SAFE").toString(),
}).toList();
          isLoading = false;
        });
        return;
      }
    }

    // Guest: use local scanHistory
    setState(() {
      displayScans = List.from(scanHistory);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return AppScaffold(
      title: "Past Scans",
      body: displayScans.isEmpty
          ? const Center(
              child: Text(
                "No items scanned yet.",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: displayScans.length,
              itemBuilder: (context, index) {
                final item = displayScans[index];
                final bool isRecall = item["status"] == "RECALL";

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.08),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(18),
                    leading: const Icon(
                      Icons.qr_code_scanner,
                      size: 32,
                    ),
                    title: Text(
                      item["name"]!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text("Barcode: ${item["barcode"]}"),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isRecall
                            ? Colors.red.withOpacity(.15)
                            : Colors.green.withOpacity(.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item["status"]!,
                        style: TextStyle(
                          color: isRecall ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}