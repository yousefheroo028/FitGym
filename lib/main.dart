import 'dart:async';

import 'package:dartx/dartx.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fit_gym/languages/langs.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart' hide Intent;
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:url_launcher/url_launcher.dart';

import 'home_page.dart';
import 'member.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHive();
  bool allowed = await checkIfAllowed();
  runApp(
    allowed
        ? const MyApp()
        : const GetMaterialApp(
            home: NotAllowedPage(),
            debugShowCheckedModeBanner: false,
          ),
  );
}

late final String deviceId;
late Box<Member> memberBox;

const boxName = 'members_new';
Future<void> initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(MemberAdapter());
  memberBox = await Hive.openBox(boxName);
}

final memberList = memberBox.values.sortedByDescending((member) => member.startDate).toList().obs;

void updateDatabase() {
  memberList.assignAll(memberBox.values.sortedByDescending((member) => member.startDate).toList());
}

Future<bool> checkIfAllowed() async {
  final deviceInfo = DeviceInfoPlugin();
  final androidInfo = await deviceInfo.androidInfo;
  deviceId = androidInfo.id;

  const allowedDevices = [
    'RKQ1.201217.002',
    'TP1A.220624.014',
    'AE3A.240806.036',
    'TP1A.220624.014',
    'HONORBRC-N21',
    'AP3A.240905.015.A2_VOOOL1',
  ];

  return allowedDevices.contains(deviceId);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal.shade400,
          brightness: Brightness.light,
        ),
        fontFamily: 'Tajawal',
        fontFamilyFallback: const ['Tajawal'],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: 'Tajawal',
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal.shade400,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
          ),
        ),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          elevation: 10,
          selectedItemColor: Colors.teal.shade400,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
        ),
        dividerTheme: DividerThemeData(
          color: Colors.teal.shade200,
          thickness: 1,
          space: 20,
          indent: 16,
          endIndent: 16,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.teal.shade400, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          labelStyle: TextStyle(color: Colors.teal.shade400),
          hintStyle: TextStyle(color: Colors.grey[600]),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal.shade300,
          brightness: Brightness.dark,
        ),
        fontFamilyFallback: const ['Tajawal'],
        fontFamily: 'Tajawal',
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey.shade900,
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Tajawal',
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal.shade300,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
          ),
        ),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
          elevation: 10,
          selectedItemColor: Colors.teal.shade300,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
        ),
        dividerTheme: DividerThemeData(
          color: Colors.teal.shade200,
          thickness: 1,
          space: 20,
          indent: 16,
          endIndent: 16,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade900,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.teal.shade300, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade700, width: 1),
          ),
          labelStyle: TextStyle(color: Colors.teal.shade200),
          hintStyle: TextStyle(color: Colors.grey[400]),
        ),
      ),
      translations: Languages(),
      locale: const Locale('ar', 'AE'),
      themeMode: ThemeMode.system,
      fallbackLocale: const Locale('ar', 'AE'),
    );
  }
}

class NotAllowedPage extends StatelessWidget {
  const NotAllowedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: InkWell(
            onTap: () => Clipboard.setData(ClipboardData(text: deviceId)).then(
                  (value) => viewSnackBar(
                    'سيتم إضافتك في السيستم بعد قليل',
                    'استنى شوية',
                    true,
                  ),
                ),
            child: Text(deviceId)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: Colors.red.withValues(alpha: 0.2),
              ),
            ),
            color: colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.block,
                    size: 80,
                    color: colorScheme.onErrorContainer,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "غير مسموح لك باستخدام التطبيق",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "أنت غير مشترك في هذا البرنامج. برجاء التواصل مع الدعم الفني.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onErrorContainer.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          await launchUrl(Uri(scheme: 'tel', path: '01140169448'));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.onErrorContainer,
                          foregroundColor: colorScheme.errorContainer,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.phone),
                        label: const Text("اتصل"),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await launchUrl(Uri.parse('https://wa.me/+201140169448/'));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.onErrorContainer,
                          foregroundColor: colorScheme.errorContainer,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const FaIcon(FontAwesomeIcons.whatsapp),
                        label: const Text("واتس"),
                      ),
                    ],
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

void viewSnackBar(String title, String message, bool isSuccess) {
  Get.snackbar(
    title,
    message,
    backgroundColor: isSuccess ? Colors.blue.withValues(alpha: 0.5) : Colors.red.withValues(alpha: 0.5),
    colorText: Colors.white,
    borderRadius: 12,
    margin: const EdgeInsets.all(12),
    icon: Icon(isSuccess ? Icons.check_circle : Icons.close, color: Colors.white),
  );
}
