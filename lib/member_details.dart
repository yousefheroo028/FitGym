import 'package:fit_gym/image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final member = Rx<Member>(memberBox.get(Get.arguments)!);

  @override
  Widget build(BuildContext context) {
    final remainingDays = member.value.getRemainingTime().obs;
    final startDate = member.value.startDate.obs;
    final endDate = member.value.endDate.obs;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Obx(() => Text(member.value.name)),
        actions: [
          IconButton(
            onPressed: () async {
              member.value = await Get.to(() => const AddPlayerPage(), arguments: member.value.phoneNumber);
            },
            icon: const Icon(Icons.edit),
          ),
        ],
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            spacing: 8.0,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => Get.to(() => const ImageViewer(), arguments: member.value.phoneNumber),
                child: Obx(() => Hero(
                      tag: member.value.phoneNumber,
                      child: Container(
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: member.value.profileImageMetadata != null
                                ? MemoryImage(member.value.profileImageMetadata!)
                                : const AssetImage('assets/icon/placeholder.jpeg'),
                            fit: BoxFit.contain,
                          ),
                          border: Border.all(color: Colors.teal.shade400, width: 1),
                        ),
                      ),
                    )),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text('personalInfo'.tr)],
              ),
              Obx(
                () => Text(
                  'nameOfPlayer'.trParams(
                    {
                      "name": member.value.name,
                    },
                  ),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                children: [
                  InkWell(
                    onLongPress: copyPhoneNumber,
                    child: Text(
                      'phoneNumberOfPlayer'.trParams({"phoneNumber": member.value.phoneNumber}),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (isValidPhoneNumber(member.value.phoneNumber)) const Spacer(),
                  if (isValidPhoneNumber(member.value.phoneNumber))
                    IconButton(
                      onPressed: () => launchUrl(
                        mode: LaunchMode.externalApplication,
                        Uri.parse('https://wa.me/+2${member.value.phoneNumber}'),
                      ),
                      icon: const Icon(FontAwesomeIcons.whatsapp),
                    ),
                  if (isValidPhoneNumber(member.value.phoneNumber))
                    IconButton(
                      onPressed: () => launchUrl(
                        mode: LaunchMode.externalApplication,
                        Uri.parse('https://t.me/+2${member.value.phoneNumber}'),
                      ),
                      icon: const Icon(FontAwesomeIcons.telegram),
                    ),
                  if (isValidPhoneNumber(member.value.phoneNumber))
                    IconButton(
                      onPressed: () => launchUrl(
                          mode: LaunchMode.externalApplication, Uri(scheme: 'tel', path: '+2${member.value.phoneNumber}')),
                      icon: const Icon(FontAwesomeIcons.phone),
                    ),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text('subscriptionInfo'.tr)],
              ),
              Obx(
                () => Text(
                  'startDateOfPlayer'.trParams(
                    {
                      "date": '${startDate.value.year} / ${startDate.value.month} / ${startDate.value.day}',
                    },
                  ),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Obx(
                () => Text(
                  'endDateOfPlayer'.trParams(
                    {
                      "date": '${endDate.value.year} / ${endDate.value.month} / ${endDate.value.day}',
                    },
                  ),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
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
              Obx(
                () => Text(
                  'subscriptionBudget'.trParams(
                    {
                      "price": '${member.value.subscriptionBudget}',
                    },
                  ),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(),
              SizedBox(
                width: Get.width,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await member.value.delete();
                    updateDatabase();
                    Get.back(result: member.value);
                  },
                  label: Text('deleteMember'.tr),
                  icon: const Icon(Icons.delete_outline),
                ),
              ),
            ],
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

  void copyPhoneNumber() => Clipboard.setData(ClipboardData(text: member.value.phoneNumber)).then(
        (value) => viewSnackBar(
          'copied'.trParams(
            {
              "name": member.value.name,
            },
          ),
          'numberCopied'.trParams(
            {
              "name": member.value.phoneNumber,
            },
          ),
          true,
        ),
      );
}
