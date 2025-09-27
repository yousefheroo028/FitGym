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

  Uint8List? _imageMetadata;

  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera, maxHeight: 480, maxWidth: 480);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = imageFile.path.split('/').last;
      final savedImage = await imageFile.copy('${appDir.path}/$fileName');
      await GallerySaver.saveImage(savedImage.path);
      _imageMetadata = await pickedFile.readAsBytes();
    }
    setState(() {});
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, maxHeight: 480, maxWidth: 480);

    if (pickedFile != null) {
      _imageMetadata = await pickedFile.readAsBytes();
    }
    setState(() {});
  }

  DateTime start = DateTime.now();
  late DateTime end = DateTime(start.year, start.month, start.day + 29);

  Member? member = Get.arguments;
  @override
  void initState() {
    if (member != null) {
      if (member!.profileImageMetadata != null) _imageMetadata = member!.profileImageMetadata!;
      nameController.text = member!.name;
      phoneNumberController.text = member!.phoneNumber;
      budgetController.text = member!.subscriptionBudget.toInt().toString();
      startDateController.text = '${member!.startDate.day} - ${member!.startDate.month} - ${member!.startDate.year}';
      endDateController.text = '${member!.endDate.day} - ${member!.endDate.month} - ${member!.endDate.year}';
      start = member!.startDate;
      end = member!.endDate;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text(member != null ? 'تعديل بيانات ${member!.name}' : 'إضافة لاعب جديد'),
      ),
      body: Form(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(8.0),
          child: Column(
            spacing: 16.0,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextFormField(
                controller: nameController,
                onTapOutside: (event) => FocusScope.of(context).unfocus(),
                decoration: InputDecoration(
                  hintText: 'enterName'.tr,
                  fillColor: Colors.grey.withValues(alpha: 0.1),
                  suffixIcon: Icon(
                    Icons.text_fields,
                    color: Colors.grey.withValues(alpha: 0.6),
                  ),
                ),
              ),
              if (member == null)
                TextFormField(
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  keyboardType: TextInputType.numberWithOptions(),
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
                keyboardType: TextInputType.numberWithOptions(),
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
              if (_imageMetadata != null)
                Column(
                  children: [
                    Image.memory(_imageMetadata!, height: 200),
                    IconButton(
                      onPressed: () {
                        _imageMetadata = null;
                        setState(() {});
                      },
                      icon: const Icon(Icons.close),
                    )
                  ],
                ),
              SizedBox(
                width: context.width,
                child: member != null
                    ? ElevatedButton(
                        onPressed: () async {
                          await memberBox.put(
                            member!.phoneNumber,
                            Member(
                              name: nameController.text,
                              startDate: start,
                              endDate: end,
                              subscriptionBudget: budgetController.text.toDouble(),
                              profileImageMetadata: _imageMetadata,
                              phoneNumber: member!.phoneNumber,
                            ),
                          );
                          Get.back(
                            result: Member(
                              name: nameController.text,
                              startDate: start,
                              endDate: end,
                              subscriptionBudget: budgetController.text.toDouble(),
                              profileImageMetadata: _imageMetadata,
                              phoneNumber: member!.phoneNumber,
                            ),
                          );
                          updateDatabase();
                          Get.snackbar(
                            'memberEdited'.tr,
                            end.date.difference(DateTime.now().date).inDays >= 0
                                ? 'daysLeft'.trParams(
                                    {
                                      "days": dayText(end.date.difference(DateTime.now().date).inDays),
                                    },
                                  )
                                : 'الاشتراك خلصان',
                            backgroundColor: Colors.blue.withValues(alpha: 0.5),
                            colorText: Colors.white,
                            borderRadius: 12,
                            margin: const EdgeInsets.all(12),
                            icon: const Icon(Icons.check_circle, color: Colors.white),
                          );
                        },
                        child: Text('editPlayer'.tr),
                      )
                    : ElevatedButton(
                        onPressed: () async {
                          if (nameController.text.isEmpty &&
                              phoneNumberController.text.isEmpty &&
                              budgetController.text.isEmpty) {
                            Get.snackbar(
                              'completeData'.tr,
                              'mustFullData'.tr,
                              backgroundColor: Colors.red.withValues(alpha: 0.5),
                              colorText: Colors.white,
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                            );
                            return;
                          }
                          if (memberList.map((member) => member.phoneNumber).contains(phoneNumberController.text)) {
                            Get.snackbar(
                              'error'.tr,
                              'existingOne'.tr,
                              backgroundColor: Colors.red.withValues(alpha: 0.5),
                              colorText: Colors.white,
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                            );
                            return;
                          }
                          await memberBox.put(
                            phoneNumberController.text,
                            Member(
                              name: nameController.text,
                              startDate: start,
                              endDate: end,
                              subscriptionBudget: budgetController.text.toDouble(),
                              profileImageMetadata: _imageMetadata,
                              phoneNumber: phoneNumberController.text,
                            ),
                          );
                          updateDatabase();
                          Get.snackbar(
                            'memberAdded'.tr,
                            end.date.difference(DateTime.now().date).inDays >= 0
                                ? 'daysLeft'.trParams(
                                    {
                                      "days": dayText(end.date.difference(DateTime.now().date).inDays),
                                    },
                                  )
                                : 'الاشتراك خلصان',
                            backgroundColor: Colors.blue.withValues(alpha: 0.5),
                            colorText: Colors.white,
                            borderRadius: 12,
                            margin: const EdgeInsets.all(12),
                            icon: const Icon(Icons.check_circle, color: Colors.white),
                          );
                          nameController.text = '';
                          phoneNumberController.text = '';
                          budgetController.text = '';
                          startDateController.text = '';
                          endDateController.text = '';
                          _imageMetadata = null;
                          setState(() {});
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
