import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'app_scaffold.dart';
import 'result_page.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {

  final MobileScannerController controller = MobileScannerController();
  bool _found = false;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Scan Item",

      body: MobileScanner(
        controller: controller,

        onDetect: (barcodeCapture) async {

          if (_found) return;

          final List<Barcode> barcodes = barcodeCapture.barcodes;

          for (final barcode in barcodes) {

            final String? code = barcode.rawValue;

            if (code != null) {

              _found = true;

              // STOP the scanner immediately
              await controller.stop();

              print("Scanned barcode: $code");

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ResultPage(barcode: code),
                ),
              ).then((_) {

                // restart scanner when returning
                _found = false;
                controller.start();

              });

              break;
            }
          }
        },
      ),
    );
  }
}