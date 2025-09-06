import 'dart:io';

import 'package:fit_gym/main.dart';
import 'package:fit_gym/member_details.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'about_page.dart';
import 'add_player_page.dart';
import 'member.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final memberSearchController = TextEditingController();

  @override
  void dispose() {
    memberSearchController.dispose();
    super.dispose();
  }

  var _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final memberList = memberBox.values.toList().obs;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _pageIndex == 0
          ? AppBar(
              centerTitle: true,
              title: const Text('FIT GYM'),
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
                const SizedBox.shrink(),
                SizedBox(
                  width: 340,
                  child: TextField(
                    controller: memberSearchController,
                    autocorrect: true,
                    decoration: InputDecoration(
                      hintText: 'nameOfMember'.tr,
                      suffixIcon: const Icon(Icons.search),
                      suffixIconColor: Colors.black.withValues(alpha: 0.6),
                    ),
                    onTapOutside: (event) => FocusScope.of(context).unfocus(),
                    onChanged: (value) => memberList.assignAll(memberBox.values.where((member) => member.name.contains(value))),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    height: 300,
                    child: memberList.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Obx(
                              () => GridView.count(
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
                              ),
                            ),
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
                    image: FileImage(File(member.profileImageURL)),
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
