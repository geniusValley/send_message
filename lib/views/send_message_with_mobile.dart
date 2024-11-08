import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';

class SendSmsPage extends StatefulWidget {
  @override
  _SendSmsPageState createState() => _SendSmsPageState();
}

class _SendSmsPageState extends State<SendSmsPage> {
  final Telephony telephony = Telephony.instance;
  TextEditingController _phoneNumberController = TextEditingController();

  // متنی که می‌خواهیم ارسال کنیم
  String message = "سلام.\nخوبی؟\nدلم برات تنگ شده خیلی";

  // تابع ارسال پیامک
  void _sendSMS(String message, String phoneNumber) async {
    bool? permissionsGranted = await telephony.requestSmsPermissions;
    if (permissionsGranted ?? false) {
      telephony.sendSms(
        to: phoneNumber,
        message: message,
      );
    } else {
      print("Permissions not granted");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ارسال پیامک"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneNumberController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "شماره موبایل",
                hintText: "11 رقم شماره موبایل را وارد کنید",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String phoneNumber = _phoneNumberController.text.trim();
                if (phoneNumber.length == 11) {
                  _sendSMS(message, phoneNumber);
                } else {
                  // در صورت اشتباه وارد کردن شماره موبایل
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("لطفا یک شماره موبایل معتبر وارد کنید."),
                    ),
                  );
                }
              },
              child: Text("ارسال پیام"),
            ),
          ],
        ),
      ),
    );
  }
}


//**** in android/app/build.gradle :

// defaultConfig {
// // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
// applicationId = "com.example.cargo_mobile"
// // You can update the following values to match your application needs.
// // For more information, see: https://flutter.dev/to/review-gradle-config.
// minSdk = 23
// targetSdk = flutter.targetSdkVersion
// versionCode = flutter.versionCode
// versionName = flutter.versionName
// }

// **** in android/app/main/AndroidManifest.xml  :

// <!-- دسترسی به ارسال پیامک -->
// <uses-permission android:name="android.permission.SEND_SMS"/>
// <uses-permission android:name="android.permission.READ_PHONE_STATE"/>
// <uses-permission android:name="android.permission.RECEIVE_SMS"/>
