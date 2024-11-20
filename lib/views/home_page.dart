import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/home_controller.dart';
import '../models/group_model.dart';
import 'package:telephony/telephony.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const platform = MethodChannel('sms_channel');

  final HomeController _controller = HomeController();
  String? selectedGroup;
  String? selectedGender;
  List<GroupModel> groups = [];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  late Future<List<GroupModel>> _groupsFuture;

  final Telephony telephony = Telephony.instance;

  // متنی که می‌خواهیم ارسال کنیم
  // String message = "سلام! به هیئت خیمة الشهدا خوش آمدید.\r\nاین مجموعه با محوریت مسجد و پایگاه موسی بن جعفر (ع) میزبان شماست.\r\n\r\nبرای عضویت در صفحات مجازی ما، از طریق لینک‌های زیر اقدام نمایید:\r\nروبیکا:\r";

  // تابع ارسال پیامک
  void _sendSMS(String message, String phoneNumber) async {
    bool? permissionsGranted = await telephony.requestSmsPermissions;
    if (permissionsGranted ?? false) {
      telephony.sendSms(
        to: phoneNumber,
        message: message,
        isMultipart: true,
      );
      sendSms(message, phoneNumber, 1);
    } else {
      print("Permissions not granted");
    }
  }

  Future<void> sendSms(String message, String phoneNumber, int simSlot) async {
    try {
      final result = await platform.invokeMethod('sendSms', {
        'message': message,
        'phoneNumber': phoneNumber,
        'simSlot': simSlot,
      });
      print(result); // Message sent
    } on PlatformException catch (e) {
      print("Failed to send SMS: ${e.message}");
    }
  }

  @override
  void initState() {
    super.initState();
    // _groupsFuture = _fetchGroups();
    _initializeTokenAndFetchGroups();
  }

  Future<void> _initializeTokenAndFetchGroups() async {
    // ابتدا توکن را تنظیم می‌کنیم
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');
    await _controller.setAuthToken(authToken ?? ""); // توکن خود را قرار دهید

    // بعد از تنظیم توکن، fetchGroups را فراخوانی می‌کنیم
    setState(() {
      _groupsFuture = _fetchGroups();
    });
  }

  Future<List<GroupModel>> _fetchGroups() async {
    try {
      final fetchedGroups = await _controller.fetchGroups();
      setState(() {
        groups = fetchedGroups;
        // اگر لیست فقط یک گروه داشت، مقدار پیش‌فرض را تنظیم کن
        if (groups.length == 1) {
          selectedGroup = groups.first.name;
        }
      });
      print("Groups fetched successfully: $fetchedGroups"); // چاپ داده‌های دریافتی
      return fetchedGroups;
    } catch (e) {
      print("Error fetching groups: $e");
      return [];
    }
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final selectedGroupId = groups.firstWhere((group) => group.name == selectedGroup).id.toString();

      final response = await _controller.addContact(
        firstName: nameController.text,
        lastName: lastNameController.text,
        phoneNumber: phoneController.text,
        gender: selectedGender!,
        groupId: selectedGroupId,
      );

      if (response != null) {
        final contact = response.contact;
        final message = response.message;
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                title: const Text("موفق"),
                content: Text(message ?? ""),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("باشه"),
                  ),
                ],
              ),
            ),
          );
        }

        String phoneNumber = phoneController.text.trim();
        if (phoneNumber.length == 11 && contact.lastMessage != null && contact.lastMessage!.isNotEmpty) {
          _sendSMS(contact.lastMessage!, phoneNumber);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("پیامی که از سرور می آید خالی است."),
              ),
            );
          }
        }
      } else {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("خطا"),
              content: const Text("مشکلی در اضافه کردن کاربر پیش آمد."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("باشه"),
                ),
              ],
            ),
          );
        }

      }
      // پاک کردن مقادیر فیلدهای متنی
      nameController.clear();
      lastNameController.clear();
      phoneController.clear();
    } else {
      // اگر فیلدها کامل نبودند، پیغام خطا نمایش داده شود
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("خطا"),
          content: const Text("لطفا همه فیلدها را پر کنید."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("باشه"),
            ),
          ],
        ),
      );
    }
  }

  // Validator functions for each field
  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return "$fieldName را وارد کنید";
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return "شماره موبایل را وارد کنید";
    } else if (value.length != 11) {
      return "شماره موبایل باید ۱۱ رقمی باشد";
    }
    return null;
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Scaffold(

          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: FutureBuilder<List<GroupModel>>(
              future: _groupsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("خطا در دریافت گروه‌ها: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("هیچ گروهی موجود نیست"));
                }

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
                                child: const Text("افزودن مخاطب",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
                                child: Image.asset(
                                  "assets/small_logo.png",
                                  height: 80,
                                  width: 80,
                                ),
                              ),
                            ],
                          ),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: "انتخاب گروه",
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white70,
                            ),
                            value: selectedGroup,
                            items: snapshot.data!.map((group) {
                              return DropdownMenuItem(
                                value: group.name,
                                child: Text(group.name),
                                alignment: Alignment.centerRight,
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedGroup = value;
                              });
                            },
                            validator: (value) => _validateRequired(value, "گروه"),
                            alignment: Alignment.centerRight,
                          ),
                          const SizedBox(height: 16),
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: "جنسیت",
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.white70,
                              ),
                              value: selectedGender,
                              items: const [
                                DropdownMenuItem(
                                  value: "مرد",
                                  child: Text("مرد"),
                                  alignment: Alignment.centerRight,
                                ),
                                DropdownMenuItem(
                                  value: "زن",
                                  child: Text("زن"),
                                  alignment: Alignment.centerRight,
                                ),
                              ],
                              alignment: Alignment.centerRight,
                              onChanged: (value) {
                                setState(() {
                                  selectedGender = value;
                                });
                              },
                              validator: (value) => _validateRequired(value, "جنسیت"),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: "نام",
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white70,
                            ),
                            textDirection: TextDirection.rtl,
                            validator: (value) => _validateRequired(value, "نام"),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: lastNameController,
                            decoration: const InputDecoration(
                              labelText: "نام خانوادگی",
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white70,
                            ),
                            textDirection: TextDirection.rtl,
                            validator: (value) => _validateRequired(value, "نام خانوادگی"),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: phoneController,
                            decoration: const InputDecoration(
                              labelText: "شماره موبایل",
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white70,
                            ),
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11),
                            ],
                            textDirection: TextDirection.rtl,
                            validator: _validatePhoneNumber,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              foregroundColor: Colors.white,
                              backgroundColor: const Color(0xff30471f),
                            ),
                            child: const Text(
                              "ثبت و ارسال پیامک",
                              style: TextStyle(fontSize: 20),
                            ),

                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../controllers/home_controller.dart';
