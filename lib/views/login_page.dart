import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/login_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginController _controller = LoginController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        // appBar: AppBar(
        //   title: Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50),
        //     child: const Text("احراز هویت"),
        //   ),
        //   actions: [
        //     Padding(
        //       padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
        //       child: Image.asset(
        //         "lib/assets/small_logo.png",
        //         height: 80,
        //         width: 80,
        //       ),
        //     ),
        //   ],
        //   // bottom: PreferredSize(
        //   //     preferredSize: Size.fromHeight(100.0),
        //   //     child: Padding(
        //   //       padding: const EdgeInsets.all(8.0),
        //   //       child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        //   //         Text("احراز هویت"),
        //   //         Image.asset(
        //   //           "lib/assets/small_logo.png",
        //   //           height: 70,
        //   //           width: 70,
        //   //         ),
        //   //       ]),
        //   //     )),
        // ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("احراز هویت",style: TextStyle(fontSize: 20)),
                      Image.asset(
                        "lib/assets/small_logo.png",
                        height: 80,
                        width: 80,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextFormField(
                    controller: _phoneController,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    decoration: _buildInputDecoration('شماره موبایل'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(11),
                    ],
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
                    controller: _passwordController,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    decoration: _buildInputDecoration('پسورد'),
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'وارد کردن پسورد الزامی است';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: isLoading ? null : () => _login(context),
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xff30471f)),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('ورود', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
