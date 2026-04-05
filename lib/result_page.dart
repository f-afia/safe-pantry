import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'app_scaffold.dart';
import 'scan_history.dart';
import 'database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResultPage extends StatefulWidget {
  final String barcode;

  const ResultPage({super.key, required this.barcode});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  Map<String, dynamic>? data;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  /// Save scan to database for logged-in users
  Future<void> saveScan(String barcode, String productName) async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    if (!isLoggedIn) return;

    final email = prefs.getString('user_email');
    if (email == null) return;

    final scan = {
      'user_email': email,
      'barcode': barcode,
      'product_name': productName,
      'timestamp': DateTime.now().toIso8601String(),
    };

    await DatabaseHelper().insertScan(scan);
  }

  /// Fetch product & recall data from your API
  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/barcode/${widget.barcode}'),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final product = decoded['product'];
        final name = product?['name'] ?? "Unknown Product";

        // Save scan in DB for logged-in users
        await saveScan(widget.barcode, name);

        setState(() {
          data = decoded;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("ERROR: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (data == null) {
      return const Center(child: Text("Error loading product"));
    }

    final product = data!['product'];
    final recall = data!['recall'];

    final name = product?['name'] ?? "Unknown Product";
    final brand = product?['brand'] ?? "Unknown Manufacturer";
    final isRecall = recall != null;
    final details = recall != null
        ? recall['reason_for_recall'] ?? "Recall found"
        : "No recalls found for this product.";

    // Add to local scan history for guest users
    if (scanHistory.isEmpty || scanHistory.first["barcode"] != widget.barcode) {
      scanHistory.insert(0, {
        "name": name,
        "barcode": widget.barcode,
        "status": isRecall ? "RECALL" : "SAFE",
      });
    }

    return AppScaffold(
      title: "Scan Result",
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// Product Name
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// Manufacturer
                  Text(
                    brand,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// Status
                  Row(
                    children: [
                      const Text(
                        "Status:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isRecall
                              ? Colors.red.withOpacity(.15)
                              : Colors.green.withOpacity(.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isRecall ? "RECALL" : "SAFE",
                          style: TextStyle(
                            color: isRecall ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  /// Recall Details
                  const Text(
                    "Recall Details",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    details,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 35),

                  /// Scan Another Item Button
                  Center(
                    child: SizedBox(
                      width: 220,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Scan Another Item",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}