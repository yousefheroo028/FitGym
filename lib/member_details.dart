import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:fit_gym/home_page.dart';
import 'package:fit_gym/member.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'add_player_page.dart';
import 'main.dart';

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
        leading: IconButton(
          onPressed: () => Get.to(AddPlayerPage(), arguments: member),
          icon: const Icon(Icons.edit),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              spacing: 8.0,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: member.phoneNumber,
                  child: Container(
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
                  onLongPress: () => Clipboard.setData(ClipboardData(text: member.phoneNumber)).then(
                    (value) => Get.snackbar(
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
                    onPressed: () {
                      member.delete();
                      updateDatabase();
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
                    Obx(
                      () => Expanded(
                        flex: 3,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            remainingDays.value = member.renew(months: months.value);
                            startDate.value = member.startDate;
                            endDate.value = member.endDate;
                            await member.save();
                            updateDatabase();
                            Get.snackbar(
                              'renewSucceded'.tr,
                              'renewMonths'.trParams(
                                {
                                  "months": months.value == 1 || months.value > 10
                                      ? '${months.value > 2 ? '${months.value} ' : ''}شهر'
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
                            foregroundColor: WidgetStatePropertyAll(remainingDays.value < 3 ? Colors.red : Colors.white),
                          ),
                          label: Text('renewMember'.tr),
                          icon: const Icon(Icons.autorenew),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        keyboardType: TextInputType.number,
                        onTapOutside: (event) => FocusScope.of(context).unfocus(),
                        decoration: InputDecoration(
                          label: Text(
                            'عدد شهور التجديد',
                            style: TextStyle(
                              fontSize: 13,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            if (value.toInt() != 0) {
                              months.value = int.parse(value);
                            } else {
                              months.value = 1;
                            }
                          } else {
                            months.value = 1;
                          }
                        },
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
                            updateDatabase();
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
                            updateDatabase();
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

  String dayText(int count) {
    if (count == 0) return "يوم";
    if (count == 1) return "يومين";
    if (count >= 2 && count <= 9) return "${count + 1} أيام";
    return "${count + 1} يومًا";
  }
}
//
// class EditableFieldEnabled extends StatefulWidget {
//   final String initialValue;
//   final Function(String) onChanged;
//   final String title;
//
//   const EditableFieldEnabled({super.key, required this.initialValue, required this.onChanged, required this.title});
//
//   @override
//   State<EditableFieldEnabled> createState() => _EditableFieldEnabledState();
// }
//
// class _EditableFieldEnabledState extends State<EditableFieldEnabled> {
//   final TextEditingController controller = TextEditingController();
//   bool isEditable = false;
//
//   @override
//   Widget build(BuildContext context) {
//     controller.text = widget.initialValue;
//
//     return GestureDetector(
//       onLongPress: enable,
//       child: Row(
//         children: [
//           Text(widget.title),
//           Expanded(
//             child: TextFormField(
//               controller: controller,
//               enabled: isEditable,
//               autofocus: isEditable,
//               // style: TextStyle(color: Colors.black),
//               decoration: InputDecoration(
//                 enabled: isEditable,
//                 fillColor: Colors.transparent,
//               ),
//               onTapOutside: (event) {
//                 isEditable = false;
//                 setState(() {});
//               },
//               onFieldSubmitted: (newName) {
//                 isEditable = false;
//                 widget.onChanged(newName);
//                 setState(() {});
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void enable() {
//     isEditable = true;
//     setState(() {});
//   }
// }
