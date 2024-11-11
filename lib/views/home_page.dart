import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/home_controller.dart';
import '../models/group_model.dart';
import 'package:telephony/telephony.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
  String message = "سلام! به هیئت خیمة الشهدا خوش آمدید.\r\nاین مجموعه با محوریت مسجد و پایگاه موسی بن جعفر (ع) میزبان شماست.\r\n\r\nبرای عضویت در صفحات مجازی ما، از طریق لینک‌های زیر اقدام نمایید:\r\nروبیکا:\r";

  // تابع ارسال پیامک
  void _sendSMS(String message, String phoneNumber) async {
    bool? permissionsGranted = await telephony.requestSmsPermissions;
    if (permissionsGranted ?? false) {
      telephony.sendSms(
        to: phoneNumber,
        message: message,isMultipart: true,
      );
    } else {
      print("Permissions not granted");
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
    await _controller.setAuthToken(authToken??""); // توکن خود را قرار دهید

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
      });
      print("Groups fetched successfully: $fetchedGroups"); // چاپ داده‌های دریافتی
      return fetchedGroups;
    } catch (e) {
      print("Error fetching groups: $e");
      return [];
    }
  }

  void _submitForm() async {
    // بررسی اینکه همه فیلدها پر شده باشند
    if (nameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        selectedGroup != null &&
        selectedGender != null) {

      // پیدا کردن ID گروه از لیست گروه‌ها
      final selectedGroupId = groups.firstWhere((group) => group.name == selectedGroup).id.toString();

      // ارسال داده‌ها به API
      final contact = await _controller.addContact(
        firstName: nameController.text,
        lastName: lastNameController.text,
        phoneNumber: phoneController.text,
        gender: selectedGender!,
        groupId: selectedGroupId,

      );

      if (contact != null) {
        // اگر پاسخ موفق بود، پیام موفقیت نمایش داده شود
        if(mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("موفق"),
              content: const Text("کاربر با موفقیت اضافه شد."),
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

        String phoneNumber = phoneController.text.trim();
        if (phoneNumber.length == 11 && contact.lastMessage != null && contact.lastMessage!.isNotEmpty) {
          _sendSMS(contact.lastMessage!, phoneNumber);
        } else {
          // در صورت اشتباه وارد کردن شماره موبایل
          if(mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("لطفا یک شماره موبایل معتبر وارد کنید."),
              ),
            );
          }

        }
      } else {
        // در صورتی که مشکلی پیش آمد
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<GroupModel>>(
          future: _groupsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No groups available"));
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "انتخاب گروه",
                    border: OutlineInputBorder(),
                  ),
                  value: selectedGroup,
                  items: snapshot.data!.map((group) {
                    return DropdownMenuItem(
                      value: group.name,
                      child: Text(group.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedGroup = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "نام",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(
                    labelText: "نام خانوادگی",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: "شماره موبایل",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // فقط اعداد
                    LengthLimitingTextInputFormatter(11), // حداکثر تعداد کاراکتر 11
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "جنسیت",
                    border: OutlineInputBorder(),
                  ),
                  value: selectedGender,
                  items: const [
                    DropdownMenuItem(value: "مرد", child: Text("مرد")),
                    DropdownMenuItem(value: "زن", child: Text("زن")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedGender = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text("ثبت و ارسال پیامک"),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
