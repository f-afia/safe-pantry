import 'package:flutter/material.dart';
import 'app_scaffold.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecentRecallsPage extends StatefulWidget {
  const RecentRecallsPage({super.key});

  @override
  State<RecentRecallsPage> createState() => _RecentRecallsPageState();
}

class _RecentRecallsPageState extends State<RecentRecallsPage> {
  List<Map<String, String>> recalls = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchRecalls();
  }

  Future<void> fetchRecalls() async {
    try {
      final url = Uri.parse('http://localhost:5000/api/recalls'); // your backend
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;

        recalls = data.map((item) {
          // Full product text for More Info
          final fullProduct = (item['product'] ?? 'Unknown Product').toString();

          // Truncate title for list display
          String product = fullProduct;
          if (product.length > 50) {
            product = '${product.substring(0, 50)}...';
          }

          // Combine full product + recall details for the dialog
          final details =
              '$fullProduct\n\n${(item['details'] ?? '').toString()}';

          // Format date YYYYMMDD -> MM/DD/YYYY
          String rawDate = (item['date'] ?? '').toString();
          String formattedDate = rawDate.length == 8
              ? '${rawDate.substring(4, 6)}/${rawDate.substring(6, 8)}/${rawDate.substring(0, 4)}'
              : rawDate;

          return <String, String>{
            'product': product,
            'company': (item['company'] ?? 'Unknown Manufacturer').toString(),
            'date': formattedDate,
            'reason': (item['reason'] ?? '').toString(),
            'details': details,
          };
        }).toList();

        setState(() {
          loading = false;
        });
      } else {
        setState(() {
          error = 'Error fetching recalls: ${response.statusCode}';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error fetching recalls: $e';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Recent Recalls',
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(child: Text(error!))
                : ListView.builder(
                    itemCount: recalls.length,
                    itemBuilder: (context, index) {
                      final recall = recalls[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product title (truncated)
                              Text(
                                recall['product']!,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),

                              // Company
                              Text(
                                recall['company']!,
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              const SizedBox(height: 12),

                              // Date
                              Text(
                                'Recall Date: ${recall['date']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Reason
                              Text(recall['reason']!),
                              const SizedBox(height: 14),

                              // More Info button
                              TextButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(recall['product']!),
                                        content: SingleChildScrollView(
                                          child: Text(recall['details']!),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Close'),
                                          )
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: const Text('More Info'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}