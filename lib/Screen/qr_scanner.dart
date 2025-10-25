import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:oraculo/Screen/spash_screen.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isRegistering = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: const Color(0xFF2D7A7B),
        actions: [
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off);
                  case TorchState.on:
                    return const Icon(Icons.flash_on);
                }
              },
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: cameraController.cameraFacingState,
              builder: (context, state, child) {
                switch (state) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                }
              },
            ),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: MobileScanner(
        controller: cameraController,
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              // QR Code detectado - mostrar mensagem e voltar
              _onQRCodeDetected(context, barcode.rawValue!);
              break;
            }
          }
        },
      ),
    );
  }

  void _onQRCodeDetected(BuildContext context, String qrCode) {
  if (_isRegistering) return;
  _isRegistering = true;
  _registerAttendance(context, qrCode);
  }

  Future<void> _registerAttendance(BuildContext context, String qrCode) async {
  final url = Uri.parse('http://172.20.10.2:3000/api/attendance/register'); // Use o IP local e porta correta do backend
    final body = jsonEncode({
      'employee_code': qrCode,
      'auth_method': 'qr',
    });
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Registro realizado com sucesso!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Erro ao registrar ponto.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro de conexão: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MySplashScreen()),
        (route) => false,
      );
      _isRegistering = false;
    });
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}