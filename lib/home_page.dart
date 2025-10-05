import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:downloadsfolder/downloadsfolder.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fit_gym/main.dart';
import 'package:fit_gym/member_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'about_page.dart';
import 'add_player_page.dart';
import 'member.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var pageIndex = 0;
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

  final filteredName = memberBox.values.toSet().obs;
  final filteredPhoneNumber = memberBox.values.toSet().obs;
  final filteredYMembers = memberBox.values.toSet().obs;
  final filteredRMembers = memberBox.values.toSet().obs;

  final filteredY = false.obs;
  final filteredR = false.obs;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: pageIndex == 0
          ? AppBar(
              title: const Text('FIT GYM'),
              centerTitle: true,
              actions: [
                TextButton(
                  onPressed: () async {
                    final importFile = await FilePicker.platform.pickFiles();

                    if (importFile != null) {
                      // if (!importFile.files.single.path!.split('/').last.startsWith(boxName)) {
                      //   Get.snackbar(
                      //     'fileIsNotTrue'.tr,
                      //     'endsWithHive'.tr,
                      //     backgroundColor: Colors.red.withValues(alpha: 0.5),
                      //     colorText: Colors.white,
                      //     icon: const Icon(Icons.close, color: Colors.white),
                      //   );
                      //   return;
                      // }
                      File file = File(importFile.files.single.path!);
                      if (await file.exists()) {
                        await memberBox.close();
                        final dir = await getApplicationDocumentsDirectory();
                        final hiveFile = File('${dir.path}/$boxName.hive');
                        await file.copy(hiveFile.path);
                        memberBox = await Hive.openBox<Member>(boxName);
                        filteredName.assignAll(memberBox.values.sortedByDescending((memebr) => memebr.startDate).toSet().obs);
                        filteredPhoneNumber
                            .assignAll(memberBox.values.sortedByDescending((memebr) => memebr.startDate).toSet().obs);
                        filteredYMembers.assignAll(memberBox.values.sortedByDescending((memebr) => memebr.startDate).toSet().obs);
                        filteredRMembers.assignAll(memberBox.values.sortedByDescending((memebr) => memebr.startDate).toSet().obs);
                        memberList.assignAll(memberBox.values.toList());
                        filteredY.value = false;
                        filteredR.value = false;
                        memberSearchByNameController.text = '';
                        memberSearchByPhoneNumberController.text = '';
                        Get.snackbar(
                          'operationSucceeded'.tr,
                          'fileIsSelected'.tr,
                          backgroundColor: Colors.blue.withValues(alpha: 0.5),
                          colorText: Colors.white,
                          icon: const Icon(Icons.check_circle, color: Colors.white),
                        );
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
              leading: IconButton(
                onPressed: () {
                  Get.changeThemeMode(isDark.value ? ThemeMode.light : ThemeMode.dark);
                  isDark.value = !isDark.value;
                },
                icon: Obx(() => isDark.value ? const Icon(Icons.light_mode) : const Icon(Icons.dark_mode)),
              ),
            )
          : null,
      body: IndexedStack(
        index: pageIndex,
        children: [
          SizedBox(
            width: Get.width,
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
                        decoration: InputDecoration(
                          hintText: 'nameOfMember'.tr,
                          suffixIcon: const Icon(Icons.search),
                        ),
                        onTapOutside: (event) => FocusScope.of(context).unfocus(),
                        onChanged: (value) {
                          filteredName.assignAll(memberBox.values
                              .sortedByDescending((memebr) => memebr.startDate)
                              .where((member) => member.name
                                  .startsWith(value.trim().split(' ').where((element) => element.isNotEmpty).join(' ')))
                              .toList());
                          memberList.assignAll(
                            filteredName
                                .intersection(filteredPhoneNumber)
                                .intersection(filteredRMembers)
                                .intersection(filteredYMembers),
                          );
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
                          filteredPhoneNumber.assignAll(memberBox.values
                              .sortedByDescending((memebr) => memebr.startDate)
                              .where((member) => member.phoneNumber.startsWith(value))
                              .toList());
                          memberList.assignAll(filteredName
                              .intersection(filteredPhoneNumber)
                              .intersection(filteredRMembers)
                              .intersection(filteredYMembers));
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
                                  filteredR.value = false;
                                  filteredRMembers.assignAll(memberBox.values.sortedByDescending((memebr) => memebr.startDate));
                                  filteredYMembers.assignAll(
                                    filteredY.value
                                        ? memberBox.values.sortedByDescending((memebr) => memebr.startDate)
                                        : memberBox.values.sortedByDescending((memebr) => memebr.startDate).where(
                                              (member) => member.getRemainingTime() >= 0 && member.getRemainingTime() < 3,
                                            ),
                                  );
                                  filteredY.value = !filteredY.value;
                                  memberList.assignAll(filteredName
                                      .intersection(filteredPhoneNumber)
                                      .intersection(filteredRMembers)
                                      .intersection(filteredYMembers));
                                },
                                child: Text('soon'.tr),
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
                                  filteredY.value = false;
                                  filteredYMembers.assignAll(memberBox.values.sortedByDescending((memebr) => memebr.startDate));
                                  filteredRMembers.assignAll(
                                    filteredR.value
                                        ? memberBox.values.sortedByDescending((memebr) => memebr.startDate)
                                        : memberBox.values
                                            .sortedByDescending((memebr) => memebr.startDate)
                                            .where((member) => member.getRemainingTime() < 0),
                                  );
                                  filteredR.value = !filteredR.value;
                                  memberList.assignAll(filteredName
                                      .intersection(filteredPhoneNumber)
                                      .intersection(filteredRMembers)
                                      .intersection(filteredYMembers));
                                },
                                child: Text('expired'.tr),
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
                          final dir = await getApplicationDocumentsDirectory();
                          final hiveFile = File('${dir.path}/$boxName.hive');
                          if (await hiveFile.exists()) {
                            try {
                              bool? success = await copyFileIntoDownloadFolder(hiveFile.path, '$boxName.hive');
                              if (success == true) {
                                Get.snackbar(
                                  'fileDownloaded'.tr,
                                  'newFilePath'.tr,
                                  backgroundColor: Colors.blue.withValues(alpha: 0.5),
                                  colorText: Colors.white,
                                  icon: const Icon(Icons.check_circle, color: Colors.white),
                                );
                              }
                            } catch (e) {
                              print('Failed to retrieve downloads folder path $e');
                            }
                          }
                        },
                        child: Text('backup'.tr),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Obx(
                    () {
                      final members = memberList.sortedByDescending((member) => member.startDate);
                      return memberList.isNotEmpty
                          ? GridView.builder(
                              cacheExtent: Get.width * 2,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                              itemCount: members.length,
                              itemBuilder: (_, i) => InkWell(
                                onTap: () => Get.to(() => const MemberDetails(), arguments: members[i]),
                                borderRadius: BorderRadius.circular(12),
                                child: MemberCard(member: members[i]),
                              ),
                            )
                          : Text('noMatchedPlayer'.tr);
                    },
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
          pageIndex = index;
        }),
        elevation: 0,
        currentIndex: pageIndex,
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
          width: Get.width / 2,
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
