import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:fit_gym/main.dart';
import 'package:fit_gym/member.dart';
import 'package:flutter/material.dart';
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

  Rxn<File?>? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera, maxHeight: 720, maxWidth: 720);

    if (pickedFile != null) {
      _imageFile!.value = File(pickedFile.path);
    }
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery, maxHeight: 720, maxWidth: 720);

    if (pickedFile != null) {
      _imageFile!.value = File(pickedFile.path);
    }
  }

  final start = DateTime.now().obs;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('addNewPlayer'.tr),
      ),
      body: Form(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
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
                    keyboardType: TextInputType.numberWithOptions(signed: false),
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
                    ),
                    firstDate: DateTime.now().subtract(const Duration(days: 31)),
                    lastDate: DateTime.now(),
                    initialPickerDateTime: DateTime.now(),
                    onChanged: (value) {
                      start.value = value ?? DateTime.now();
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
                          await memberBox.put(
                            phoneNumberController.value.text,
                            Member(
                              name: nameController.value.text,
                              startDate: start.value,
                              endDate: start.value.add(const Duration(days: 30)),
                              subscriptionBudget: budgetController.value.text.toDouble(),
                              profileImageURL: _imageFile?.value?.path,
                              phoneNumber: phoneNumberController.value.text,
                            ),
                          );
                          Get.snackbar(
                            'memberAdded'.tr,
                            ' ',
                          );
                          nameController.value.text = '';
                          phoneNumberController.value.text = '';
                          budgetController.value.text = '';
                          start.value = DateTime.now();
                          _imageFile?.value = null;
                        } else {
                          Get.snackbar('invalidBudgetValue'.tr, ' ');
                        }
                      } else {
                        Get.snackbar('completeData'.tr, ' ');
                      }
                    },
                    child: Text('addNewPlayer'.tr),
                  ),
                  if (_imageFile?.value != null)
                    Expanded(
                      child: Image.file(
                        _imageFile!.value!,
                        gaplessPlayback: true,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
