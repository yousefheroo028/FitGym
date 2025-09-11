import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fit_gym/main.dart';
import 'package:fit_gym/member_details.dart';
import 'package:fit_gym/share_handler_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter, LengthLimitingTextInputFormatter;
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
  var _pageIndex = 0;
  final memberSearchByNameController = TextEditingController();
  final memberSearchByPhoneNumberController = TextEditingController();

  @override
  void dispose() {
    memberSearchByNameController.dispose();
    memberSearchByPhoneNumberController.dispose();
    super.dispose();
  }

  final ShareController shareController = Get.find<ShareController>();

  final memberList = memberBox.values.sortedByDescending((element) => element.startDate).toList().obs;

  @override
  Widget build(BuildContext context) {
    memberList.assignAll(memberBox.values.sortedByDescending((element) => element.startDate).toList());
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _pageIndex == 0
          ? AppBar(
              title: const Text('FIT GYM'),
              centerTitle: true,
              actions: [
                TextButton(
                  onPressed: () async {
                    FilePickerResult? importFile = await FilePicker.platform.pickFiles();

                    if (importFile != null) {
                      if (!importFile.files.single.path!.endsWith('.hive')) return;
                      File file = File(importFile.files.single.path!);
                      if (await file.exists()) {
                        await Hive.close();
                        final dir = await getApplicationDocumentsDirectory();
                        final hiveFile = File('${dir.path}/members.hive');
                        await file.copy(hiveFile.path);
                        Get.snackbar(
                          'operationSucceeded'.tr,
                          'fileIsSelected'.tr,
                          backgroundColor: Colors.blue.withValues(alpha: 0.5),
                          colorText: Colors.white,
                          icon: const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                          ),
                        );
                        memberBox = await Hive.openBox('members');
                        memberList.assignAll(memberBox.values.toList());
                        setState(() {});
                      }
                    } else {
                      Get.snackbar(
                        'operationStoped'.tr,
                        'fileIsNotSelected'.tr,
                        backgroundColor: Colors.red.withValues(alpha: 0.5),
                        colorText: Colors.white,
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      );
                    }
                  },
                  child: Text(
                    'import'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final dir = await getApplicationDocumentsDirectory();
                    final hiveFile = File('${dir.path}/members.hive');

                    if (await hiveFile.exists()) {
                      SharePlus.instance.share(
                        ShareParams(
                          files: [
                            XFile('${dir.path}/members.hive'),
                          ],
                        ),
                      );
                    }
                  },
                  child: Text(
                    'export'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
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
                          suffixIconColor: Colors.black.withValues(alpha: 0.6),
                        ),
                        onTapOutside: (event) => FocusScope.of(context).unfocus(),
                        onChanged: (value) => memberList.assignAll(
                          memberBox.values.where(
                            (member) => member.name.toLowerCase().contains(
                                  value.toLowerCase(),
                                ),
                          ),
                        ),
                      ),
                      TextField(
                        controller: memberSearchByPhoneNumberController,
                        autocorrect: true,
                        decoration: InputDecoration(
                          hintText: 'phoneNumberOfMember'.tr,
                          suffixIcon: const Icon(Icons.search),
                          suffixIconColor: Colors.black.withValues(alpha: 0.6),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(11),
                        ],
                        onTapOutside: (event) => FocusScope.of(context).unfocus(),
                        onChanged: (value) => memberList.assignAll(
                          memberBox.values.where(
                            (member) => member.phoneNumber.startsWith(value),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: memberList.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Obx(
                            () {
                              final data = shareController.sharedMedia.value;

                              // if (data == null) {
                              return GridView.count(
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
                              );
                              // }
                              // return Column(
                              //   mainAxisAlignment: MainAxisAlignment.center,
                              //   children: [
                              //     if (data.content != null) Text("Shared Text: ${data.content}"),
                              //     if (data.attachments != null) ...data.attachments!.map((file) => Text("File: ${file?.path}")),
                              //   ],
                              // );
                            },
                          ),
                        )
                      : Text('noMatchedPlayer'.tr),
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
      color: member.getRemainingTime > 3
          ? Colors.grey.withValues(alpha: 0.1)
          : member.getRemainingTime > 0
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
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: member.profileImageURL != null
                        ? FileImage(File(member.profileImageURL!))
                        : AssetImage('assets/icon/placeholder.jpeg'),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(color: Colors.blue, width: 3),
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
