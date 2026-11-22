
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'otp_verification_screen.dart';

class MobileLoginScreen extends StatefulWidget {
  const MobileLoginScreen({super.key});

  @override
  State<MobileLoginScreen> createState() => _MobileLoginScreenState();
}

class _MobileLoginScreenState extends State<MobileLoginScreen> {
  final phoneController = TextEditingController();
  bool loading = false;

  Future<void> sendOtp() async {
    final phone = phoneController.text.trim();

    if (!RegExp(r'^[6-9][0-9]{9}$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid 10-digit mobile number')),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final response = await ApiService.sendOtp(phone);

      if (!mounted) return;

      if (response['success'] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpVerificationScreen(
              phone: phone,
              devOtp: response['dev_otp']?.toString(),
            ),
          ),
        );
      } else {
        throw Exception(response['message'] ?? 'Unable to send OTP');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.eco, size: 65, color: Color(0xFF008747)),
            const SizedBox(height: 25),
            const Text(
              'Welcome to TrimPlate',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text('Enter your mobile number to continue'),
            const SizedBox(height: 30),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: const InputDecoration(
                labelText: 'Mobile Number',
                prefixText: '+91 ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: loading ? null : sendOtp,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text('Send OTP'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
