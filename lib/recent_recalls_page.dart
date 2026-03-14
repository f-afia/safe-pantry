import 'package:flutter/material.dart';
import 'app_scaffold.dart';

class RecentRecallsPage extends StatelessWidget {
  const RecentRecallsPage({super.key});

  @override
  Widget build(BuildContext context) {

    final List<Map<String, String>> recalls = [

      {
        "product": "Fresh Spinach Salad Mix",
        "company": "Green Valley Farms",
        "date": "May 12, 2026",
        "reason": "Potential E. coli contamination.",
        "details": "Consumers are advised to discard the product immediately."
      },

      {
        "product": "Organic Peanut Butter",
        "company": "NatureSpread Foods",
        "date": "April 30, 2026",
        "reason": "Possible Salmonella contamination.",
        "details": "Distributed nationwide to major grocery chains."
      },

      {
        "product": "Frozen Chicken Nuggets",
        "company": "FarmFresh Poultry Co.",
        "date": "April 15, 2026",
        "reason": "Possible presence of foreign material.",
        "details": "Consumers should not consume the product."
      }

    ];

    return AppScaffold(
      title: "Recent Recalls",

      body: ListView.builder(
        padding: const EdgeInsets.all(20),
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

                  /// Product
                  Text(
                    recall["product"]!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  /// Manufacturer
                  Text(
                    recall["company"]!,
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// Recall Date
                  Text(
                    "Recall Date: ${recall["date"]}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// Reason
                  Text(
                    recall["reason"]!,
                  ),

                  const SizedBox(height: 14),

                  /// More Info button
                  TextButton(
                    onPressed: () {

                      showDialog(
                        context: context,
                        builder: (context) {

                          return AlertDialog(
                            title: Text(recall["product"]!),

                            content: Text(recall["details"]!),

                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("Close"),
                              )
                            ],
                          );
                        },
                      );

                    },

                    child: const Text("More Info"),
                  )

                ],
              ),
            ),
          );
        },
      ),
    );
  }
}