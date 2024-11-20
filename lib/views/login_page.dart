import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/login_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final LoginController _controller = LoginController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _phoneFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool isLoading = false;

  Future<void> _login(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true;
      });

      final response = await _controller.loginUser(
        _phoneController.text,
        _passwordController.text,
      );

      setState(() {
        isLoading = false;
      });

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
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey, fontSize: 16),
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Color(0xff30471f)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Color(0xff30471f), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Colors.grey, width: 1.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Colors.red, width: 1.0),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = bottomInset > 0;
    final mediaQueryWidth = MediaQuery.of(context).size.width;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: isKeyboardOpen ? mediaQueryWidth * 0.05 : mediaQueryWidth * 0.1),
                  Padding(
                    padding: EdgeInsets.all(mediaQueryWidth * 0.1),
                    child: Image.asset(
                      "assets/large_logo.png",
                      height: isKeyboardOpen ? mediaQueryWidth * 0.35 : mediaQueryWidth * 0.45,
                      width: isKeyboardOpen ? mediaQueryWidth * 0.35 : mediaQueryWidth * 0.45,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: TextFormField(
                      focusNode: _phoneFocusNode,
                      textInputAction: TextInputAction.next,
                      controller: _phoneController,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      decoration: _buildInputDecoration('شماره موبایل'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                      ],
                      onFieldSubmitted: (value) {
                        // انتقال فوکوس به فیلد دوم
                        FocusScope.of(context).requestFocus(_passwordFocusNode);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'شماره موبایل الزامی است';
                        } else if (value.length != 11) {
                          return 'شماره موبایل باید ۱۱ رقم باشد';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: TextFormField(
                      focusNode: _passwordFocusNode,
                      textInputAction: TextInputAction.done,
                      controller: _passwordController,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      decoration: _buildInputDecoration('پسورد'),
                      keyboardType: TextInputType.text,
                      obscureText: true,
                      onFieldSubmitted: (value) {
                        // اجرای لاگین هنگام کلیک روی دکمه Done
                        if (_formKey.currentState!.validate()) {
                          _login(context);
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'وارد کردن پسورد الزامی است';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: isKeyboardOpen ? mediaQueryWidth * 0.08 : mediaQueryWidth * 0.45),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () => _login(context),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xff30471f),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('ورود', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
