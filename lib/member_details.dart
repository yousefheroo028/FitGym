import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:fit_gym/home_page.dart';
import 'package:fit_gym/member.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class MemberDetails extends StatefulWidget {
  const MemberDetails({super.key});

  @override
  State<MemberDetails> createState() => _MemberDetailsState();
}

class _MemberDetailsState extends State<MemberDetails> {
  File? _imageFile;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera, maxHeight: 720, maxWidth: 720);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery, maxHeight: 720, maxWidth: 720);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Member member = Get.arguments;
    final months = 1.obs;

    return Scaffold(
      appBar: AppBar(
        title: Text(member.name),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: SingleChildScrollView(
            child: Column(
              spacing: 8.0,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: member.profileImageURL != null
                          ? FileImage(File(member.profileImageURL!))
                          : const AssetImage('assets/icon/placeholder.jpeg'),
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
                InkWell(
                  onLongPress: () => Clipboard.setData(ClipboardData(text: member.phoneNumber)).then(
                    (value) => Get.snackbar(
                      'copied'.tr,
                      'numberCopied'.trParams(
                        {
                          "name": member.name,
                        },
                      ),
                      backgroundColor: Colors.blue.withValues(alpha: 0.5),
                      colorText: Colors.white,
                      borderRadius: 12,
                      margin: const EdgeInsets.all(12),
                      icon: const Icon(Icons.check_circle, color: Colors.white),
                    ),
                  ),
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
                      style: TextStyle(color: Colors.black.withValues(alpha: 0.3)),
                    ),
                  ],
                ),
                Text(
                  'startDateOfPlayer'.trParams(
                    {
                      "date": '${member.startDate.year} / ${member.startDate.month} / ${member.startDate.day}',
                    },
                  ),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'endDateOfPlayer'.trParams(
                    {
                      "date": '${member.endDate.year} / ${member.endDate.month} / ${member.endDate.day}',
                    },
                  ),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  member.getRemainingTime > 0
                      ? 'daysLeft'.trParams(
                          {
                            "days":
                                '${member.getRemainingTime > 2 ? '${member.getRemainingTime} ' : ''}${member.getRemainingTime > 2 ? member.getRemainingTime > 10 ? 'يوم' : 'أيام' : member.getRemainingTime == 2 ? 'يومين ' : 'يوم'}',
                          },
                        )
                      : 'الاشتراك خلص',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                      Get.offAll(() => const HomePage());
                    },
                    label: Text('deleteMember'.tr),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  spacing: 16.0,
                  children: [
                    Expanded(
                      flex: 3,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          member.startDate = DateTime.now();
                          member.endDate = member.startDate.add(
                            Duration(days: 30 * months.value),
                          );
                          await member.save();
                          setState(() {});
                          Get.snackbar(
                            'renewSucceded'.tr,
                            'renewMonths'.trParams(
                              {
                                "months": months.value == 1
                                    ? 'شهر'
                                    : months.value == 2
                                        ? 'شهرين'
                                        : '${months.value} شهور',
                              },
                            ),
                            backgroundColor: Colors.blue.withValues(alpha: 0.5),
                            colorText: Colors.white,
                            borderRadius: 12,
                            margin: const EdgeInsets.all(12),
                            icon: const Icon(Icons.check_circle, color: Colors.white),
                          );
                        },
                        style: ButtonStyle(
                          foregroundColor: WidgetStatePropertyAll(member.getRemainingTime < 4 ? Colors.red : Colors.white),
                        ),
                        label: Text('renewMember'.tr),
                        icon: const Icon(Icons.autorenew),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          label: Text(
                            'عدد شهور التجديد',
                            style: TextStyle(
                              color: Colors.black.withValues(alpha: 0.3),
                              fontSize: 13,
                            ),
                          ),
                        ),
                        onChanged: (value) => months.value = value.isNotEmpty
                            ? value.toInt() == 0
                                ? 1
                                : value.toInt()
                            : 1,
                      ),
                    ),
                  ],
                ),
                if (member.profileImageURL == null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    spacing: 16.0,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await _pickImageFromGallery();
                            member.profileImageURL = _imageFile?.path;
                            await member.save();
                          },
                          icon: const Icon(Icons.photo_size_select_actual_outlined),
                          label: Text('pickPhoto'.tr),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await _pickImageFromCamera();
                            member.profileImageURL = _imageFile?.path;
                            await member.save();
                          },
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: Text('takePhoto'.tr),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
