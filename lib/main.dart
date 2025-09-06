import 'package:fit_gym/languages/langs.dart';
import 'package:fit_gym/member.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:url_launcher/url_launcher.dart';

import 'home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await inittHive();
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
late final Box<Member> memberBox;

Future<void> inittHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(MemberAdapter());
  memberBox = await Hive.openBox<Member>('members');
}

Future<bool> checkIfAllowed() async {
  final deviceInfo = DeviceInfoPlugin();
  final androidInfo = await deviceInfo.androidInfo;
  deviceId = androidInfo.id;

  const allowedDevices = [
    'RKQ1.201217.002',
    'TP1A.220624.014',
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
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.cairoTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.blueAccent.withValues(alpha: 0.1),
          elevation: 0,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          elevation: 10,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 12,
          ),
          showUnselectedLabels: true,
          // يظهر النص حتى لو مش مختار
          type: BottomNavigationBarType.fixed, // يثبت الأيقونات
        ),
        dividerTheme: DividerThemeData(
          color: Colors.blueAccent.withValues(alpha: 0.3),
          // لون الخط
          thickness: 1,
          // السمك
          space: 20,
          // مسافة قبل وبعد
          indent: 16,
          // بداية المسافة من الشمال
          endIndent: 16, // نهاية المسافة من اليمين
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none, // بدون خط
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3), width: 1),
          ),
          labelStyle: const TextStyle(color: Colors.blue),
          hintStyle: TextStyle(color: Colors.grey[500]),
        ),
      ),
      translations: Languages(),
      locale: const Locale('ar', 'AE'),
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
