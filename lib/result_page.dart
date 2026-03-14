import 'package:flutter/material.dart';
import 'app_scaffold.dart';
import 'scan_history.dart';

class ResultPage extends StatelessWidget {
  final String barcode;

  const ResultPage({super.key, required this.barcode});

  @override
  Widget build(BuildContext context) {

    Map<String, Map<String, String>> fakeDatabase = {
      "043000794609": {
        "name": "Maxwell House Instant Coffee",
        "company": "Kraft Heinz",
        "status": "RECALL",
        "details": "No recalls found for this product."
      },
      "032917001597": {
        "name": "Traditional Medicinals Throat Coat Tea",
        "company": "Traditional Medicinals",
        "status": "SAFE",
        "details": "No recalls found for this product."
      }
    };

    final product = fakeDatabase[barcode] ?? {
      "name": "Unknown Product",
      "company": "Unknown Manufacturer",
      "status": "UNKNOWN",
      "details": "Product not found in database."
    };

    // Save to history
    if (scanHistory.isEmpty || scanHistory.first["barcode"] != barcode) {
      scanHistory.insert(0, {
        "name": product["name"]!,
        "barcode": barcode,
        "status": product["status"]!,
      });
    }

    final bool isRecall = product["status"] == "RECALL";

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
                    product["name"]!,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// Manufacturer
                  Text(
                    product["company"]!,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// Status Row
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
                          product["status"]!,
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
                    product["details"]!,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 35),

                  /// Button
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