// import '../models/group_model.dart';
// import 'package:telephony/telephony.dart';
//
// class HomePage extends StatefulWidget {
//   HomePage({super.key});
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   static const platform = MethodChannel('sms_channel');
//
//   final HomeController _controller = HomeController();
//   String? selectedGroup;
//   String? selectedGender;
//   List<GroupModel> groups = [];
//   String? selectedSimCard; // افزودن متغیر انتخاب سیم کارت
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController lastNameController = TextEditingController();
//   final TextEditingController phoneController = TextEditingController();
//
//   late Future<List<GroupModel>> _groupsFuture;
//
//   final Telephony telephony = Telephony.instance;
//
//   void _sendSMS(String message, String phoneNumber) async {
//     bool? permissionsGranted = await telephony.requestSmsPermissions;
//     if (permissionsGranted ?? false) {
//       int simSlot = selectedSimCard == "سیم کارت اول" ? 0 : 1;
//       List<String> messageParts = _splitMessage(message, 60); // تقسیم پیامک به بخش‌های 160 کاراکتری
//
//       for (String part in messageParts) {
//         await sendSms(part, phoneNumber, simSlot);
//         await Future.delayed(Duration(milliseconds: 500)); // فاصله زمانی بین ارسال هر بخش برای اطمینان
//       }
//     } else {
//       print("Permissions not granted");
//     }
//   }
//
// // تابع تقسیم پیامک به بخش‌های کوچکتر
//   List<String> _splitMessage(String message, int maxLength) {
//     List<String> parts = [];
//     for (int i = 0; i < message.length; i += maxLength) {
//       parts.add(message.substring(i, i + maxLength > message.length ? message.length : i + maxLength));
//     }
//     return parts;
//   }
//   Future<void> sendSms(String message, String phoneNumber, int simSlot) async {
//     try {
//       final result = await platform.invokeMethod('sendSms', {
//         'message': message,
//         'phoneNumber': phoneNumber,
//         'simSlot': simSlot,
//       });
//       print(result); // Message sent
//     } on PlatformException catch (e) {
//       print("Failed to send SMS: ${e.message}");
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeTokenAndFetchGroups();
//   }
//
//   Future<void> _initializeTokenAndFetchGroups() async {
//     final prefs = await SharedPreferences.getInstance();
//     final authToken = prefs.getString('auth_token');
//     await _controller.setAuthToken(authToken ?? "");
//
//     setState(() {
//       _groupsFuture = _fetchGroups();
//     });
//   }
//
//   Future<List<GroupModel>> _fetchGroups() async {
//     try {
//       final fetchedGroups = await _controller.fetchGroups();
//       setState(() {
//         groups = fetchedGroups;
//       });
//       print("Groups fetched successfully: $fetchedGroups");
//       return fetchedGroups;
//     } catch (e) {
//       print("Error fetching groups: $e");
//       return [];
//     }
//   }
//
//   void _submitForm() async {
//     if (nameController.text.isNotEmpty &&
//         lastNameController.text.isNotEmpty &&
//         phoneController.text.isNotEmpty &&
//         selectedGroup != null &&
//         selectedGender != null &&
//         selectedSimCard != null) {
//
//       final selectedGroupId = groups.firstWhere((group) => group.name == selectedGroup).id.toString();
//
//       final contact = await _controller.addContact(
//         firstName: nameController.text,
//         lastName: lastNameController.text,
//         phoneNumber: phoneController.text,
//         gender: selectedGender!,
//         groupId: selectedGroupId,
//       );
//
//       if (contact != null) {
//         if (mounted) {
//           showDialog(
//             context: context,
//             builder: (context) => AlertDialog(
//               title: const Text("موفق"),
//               content: const Text("کاربر با موفقیت اضافه شد."),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                   child: const Text("باشه"),
//                 ),
//               ],
//             ),
//           );
//         }
//
//         String phoneNumber = phoneController.text.trim();
//         if (phoneNumber.length == 11 && contact.lastMessage != null && contact.lastMessage!.isNotEmpty) {
//           _sendSMS(contact.lastMessage!, phoneNumber);
//         } else {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text("لطفا یک شماره موبایل معتبر وارد کنید."),
//               ),
//             );
//           }
//         }
//       } else {
//         showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const Text("خطا"),
//             content: const Text("مشکلی در اضافه کردن کاربر پیش آمد."),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: const Text("باشه"),
//               ),
//             ],
//           ),
//         );
//       }
//     } else {
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text("خطا"),
//           content: const Text("لطفا همه فیلدها را پر کنید."),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text("باشه"),
//             ),
//           ],
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("افزودن مخاطب"),
//       ),
//       body: FutureBuilder<List<GroupModel>>(
//         future: _groupsFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text("Error: ${snapshot.error}"));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text("No groups available"));
//           }
//
//           return SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   DropdownButtonFormField<String>(
//                     decoration: const InputDecoration(
//                       labelText: "انتخاب گروه",
//                       border: OutlineInputBorder(),
//                     ),
//                     value: selectedGroup,
//                     items: snapshot.data!.map((group) {
//                       return DropdownMenuItem(
//                         value: group.name,
//                         child: Text(group.name),
//                       );
//                     }).toList(),
//                     onChanged: (value) {
//                       setState(() {
//                         selectedGroup = value;
//                       });
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   TextField(
//                     controller: nameController,
//                     decoration: const InputDecoration(
//                       labelText: "نام",
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   TextField(
//                     controller: lastNameController,
//                     decoration: const InputDecoration(
//                       labelText: "نام خانوادگی",
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   TextField(
//                     controller: phoneController,
//                     decoration: const InputDecoration(
//                       labelText: "شماره موبایل",
//                       border: OutlineInputBorder(),
//                     ),
//                     keyboardType: TextInputType.phone,
//                     inputFormatters: [
//                       FilteringTextInputFormatter.digitsOnly,
//                       LengthLimitingTextInputFormatter(11),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   DropdownButtonFormField<String>(
//                     decoration: const InputDecoration(
//                       labelText: "جنسیت",
//                       border: OutlineInputBorder(),
//                     ),
//                     value: selectedGender,
//                     items: const [
//                       DropdownMenuItem(value: "مرد", child: Text("مرد")),
//                       DropdownMenuItem(value: "زن", child: Text("زن")),
//                     ],
//                     onChanged: (value) {
//                       setState(() {
//                         selectedGender = value;
//                       });
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   DropdownButtonFormField<String>(
//                     decoration: const InputDecoration(
//                       labelText: "انتخاب سیم کارت",
//                       border: OutlineInputBorder(),
//                     ),
//                     value: selectedSimCard,
//                     items: const [
//                       DropdownMenuItem(value: "سیم کارت اول", child: Text("سیم کارت اول")),
//                       DropdownMenuItem(value: "سیم کارت دوم", child: Text("سیم کارت دوم")),
//                     ],
//                     onChanged: (value) {
//                       setState(() {
//                         selectedSimCard = value;
//                       });
//                     },
//                   ),
//                   const SizedBox(height: 24),
//                   ElevatedButton(
//                     onPressed: _submitForm,
//                     child: const Text("ثبت و ارسال پیامک"),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../controllers/home_controller.dart';
// import '../models/group_model.dart';
// import 'package:telephony/telephony.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:sim_card_info/sim_card_info.dart';
// import 'package:sim_card_info/sim_info.dart';
//
// class HomePage extends StatefulWidget {
//   HomePage({super.key});
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   final HomeController _controller = HomeController();
//   String? selectedGroup;
//   String? selectedGender;
//   String? selectedSimCard;
//   List<GroupModel> groups = [];
//   List<SimInfo>? _simInfo;
//   bool isSimInfoSupported = true;
//
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController lastNameController = TextEditingController();
//   final TextEditingController phoneController = TextEditingController();
//
//   late Future<List<GroupModel>> _groupsFuture;
//
//   final Telephony telephony = Telephony.instance;
//
//   // متنی که می‌خواهیم ارسال کنیم
//   String message = "سلام.\nخوبی؟\nدلم برات تنگ شده خیلی";
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeTokenAndFetchGroups();
//     _initializeSimInfo();
//   }
//
//   Future<void> _initializeSimInfo() async {
//     await Permission.phone.request();
//     try {
//       _simInfo = await SimCardInfo().getSimInfo();
//     } on PlatformException {
//       setState(() {
//         isSimInfoSupported = false;
//       });
//     }
//     if (!mounted) return;
//     setState(() {});
//   }
//
//   Future<void> _initializeTokenAndFetchGroups() async {
//     final prefs = await SharedPreferences.getInstance();
//     final authToken = prefs.getString('auth_token');
//     await _controller.setAuthToken(authToken ?? "");
//
//     setState(() {
//       _groupsFuture = _fetchGroups();
//     });
//   }
//
//   Future<List<GroupModel>> _fetchGroups() async {
//     try {
//       final fetchedGroups = await _controller.fetchGroups();
//       setState(() {
//         groups = fetchedGroups;
//       });
//       return fetchedGroups;
//     } catch (e) {
//       return [];
//     }
//   }
//
//   // تابع ارسال پیامک با استفاده از سیم‌کارت انتخابی
//   void _sendSMS(String message, String phoneNumber) async {
//     bool? permissionsGranted = await telephony.requestSmsPermissions;
//     if (permissionsGranted ?? false) {
//       int? slotIndex = _simInfo?.firstWhere((sim) => sim.displayName == selectedSimCard)?.slotIndex;
//       telephony.sendSms(
//         to: phoneNumber,
//         message: message,
//         simSlot: slotIndex,
//       );
//     } else {
//       print("Permissions not granted");
//     }
//   }
//
//   void _submitForm() async {
//     if (nameController.text.isNotEmpty &&
//         lastNameController.text.isNotEmpty &&
//         phoneController.text.isNotEmpty &&
//         selectedGroup != null &&
//         selectedGender != null &&
//         selectedSimCard != null) {
//
//       final selectedGroupId = groups.firstWhere((group) => group.name == selectedGroup).id;
//       final contact = await _controller.addContact(
//         firstName: nameController.text,
//         lastName: lastNameController.text,
//         phoneNumber: phoneController.text,
//         gender: selectedGender!,
//         groupId: selectedGroupId,
//       );
//
//       if (contact != null) {
//         if (mounted) {
//           showDialog(
//             context: context,
//             builder: (context) => AlertDialog(
//               title: const Text("موفق"),
//               content: const Text("کاربر با موفقیت اضافه شد."),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                   child: const Text("باشه"),
//                 ),
//               ],
//             ),
//           );
//         }
//
//         String phoneNumber = phoneController.text.trim();
//         if (phoneNumber.length == 11) {
//           _sendSMS(message, phoneNumber);
//         } else {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text("لطفا یک شماره موبایل معتبر وارد کنید."),
//               ),
//             );
//           }
//         }
//       } else {
//         showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const Text("خطا"),
//             content: const Text("مشکلی در اضافه کردن کاربر پیش آمد."),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: const Text("باشه"),
//               ),
//             ],
//           ),
//         );
//       }
//     } else {
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text("خطا"),
//           content: const Text("لطفا همه فیلدها را پر کنید."),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text("باشه"),
//             ),
//           ],
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Home Page"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: FutureBuilder<List<GroupModel>>(
//           future: _groupsFuture,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             } else if (snapshot.hasError) {
//               return Center(child: Text("Error: ${snapshot.error}"));
//             } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//               return const Center(child: Text("No groups available"));
//             }
//
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 if (isSimInfoSupported && _simInfo != null)
//                   DropdownButtonFormField<String>(
//                     decoration: const InputDecoration(
//                       labelText: "انتخاب سیم‌کارت",
//                       border: OutlineInputBorder(),
//                     ),
//                     value: selectedSimCard,
//                     items: _simInfo!.map((sim) {
//                       return DropdownMenuItem(
//                         value: sim.displayName,
//                         child: Text("سیم‌کارت ${sim.slotIndex + 1}: ${sim.carrierName}"),
//                       );
//                     }).toList(),
//                     onChanged: (value) {
//                       setState(() {
//                         selectedSimCard = value;
//                       });
//                     },
//                   ),
//                 const SizedBox(height: 16),
//                 DropdownButtonFormField<String>(
//                   decoration: const InputDecoration(
//                     labelText: "انتخاب گروه",
//                     border: OutlineInputBorder(),
//                   ),
//                   value: selectedGroup,
//                   items: snapshot.data!.map((group) {
//                     return DropdownMenuItem(
//                       value: group.name,
//                       child: Text(group.name),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       selectedGroup = value;
//                     });
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: nameController,
//                   decoration: const InputDecoration(
//                     labelText: "نام",
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: lastNameController,
//                   decoration: const InputDecoration(
//                     labelText: "نام خانوادگی",
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: phoneController,
//                   decoration: const InputDecoration(
//                     labelText: "شماره موبایل",
//                     border: OutlineInputBorder(),
//                   ),
//                   keyboardType: TextInputType.phone,
//                   inputFormatters: [
//                     FilteringTextInputFormatter.digitsOnly,
//                     LengthLimitingTextInputFormatter(11),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 DropdownButtonFormField<String>(
//                   decoration: const InputDecoration(
//                     labelText: "جنسیت",
//                     border: OutlineInputBorder(),
//                   ),
//                   value: selectedGender,
//                   items: const [
//                     DropdownMenuItem(value: "مرد", child: Text("مرد")),
//                     DropdownMenuItem(value: "زن", child: Text("زن")),
//                   ],
//                   onChanged: (value) {
//                     setState(() {
//                       selectedGender = value;
//                     });
//                   },
//                 ),
//                 const SizedBox(height: 24),
//                 ElevatedButton(
//                   onPressed: _submitForm,
//                   child: const Text("ثبت و ارسال پیامک"),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
