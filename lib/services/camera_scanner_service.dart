import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class CameraScannerService {
  final MobileScannerController _scannerController = MobileScannerController();

  Widget buildScanner(BuildContext context, Function(String) onDetect) {
    return MobileScanner(
      controller: _scannerController,
      onDetect: (capture) {
        final List<Barcode> barcodes = capture.barcodes;
        if (barcodes.isNotEmpty) {
          final barcode = barcodes.first;
          if (barcode.rawValue != null) {
            onDetect(barcode.rawValue!);
          }
        }
      },
    );
  }

  void dispose() {
    _scannerController.dispose();
  }
}
