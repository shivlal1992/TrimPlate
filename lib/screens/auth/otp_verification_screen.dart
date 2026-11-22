
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../home/home_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phone;
  final String? devOtp;

  const OtpVerificationScreen({
    super.key,
    required this.phone,
    this.devOtp,
  });

  @override
  State<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final otpController = TextEditingController();
  bool loading = false;

  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();

    if (!RegExp(r'^[0-9]{6}$').hasMatch(otp)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid 6-digit OTP')),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final response = await ApiService.verifyOtp(widget.phone, otp);

      if (!mounted) return;

      if (response['success'] == true) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
              (_) => false,
        );
      } else {
        throw Exception(response['message'] ?? 'OTP verification failed');
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
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.verified_user,
              size: 70,
              color: Color(0xFF008747),
            ),
            const SizedBox(height: 20),
            const Text(
              'Verify Your Mobile Number',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text('Enter the OTP sent to +91 ${widget.phone}'),
            const SizedBox(height: 25),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: '6-digit OTP',
                border: OutlineInputBorder(),
              ),
            ),
            if (widget.devOtp != null) ...[
              const SizedBox(height: 8),
              Text(
                'Development OTP: ${widget.devOtp}',
                style: const TextStyle(color: Colors.orange),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: loading ? null : verifyOtp,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text('Verify & Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
