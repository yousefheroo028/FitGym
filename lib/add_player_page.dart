import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:fit_gym/main.dart';
import 'package:fit_gym/member.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter, LengthLimitingTextInputFormatter;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

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

  DateTime start = DateTime.now();
  DateTime end = DateTime(DateTime.now().year, DateTime.now().month + 1, DateTime.now().day);

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
          child: SingleChildScrollView(
            child: Column(
              spacing: 16.0,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextFormField(
                  controller: nameController,
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
                  controller: phoneNumberController,
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
                  controller: budgetController,
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
                TextFormField(
                  onTapOutside: (event) => FocusScope.of(context).unfocus(),
                  readOnly: true,
                  onTap: () async {
                    await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(DateTime.now().year - 1, DateTime.now().month, DateTime.now().day),
                      lastDate: DateTime(DateTime.now().year + 1, DateTime.now().month, DateTime.now().day),
                    ).then(
                      (value) {
                        startDateController.text = '${value?.day} - ${value?.month} - ${value?.year}';
                        start = value ?? DateTime.now();
                      },
                    );
                  },
                  decoration: InputDecoration(
                    labelText: 'enterStartDate'.tr,
                    suffixIcon: const Icon(Icons.date_range),
                    suffixIconColor: Colors.black.withValues(alpha: 0.5),
                  ),
                  controller: startDateController,
                ),
                TextFormField(
                  onTapOutside: (event) => FocusScope.of(context).unfocus(),
                  readOnly: true,
                  onTap: () async {
                    await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(DateTime.now().year - 1, DateTime.now().month, DateTime.now().day),
                      lastDate: DateTime(DateTime.now().year + 1, DateTime.now().month, DateTime.now().day),
                    ).then(
                      (value) {
                        endDateController.text = '${value?.day} - ${value?.month} - ${value?.year}';
                        end = value ?? DateTime(DateTime.now().year, DateTime.now().month + 1, DateTime.now().day);
                      },
                    );
                  },
                  decoration: InputDecoration(
                    labelText: 'enterEndDate'.tr,
                    suffixIcon: const Icon(Icons.date_range),
                    suffixIconColor: Colors.black.withValues(alpha: 0.5),
                  ),
                  controller: endDateController,
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
                    if (nameController.text.isNotEmpty &&
                        phoneNumberController.text.isNotEmpty &&
                        budgetController.text.isNotEmpty) {
                      if (budgetController.text.toDouble() > 0) {
                        if (memberBox.get(phoneNumberController.text) == null) {
                          await memberBox.put(
                            phoneNumberController.text,
                            Member(
                              name: nameController.text,
                              startDate: start,
                              endDate: end,
                              subscriptionBudget: budgetController.text.toDouble(),
                              profileImageURL: _imageFile?.path,
                              phoneNumber: phoneNumberController.text,
                            ),
                          );
                          Get.snackbar(
                            'memberAdded'.tr,
                            'daysLeft'.trParams(
                              {
                                'days':
                                    '${end.add(const Duration(days: 1)).difference(DateTime.now()).inDays > 2 ? '${end.add(const Duration(days: 1)).difference(DateTime.now()).inDays} ' : ''}${end.add(const Duration(days: 1)).difference(DateTime.now()).inDays > 2 ? end.add(const Duration(days: 1)).difference(DateTime.now()).inDays > 10 ? 'يوم' : 'أيام' : end.add(const Duration(days: 1)).difference(DateTime.now()).inDays == 2 ? 'يومين ' : 'يوم'}',
                              },
                            ),
                            backgroundColor: Colors.blue.withValues(alpha: 0.5),
                            colorText: Colors.white,
                            borderRadius: 12,
                            margin: const EdgeInsets.all(12),
                            icon: const Icon(Icons.check_circle, color: Colors.white),
                          );
                          nameController.text = '';
                          phoneNumberController.text = '';
                          budgetController.text = '';
                          start = DateTime.now();
                          end = DateTime.now().add(const Duration(days: 30));
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
                if (_imageFile != null) Image.file(_imageFile!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
