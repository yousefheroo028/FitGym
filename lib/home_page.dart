import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fit_gym/main.dart';
import 'package:fit_gym/member_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_saver/file_saver.dart';

import 'about_page.dart';
import 'add_player_page.dart';
import 'member.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _pageIndex = 0;
  final memberSearchByNameController = TextEditingController();
  final memberSearchByPhoneNumberController = TextEditingController();

  @override
  void dispose() {
    memberSearchByNameController.dispose();
    memberSearchByPhoneNumberController.dispose();
    super.dispose();
  }

  final isNameEmpty = false.obs;
  final isPhoneNumberEmpty = false.obs;

  final isDark = Get.isDarkMode.obs;

  @override
  Widget build(BuildContext context) {
    final filteredY = false.obs;
    final filteredR = false.obs;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _pageIndex == 0
          ? AppBar(
              title: const Text('FIT GYM'),
              centerTitle: true,
              actions: [
                TextButton(
                  onPressed: () async {
                    final importFile = await FilePicker.platform.pickFiles();

                    if (importFile != null) {
                      if (!importFile.files.single.path!.endsWith('.hive')) return;
                      File file = File(importFile.files.single.path!);
                      if (await file.exists()) {
                        await Hive.close();
                        final dir = await getApplicationDocumentsDirectory();
                        final hiveFile = File('${dir.path}/$boxName.hive');
                        final filee = await file.copy(hiveFile.path);
                        print(filee);
                        // await migrateMembers();
                        memberBox = await Hive.openBox<Member>(boxName);
                        updateDatabase();
                        Get.snackbar(
                          'operationSucceeded'.tr,
                          'fileIsSelected'.tr,
                          backgroundColor: Colors.blue.withValues(alpha: 0.5),
                          colorText: Colors.white,
                          icon: const Icon(Icons.check_circle, color: Colors.white),
                        );
                        setState(() {});
                      }
                    }
                  },
                  child: Text('import'.tr, style: const TextStyle(fontSize: 16)),
                ),
                TextButton(
                  onPressed: () async {
                    final dir = await getApplicationDocumentsDirectory();
                    final hiveFile = File('${dir.path}/$boxName.hive');

                    if (await hiveFile.exists()) {
                      SharePlus.instance.share(ShareParams(files: [XFile('${dir.path}/$boxName.hive')]));
                    }
                  },
                  child: Text('export'.tr, style: const TextStyle(fontSize: 16)),
                ),
              ],
              leading: Obx(
                () => IconButton(
                  onPressed: () {
                    Get.changeThemeMode(isDark.value ? ThemeMode.light : ThemeMode.dark);
                    isDark.value = !isDark.value;
                  },
                  icon: Icon(isDark.value ? Icons.light_mode : Icons.dark_mode),
                ),
              ),
            )
          : null,
      body: IndexedStack(
        index: _pageIndex,
        children: [
          SizedBox(
            width: context.width,
            child: Column(
              spacing: 8.0,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    spacing: 8.0,
                    children: [
                      TextField(
                        controller: memberSearchByNameController,
                        autocorrect: true,
                        decoration: InputDecoration(
                          hintText: 'nameOfMember'.tr,
                          suffixIcon: const Icon(Icons.search),
                        ),
                        onTapOutside: (event) => FocusScope.of(context).unfocus(),
                        onChanged: (value) {
                          memberList.assignAll(
                            memberBox.values.where((member) => member.name.toLowerCase().contains(value.toLowerCase())),
                          );
                          isNameEmpty.value = memberList.isEmpty;
                          memberList.sortedByDescending((member) => member.startDate);
                        },
                      ),
                      TextField(
                        controller: memberSearchByPhoneNumberController,
                        autocorrect: true,
                        decoration: InputDecoration(
                          hintText: 'phoneNumberOfMember'.tr,
                          suffixIcon: const Icon(Icons.search),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onTapOutside: (event) => FocusScope.of(context).unfocus(),
                        onChanged: (value) {
                          memberList.assignAll(
                            memberBox.values.where((member) => member.phoneNumber.startsWith(value)),
                          );
                          isPhoneNumberEmpty.value = memberList.isEmpty;
                          memberList.sortedByDescending((member) => member.startDate);
                        },
                      ),
                      Obx(
                        () => Row(
                          spacing: 16.0,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber.shade600.withValues(alpha: filteredY.value ? 0.2 : 1),
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  print(Hive);
                                  memberList.assignAll(
                                    filteredY.value
                                        ? memberBox.values
                                        : memberBox.values.where(
                                            (member) => member.getRemainingTime() >= 0 && member.getRemainingTime() < 3,
                                          ),
                                  );
                                  filteredY.value = !filteredY.value;
                                  filteredR.value = false;
                                },
                                child: Text(
                                  'soon'.tr,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade700.withValues(alpha: filteredR.value ? 0.2 : 1),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  memberList.assignAll(
                                    filteredR.value
                                        ? memberBox.values
                                        : memberBox.values.where(
                                            (member) => member.getRemainingTime() < 0,
                                          ),
                                  );
                                  filteredR.value = !filteredR.value;
                                  filteredY.value = false;
                                },
                                child: Text(
                                  'expired'.tr,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() => Text('numberOfMembers'.trParams({"number": memberList.length.toString()}))),
                      TextButton(
                        style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.all(0.0))),
                        onPressed: () async {
                          if (memberBox.values.isEmpty) {
                            Get.snackbar(
                              'bosIsNotSaved'.tr,
                              'boxIsEmpty'.tr,
                              backgroundColor: Colors.red.withValues(alpha: 0.5),
                              colorText: Colors.white,
                              icon: const Icon(Icons.close, color: Colors.white),
                            );
                            return;
                          }
                          final appDir = await getApplicationDocumentsDirectory();
                          final hiveFile = File('${appDir.path}/$boxName.hive');
                          if (await hiveFile.exists()) {
                            final bytes = await hiveFile.readAsBytes();

                            await FileSaver.instance.saveFile(
                              name: boxName,
                              bytes: bytes,
                              fileExtension: "hive",
                              mimeType: MimeType.other,
                            );
                            Get.snackbar(
                              'fileDownloaded'.tr,
                              'newFilePath'.tr,
                              backgroundColor: Colors.blue.withValues(alpha: 0.5),
                              colorText: Colors.white,
                              icon: const Icon(Icons.check_circle, color: Colors.white),
                            );
                          }
                        },
                        child: Text('backup'.tr),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Obx(
                    () => !isNameEmpty.value && !isPhoneNumberEmpty.value && memberList.isNotEmpty
                        ? GridView.count(
                            crossAxisCount: 2,
                            physics: BouncingScrollPhysics(),
                            children: [
                              for (final member in memberList)
                                InkWell(
                                  onTap: () {
                                    Get.to(() => const MemberDetails(), arguments: member);
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: MemberCard(member: member),
                                ),
                            ],
                          )
                        : Text('noMatchedPlayer'.tr),
                  ),
                ),
              ],
            ),
          ),
          const AddPlayerPage(),
          const AboutPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) => setState(() {
          _pageIndex = index;
        }),
        elevation: 0,
        currentIndex: _pageIndex,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: 'homePage'.tr),
          BottomNavigationBarItem(icon: const Icon(Icons.add), label: 'addNewPlayer'.tr),
          BottomNavigationBarItem(icon: const Icon(Icons.question_mark), label: 'about'.tr),
        ],
      ),
    );
  }
}

class MemberCard extends StatelessWidget {
  const MemberCard({super.key, required this.member});

  final Member member;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: member.getRemainingTime() > 2
          ? Colors.grey.withValues(alpha: 0.1)
          : member.getRemainingTime() >= 0
              ? Colors.orange.withValues(alpha: 0.2)
              : Colors.red.withValues(alpha: 0.2),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: context.width / 2,
          height: 170,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              Hero(
                tag: member.phoneNumber,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: member.profileImageMetadata != null
                          ? MemoryImage(member.profileImageMetadata!)
                          : const AssetImage('assets/icon/placeholder.jpeg'),
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(color: Colors.teal.shade400, width: 3),
                  ),
                ),
              ),
              Text(
                member.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
