import 'package:flutter/material.dart';
import 'app_scaffold.dart';
import 'scan_history.dart';

class PastScansPage extends StatelessWidget {
  const PastScansPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Past Scans",

      body: scanHistory.isEmpty
          ? const Center(
              child: Text(
                "No items scanned yet.",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: scanHistory.length,
              itemBuilder: (context, index) {

                final item = scanHistory[index];

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

                    subtitle: Text(
                      "Barcode: ${item["barcode"]}",
                    ),

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