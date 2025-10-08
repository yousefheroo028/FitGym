import 'dart:io';
import 'dart:typed_data';

import 'package:dartx/dartx.dart';
import 'package:fit_gym/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'member.dart';

class AddPlayerPage extends StatefulWidget {
  const AddPlayerPage({super.key});

  @override
  State<AddPlayerPage> createState() => _AddPlayerPageState();
}

class _AddPlayerPageState extends State<AddPlayerPage> {
  final nameController = TextEditingController();

  final phoneNumberController = TextEditingController();

  final budgetController = TextEditingController();

  final startDateController = TextEditingController();

  final endDateController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    phoneNumberController.dispose();
    budgetController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }

  final _imageMetadata = Rxn<Uint8List>();

  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera, maxHeight: 480, maxWidth: 480);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = imageFile.path.split('/').last;
      final savedImage = await imageFile.copy('${appDir.path}/$fileName');
      await GallerySaver.saveImage(savedImage.path);
      _imageMetadata.value = await pickedFile.readAsBytes();
    }
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, maxHeight: 480, maxWidth: 480);

    if (pickedFile != null) {
      _imageMetadata.value = await pickedFile.readAsBytes();
    }
  }

  DateTime start = DateTime.now();
  late DateTime end = DateTime(start.year, start.month, start.day + 29);

  final member = Rxn<Member>(Get.arguments != null ? memberBox.get(Get.arguments) : null);

  @override
  void initState() {
    super.initState();
    if (member.value != null) {
      if (member.value!.profileImageMetadata != null) _imageMetadata.value = member.value!.profileImageMetadata!;
      nameController.text = member.value!.name;
      phoneNumberController.text = member.value!.phoneNumber;
      budgetController.text = member.value!.subscriptionBudget.toInt().toString();
      startDateController.text =
          '${member.value!.startDate.day} - ${member.value!.startDate.month} - ${member.value!.startDate.year}';
      endDateController.text = '${member.value!.endDate.day} - ${member.value!.endDate.month} - ${member.value!.endDate.year}';
      start = member.value!.startDate;
      end = member.value!.endDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text(member.value != null ? 'تعديل بيانات ${member.value!.name}' : 'إضافة لاعب جديد'),
      ),
      body: Form(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            spacing: 12.0,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextFormField(
                controller: nameController,
                onTapOutside: (event) => FocusScope.of(context).unfocus(),
                decoration: InputDecoration(
                  hintText: 'enterName'.tr,
                  fillColor: Colors.grey.withValues(alpha: 0.1),
                  suffixIcon: Icon(Icons.text_fields, color: Colors.grey.withValues(alpha: 0.6)),
                ),
              ),
              if (member.value == null)
                TextFormField(
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: const TextInputType.numberWithOptions(),
                  controller: phoneNumberController,
                  onTapOutside: (event) => FocusScope.of(context).unfocus(),
                  decoration: InputDecoration(
                    hintText: 'enterPhone'.tr,
                    fillColor: Colors.grey.withValues(alpha: 0.1),
                    suffixIcon: Icon(
                      Icons.phone,
                      color: Colors.grey.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              TextFormField(
                controller: budgetController,
                onTapOutside: (event) => FocusScope.of(context).unfocus(),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                keyboardType: const TextInputType.numberWithOptions(),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  hintText: 'enterBudget'.tr,
                  fillColor: Colors.grey.withValues(alpha: 0.1),
                  suffixIcon: Icon(
                    Icons.attach_money,
                    color: Colors.grey.withValues(alpha: 0.6),
                  ),
                ),
              ),
              TextFormField(
                onTapOutside: (event) => FocusScope.of(context).unfocus(),
                readOnly: true,
                onTap: () async {
                  await showDatePicker(
                    context: context,
                    firstDate: DateTime(DateTime.now().year - 1, DateTime.now().month, DateTime.now().day),
                    lastDate: DateTime(DateTime.now().year + 1, DateTime.now().month, DateTime.now().day),
                  ).then(
                    (value) {
                      startDateController.text = value != null ? '${value.day} - ${value.month} - ${value.year}' : '';
                      start = value ?? DateTime.now();
                      end = DateTime(start.year, start.month, start.day + 29);
                    },
                  );
                },
                decoration: InputDecoration(
                  labelText: 'enterStartDate'.tr,
                  suffixIcon: const Icon(Icons.date_range),
                ),
                controller: startDateController,
              ),
              TextFormField(
                onTapOutside: (event) => FocusScope.of(context).unfocus(),
                readOnly: true,
                onTap: () async {
                  await showDatePicker(
                    context: context,
                    firstDate: DateTime(DateTime.now().year - 1, DateTime.now().month, DateTime.now().day),
                    lastDate: DateTime(DateTime.now().year + 1, DateTime.now().month, DateTime.now().day),
                  ).then(
                    (value) {
                      endDateController.text = value != null ? '${value.day} - ${value.month} - ${value.year}' : '';
                      end = value ?? DateTime(start.year, start.month, start.day + 29);
                    },
                  );
                },
                decoration: InputDecoration(
                  labelText: 'enterEndDate'.tr,
                  suffixIcon: const Icon(Icons.date_range),
                ),
                controller: endDateController,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                spacing: 16.0,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await _pickImageFromGallery();
                      },
                      icon: const Icon(Icons.photo_size_select_actual_outlined),
                      label: Text('pickPhoto'.tr),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await _pickImageFromCamera();
                      },
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: Text('takePhoto'.tr),
                    ),
                  ),
                ],
              ),
              Obx(
                () => _imageMetadata.value != null
                    ? Column(
                        children: [
                          Image.memory(_imageMetadata.value!, height: 200),
                          IconButton(
                            onPressed: () {
                              _imageMetadata.value = null;
                            },
                            icon: const Icon(Icons.close),
                          )
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
              SizedBox(
                width: Get.width,
                child: member.value != null
                    ? ElevatedButton(
                        onPressed: () async {
                          member.value!.name =
                              nameController.text.trim().split(' ').where((element) => element.isNotEmpty).join(' ');
                          member.value!.startDate = start;
                          member.value!.endDate = end;
                          member.value!.subscriptionBudget = budgetController.text.toDouble();
                          member.value!.profileImageMetadata = _imageMetadata.value;
                          await member.value!.save();
                          updateDatabase();
                          Get.back(result: member.value);
                          viewSnackBar(
                            'memberEdited'.tr,
                            end.date.difference(DateTime.now().date).inDays >= 0
                                ? 'daysLeft'.trParams(
                                    {
                                      "days": dayText(end.date.difference(DateTime.now().date).inDays),
                                    },
                                  )
                                : 'الاشتراك خلصان',
                            true,
                          );
                          member.value = null;
                          nameController.text = '';
                          phoneNumberController.text = '';
                          budgetController.text = '';
                          startDateController.text = '';
                          endDateController.text = '';
                          _imageMetadata.value = null;
                        },
                        child: Text('editPlayer'.tr),
                      )
                    : ElevatedButton(
                        onPressed: () async {
                          if (nameController.text.isEmpty &&
                              phoneNumberController.text.isEmpty &&
                              budgetController.text.isEmpty) {
                            viewSnackBar('completeData'.tr, 'mustFullData'.tr, false);
                            return;
                          }
                          if (memberBox.values.map((member) => member.phoneNumber).contains(phoneNumberController.text)) {
                            viewSnackBar('error'.tr, 'existingOne'.tr, false);
                            return;
                          }
                          if (phoneNumberController.text.length != 11) {
                            viewSnackBar('errorInPhoneNumber'.tr, 'phoneNumberLength'.tr, false);
                            return;
                          }
                          if (!(phoneNumberController.text.startsWith('011') ||
                              phoneNumberController.text.startsWith('012') ||
                              phoneNumberController.text.startsWith('015') ||
                              phoneNumberController.text.startsWith('010'))) {
                            viewSnackBar('errorInPhoneNumber'.tr, 'phoneNumberType'.tr, false);
                            return;
                          }
                          await memberBox.put(
                            phoneNumberController.text,
                            Member(
                              name: nameController.text.trim().split(' ').where((element) => element.isNotEmpty).join(' '),
                              startDate: start,
                              endDate: end,
                              subscriptionBudget: budgetController.text.toDouble(),
                              profileImageMetadata: _imageMetadata.value,
                              phoneNumber: phoneNumberController.text,
                            ),
                          );
                          updateDatabase();
                          viewSnackBar(
                            'memberAdded'.tr,
                            end.date.difference(DateTime.now().date).inDays >= 0
                                ? 'daysLeft'.trParams(
                                    {
                                      "days": dayText(end.date.difference(DateTime.now().date).inDays),
                                    },
                                  )
                                : 'الاشتراك خلصان',
                            true,
                          );
                          nameController.text = '';
                          phoneNumberController.text = '';
                          budgetController.text = '';
                          startDateController.text = '';
                          endDateController.text = '';
                          _imageMetadata.value = null;
                        },
                        child: Text('addNewPlayer'.tr),
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
}
