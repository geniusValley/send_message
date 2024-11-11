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
          const SnackBar(content: Text('ورود با شکست مواجه شد!')),
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
            Directionality(
              textDirection: TextDirection.rtl,
              child: TextField(
                controller: _phoneController,textDirection: TextDirection.rtl,textAlign: TextAlign.right,
                decoration: const InputDecoration(labelText: 'شماره موبایل'),
                keyboardType: TextInputType.number, // تنظیم کیبورد فقط برای اعداد
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // فقط اعداد مجاز است
                  LengthLimitingTextInputFormatter(11), // محدودیت به 11 رقم
                ],
              ),
            ),
            Directionality(
              textDirection: TextDirection.rtl,
              child: TextField(
                controller: _passwordController,textDirection: TextDirection.rtl,textAlign: TextAlign.right,
                decoration: const InputDecoration(labelText: 'پسورد'),
                keyboardType: TextInputType.text, // کیبورد کامل
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(onPressed: () => _login(context), child: const Text('ورود')),
            ),
          ],
        ),
      ),
    );
  }
}
