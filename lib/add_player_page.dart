import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:fit_gym/main.dart';
import 'package:fit_gym/member.dart';
import 'package:flutter/material.dart';
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

  @override
  void dispose() {
    nameController.dispose();
    phoneNumberController.dispose();
    budgetController.dispose();
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
          child: Column(
            spacing: 16.0,
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
                      await memberBox.put(
                        phoneNumberController.text,
                        Member(
                          name: nameController.text,
                          startDate: DateTime.now(),
                          endDate: DateTime.now().add(Duration(days: 30)),
                          subscriptionBudget: budgetController.text.toDouble(),
                          profileImageURL: _imageFile?.path,
                          phoneNumber: phoneNumberController.text,
                        ),
                      );
                      Get.snackbar(
                        'memberAdded'.tr,
                        ' ',
                      );
                      nameController.text = '';
                      phoneNumberController.text = '';
                      budgetController.text = '';
                      _imageFile = null;
                      setState(() {});
                    } else {
                      Get.snackbar('invalidBudgetValue'.tr, ' ');
                    }
                  } else {
                    Get.snackbar('completeData'.tr, ' ');
                  }
                },
                child: Text('addNewPlayer'.tr),
              ),
              if (_imageFile != null)
                Expanded(
                  child: Image.file(
                    _imageFile!,
                    gaplessPlayback: true,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
