
import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../widgets/app_bottom_nav_bar.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const EditProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {
  static const Color green = Color(0xFF008747);
  static const Color background = Color(0xFFF6F9F6);

  final formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController emailController;

  bool saving = false;

  // =====================================
  // INITIALIZE CONTROLLERS
  // =====================================
  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: widget.user['name']?.toString() ?? '',
    );

    emailController = TextEditingController(
      text: widget.user['email']?.toString() ?? '',
    );
  }

  // =====================================
  // DISPOSE CONTROLLERS
  // =====================================
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  // =====================================
  // SAVE PROFILE
  // =====================================
  Future<void> saveProfile() async {
    if (saving) return;

    if (!formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      saving = true;
    });

    try {
      final result = await ApiService.updateProfile(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
      );

      if (!mounted) return;

      if (result['success'] != true) {
        throw Exception(
          result['message'] ??
              'Unable to update profile',
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Profile updated successfully',
          ),
          backgroundColor: green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  // =====================================
  // INPUT FIELD DECORATION
  // =====================================
  InputDecoration fieldDecoration(
      String label,
      IconData icon,
      ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        color: green,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF68736D),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: green,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
    );
  }

  // =====================================
  // MAIN SCREEN
  // =====================================
  @override
  Widget build(BuildContext context) {
    final phone =
    (widget.user['phone'] ??
        widget.user['mobile'] ??
        '')
        .toString();

    return Scaffold(
      backgroundColor: background,

      // =====================================
      // APP BAR
      // =====================================
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFEDF4EF),
        elevation: 0,
      ),

      // =====================================
      // BODY
      // =====================================
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // PROFILE AVATAR
            const Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: Color(0xFFE5F3E8),
                child: Icon(
                  Icons.person,
                  size: 52,
                  color: green,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // =====================================
            // FULL NAME
            // =====================================
            TextFormField(
              controller: nameController,
              enabled: !saving,
              textCapitalization:
              TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: fieldDecoration(
                'Full Name',
                Icons.person_outline,
              ),
              validator: (value) {
                final name = value?.trim() ?? '';

                if (name.isEmpty) {
                  return 'Please enter your full name';
                }

                if (name.length < 2) {
                  return 'Enter at least 2 characters';
                }

                if (name.length > 255) {
                  return 'Name is too long';
                }

                return null;
              },
            ),

            const SizedBox(height: 18),

            // =====================================
            // MOBILE NUMBER
            // =====================================
            TextFormField(
              initialValue: phone,
              readOnly: true,
              decoration: fieldDecoration(
                'Mobile Number',
                Icons.phone_outlined,
              ).copyWith(
                helperText:
                'Mobile number cannot be changed here',
                helperMaxLines: 2,
              ),
            ),

            const SizedBox(height: 18),

            // =====================================
            // EMAIL ADDRESS
            // =====================================
            TextFormField(
              controller: emailController,
              enabled: !saving,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              decoration: fieldDecoration(
                'Email Address (Optional)',
                Icons.email_outlined,
              ),
              validator: (value) {
                final email = value?.trim() ?? '';

                if (email.isEmpty) {
                  return null;
                }

                final valid = RegExp(
                  r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                ).hasMatch(email);

                if (!valid) {
                  return 'Enter a valid email address';
                }

                if (email.length > 255) {
                  return 'Email address is too long';
                }

                return null;
              },
            ),

            const SizedBox(height: 30),

            // =====================================
            // SAVE CHANGES BUTTON
            // =====================================
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: saving ? null : saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                  green.withValues(alpha: 0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                  ),
                ),
                child: saving
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),

      // =====================================
      // COMMON BOTTOM NAVIGATION BAR
      // =====================================
      bottomNavigationBar: const AppBottomNavBar(
        selectedIndex: 3,
      ),
    );
  }
}
