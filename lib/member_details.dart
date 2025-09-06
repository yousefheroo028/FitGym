import 'dart:io';

import 'package:fit_gym/home_page.dart';
import 'package:fit_gym/member.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MemberDetails extends StatelessWidget {
  const MemberDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final Member member = Get.arguments;
    var startDate = member.startDate.obs;
    var endDate = member.endDate.obs;

    return Scaffold(
      appBar: AppBar(
        title: Text(member.name),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            spacing: 8.0,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: FileImage(File(member.profileImageURL)),
                    fit: BoxFit.contain,
                  ),
                  border: Border.all(color: Colors.blue, width: 1),
                ),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'personalInfo'.tr,
                    style: TextStyle(color: Colors.black.withValues(alpha: 0.3)),
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
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                'phoneNumberOfPlayer'.trParams(
                  {
                    "phoneNumber": member.phoneNumber,
                  },
                ),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'subscriptionInfo'.tr,
                    style: TextStyle(color: Colors.black.withValues(alpha: 0.3)),
                  ),
                ],
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
                child: Wrap(
                  spacing: 16.0,
                  runSpacing: 8.0,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        await member.delete();
                        Get.off(const HomePage());
                      },
                      label: Text('deleteMember'.tr),
                      icon: const Icon(Icons.delete_outline),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        member.startDate = DateTime.now();
                        member.endDate = member.startDate.add(const Duration(days: 30));
                        startDate.value = member.startDate;
                        endDate.value = member.endDate;
                        await member.save();
                        Get.snackbar(
                          'renewSucceded'.tr,
                          ' ',
                        );
                      },
                      label: Text('renewMember'.tr),
                      icon: const Icon(Icons.autorenew),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
