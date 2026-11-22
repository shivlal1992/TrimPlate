
import 'package:flutter/material.dart';
import 'mobile_login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF10280F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              const Icon(
                Icons.eco,
                size: 105,
                color: Color(0xFF9BCB45),
              ),
              const SizedBox(height: 20),
              const Text(
                'TRIMPLATE',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const Text(
                'Eat Healthy, Live Healthy',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 17,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.restaurant,
                size: 130,
                color: Color(0xFF9BCB45),
              ),
              const SizedBox(height: 24),
              const Text(
                'Fresh & Healthy Meals\nDelivered Daily',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF008747),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MobileLoginScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Continue with Mobile',
                    style: TextStyle(fontSize: 17),
                  ),
                ),
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
