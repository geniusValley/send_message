import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/login_controller.dart';

class LoginPage extends StatelessWidget {
  final LoginController _controller = LoginController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginPage({super.key});

  void _login(BuildContext context) async {
    final response = await _controller.loginUser(
      _phoneController.text,
      _passwordController.text,
    );

    if (response != null) {
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.number, // تنظیم کیبورد فقط برای اعداد
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // فقط اعداد مجاز است
                LengthLimitingTextInputFormatter(11), // محدودیت به 11 رقم
              ],
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              keyboardType: TextInputType.text, // کیبورد کامل
            ),
            ElevatedButton(onPressed: () => _login(context), child: const Text('Login')),
          ],
        ),
      ),
    );
  }
}
