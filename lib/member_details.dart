import 'package:fit_gym/home_page.dart';
import 'package:fit_gym/image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'add_player_page.dart';
import 'main.dart';
import 'member.dart';

class MemberDetails extends StatefulWidget {
  const MemberDetails({super.key});

  @override
  State<MemberDetails> createState() => _MemberDetailsState();
}

class _MemberDetailsState extends State<MemberDetails> {
  final months = 1.obs;
  Member member = Get.arguments;
  @override
  Widget build(BuildContext context) {
    final remainingDays = member.getRemainingTime().obs;
    final startDate = member.startDate.obs;
    final endDate = member.endDate.obs;

    return Scaffold(
      appBar: AppBar(
        title: Text(member.name),
        actions: [
          IconButton(
            onPressed: () async {
              member = await Get.to(() => const AddPlayerPage(), arguments: member);
              setState(() {});
            },
            icon: const Icon(Icons.edit),
          ),
        ],
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              spacing: 8.0,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => Get.to(() => const ImageViewer(), arguments: member),
                  child: Hero(
                    tag: member.phoneNumber,
                    child: Container(
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: member.profileImageMetadata != null
                              ? MemoryImage(member.profileImageMetadata!)
                              : const AssetImage('assets/icon/placeholder.jpeg'),
                          fit: BoxFit.contain,
                        ),
                        border: Border.all(color: Colors.teal.shade400, width: 1),
                      ),
                    ),
                  ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'personalInfo'.tr,
                    ),
                  ],
                ),
                Text(
                  'nameOfPlayer'.trParams(
                    {
                      "name": member.name,
                    },
                  ),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                InkWell(
                  onLongPress: copyPhoneNumber,
                  child: Text(
                    'phoneNumberOfPlayer'.trParams(
                      {
                        "phoneNumber": member.phoneNumber,
                      },
                    ),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'subscriptionInfo'.tr,
                    ),
                  ],
                ),
                Obx(() {
                  return Text(
                    'startDateOfPlayer'.trParams(
                      {
                        "date": '${startDate.value.year} / ${startDate.value.month} / ${startDate.value.day}',
                      },
                    ),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  );
                }),
                Obx(() {
                  return Text(
                    'endDateOfPlayer'.trParams(
                      {
                        "date": '${endDate.value.year} / ${endDate.value.month} / ${endDate.value.day}',
                      },
                    ),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  );
                }),
                Obx(
                  () => Text(
                    remainingDays.value >= 0
                        ? 'daysLeft'.trParams(
                            {
                              "days": dayText(remainingDays.value),
                            },
                          )
                        : 'الاشتراك خلص',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  'subscriptionBudget'.trParams(
                    {
                      "price": '${member.subscriptionBudget}',
                    },
                  ),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                SizedBox(
                  width: context.width,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await member.delete();
                      updateDatabase();
                      Get.offAll(() => const HomePage());
                    },
                    label: Text('deleteMember'.tr),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String dayText(int count) {
    if (count == 0) return "يوم";
    if (count == 1) return "يومين";
    if (count >= 2 && count <= 9) return "${count + 1} أيام";
    return "${count + 1} يومًا";
  }

  void copyPhoneNumber() => Clipboard.setData(ClipboardData(text: member.phoneNumber)).then(
        (value) => viewSnackBar(
          'copied'.trParams(
            {
              "name": member.name,
            },
          ),
          'numberCopied'.trParams(
            {
              "name": member.phoneNumber,
            },
          ),
          true,
        ),
      );
}
