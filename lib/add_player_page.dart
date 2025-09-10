import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:fit_gym/main.dart';
import 'package:fit_gym/member.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter, LengthLimitingTextInputFormatter;
import 'package:get/get.dart';
import 'package:date_field/date_field.dart';
import 'package:image_picker/image_picker.dart';

class AddPlayerPage extends StatefulWidget {
  const AddPlayerPage({super.key});

  @override
  State<AddPlayerPage> createState() => _AddPlayerPageState();
}

class _AddPlayerPageState extends State<AddPlayerPage> {
  final nameController = TextEditingController().obs;

  final phoneNumberController = TextEditingController().obs;

  final budgetController = TextEditingController().obs;

  @override
  void dispose() {
    nameController.value.dispose();
    phoneNumberController.value.dispose();
    budgetController.value.dispose();
    super.dispose();
  }

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

  final start = DateTime.now().obs;
  final end = DateTime.now().add(const Duration(days: 30)).obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text('addNewPlayer'.tr),
      ),
      body: Form(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Obx(
            () => Column(
              spacing: 16.0,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextFormField(
                  controller: nameController.value,
                  onTapOutside: (event) => FocusScope.of(context).unfocus(),
                  decoration: InputDecoration(
                    hintText: 'enterName'.tr,
                    enabledBorder: InputBorder.none,
                    fillColor: Colors.grey.withValues(alpha: 0.1),
                    suffixIcon: Icon(
                      Icons.text_fields,
                      color: Colors.grey.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                TextFormField(
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  keyboardType: TextInputType.numberWithOptions(),
                  controller: phoneNumberController.value,
                  onTapOutside: (event) => FocusScope.of(context).unfocus(),
                  decoration: InputDecoration(
                    hintText: 'enterPhone'.tr,
                    enabledBorder: InputBorder.none,
                    fillColor: Colors.grey.withValues(alpha: 0.1),
                    suffixIcon: Icon(
                      Icons.phone,
                      color: Colors.grey.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                TextFormField(
                  controller: budgetController.value,
                  onTapOutside: (event) => FocusScope.of(context).unfocus(),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  keyboardType: TextInputType.numberWithOptions(),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    hintText: 'enterBudget'.tr,
                    enabledBorder: InputBorder.none,
                    fillColor: Colors.grey.withValues(alpha: 0.1),
                    suffixIcon: Icon(
                      Icons.attach_money,
                      color: Colors.grey.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                DateTimeFormField(
                  decoration: InputDecoration(
                    labelText: 'enterStartDate'.tr,
                    enabledBorder: InputBorder.none,
                    labelStyle: TextStyle(color: Colors.grey[500]),
                  ),
                  initialPickerDateTime: DateTime.now(),
                  onChanged: (value) {
                    start.value = value ?? DateTime.now();
                  },
                  mode: DateTimeFieldPickerMode.date,
                ),
                DateTimeFormField(
                  decoration: InputDecoration(
                    labelText: 'enterEndDate'.tr,
                    enabledBorder: InputBorder.none,
                    labelStyle: TextStyle(color: Colors.grey[500]),
                  ),
                  initialPickerDateTime: DateTime.now().add(const Duration(days: 30)),
                  onChanged: (value) {
                    end.value = value ?? DateTime.now().add(const Duration(days: 30));
                  },
                  mode: DateTimeFieldPickerMode.date,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        await _pickImageFromGallery();
                      },
                      icon: const Icon(Icons.photo_size_select_actual_outlined),
                      label: Text('pickPhoto'.tr),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await _pickImageFromCamera();
                      },
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: Text('takePhoto'.tr),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.value.text.isNotEmpty &&
                        phoneNumberController.value.text.isNotEmpty &&
                        budgetController.value.text.isNotEmpty) {
                      if (budgetController.value.text.toDouble() > 0) {
                        if (memberBox.get(phoneNumberController.value.text) == null) {
                          await memberBox.put(
                            phoneNumberController.value.text,
                            Member(
                              name: nameController.value.text,
                              startDate: start.value,
                              endDate: end.value,
                              subscriptionBudget: budgetController.value.text.toDouble(),
                              profileImageURL: _imageFile?.path,
                              phoneNumber: phoneNumberController.value.text,
                            ),
                          );
                          Get.snackbar(
                            'memberAdded'.tr,
                            'daysLeft'.trParams(
                              {
                                'days':
                                    '${end.value.add(const Duration(days: 1)).difference(DateTime.now()).inDays > 2 ? '${end.value.add(const Duration(days: 1)).difference(DateTime.now()).inDays} ' : ''}${end.value.add(const Duration(days: 1)).difference(DateTime.now()).inDays > 2 ? end.value.add(const Duration(days: 1)).difference(DateTime.now()).inDays > 10 ? 'يوم' : 'أيام' : end.value.add(const Duration(days: 1)).difference(DateTime.now()).inDays == 2 ? 'يومين ' : 'يوم'}',
                              },
                            ),
                            backgroundColor: Colors.blue.withValues(alpha: 0.5),
                            colorText: Colors.white,
                            borderRadius: 12,
                            margin: const EdgeInsets.all(12),
                            icon: const Icon(Icons.check_circle, color: Colors.white),
                          );
                          nameController.value.text = '';
                          phoneNumberController.value.text = '';
                          budgetController.value.text = '';
                          start.value = DateTime.now();
                          end.value = DateTime.now().add(const Duration(days: 30));
                          _imageFile = null;
                          setState(() {});
                        } else {
                          Get.snackbar(
                            'error'.tr,
                            'existingOne'.tr,
                            backgroundColor: Colors.red.withValues(alpha: 0.5),
                            colorText: Colors.white,
                            borderRadius: 12,
                            margin: const EdgeInsets.all(12),
                            icon: const Icon(Icons.close, color: Colors.white),
                          );
                        }
                      } else {
                        Get.snackbar(
                          'invalidBudgetValue'.tr,
                          'invalidBudgetValueDetailed'.tr,
                          backgroundColor: Colors.red.withValues(alpha: 0.5),
                          colorText: Colors.white,
                          borderRadius: 12,
                          margin: const EdgeInsets.all(12),
                          icon: const Icon(Icons.close, color: Colors.white),
                        );
                      }
                    } else {
                      Get.snackbar(
                        'completeData'.tr,
                        'mustFullData'.tr,
                        backgroundColor: Colors.red.withValues(alpha: 0.5),
                        colorText: Colors.white,
                        borderRadius: 12,
                        margin: const EdgeInsets.all(12),
                        icon: const Icon(Icons.close, color: Colors.white),
                      );
                    }
                  },
                  child: Text('addNewPlayer'.tr),
                ),
                if (_imageFile != null)
                  Expanded(
                    child: Image.file(_imageFile!),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
