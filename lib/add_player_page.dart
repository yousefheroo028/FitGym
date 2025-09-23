import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:fit_gym/main.dart';
import 'package:fit_gym/member.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
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
  final _picker = ImagePicker();

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
  late DateTime end = DateTime(start.year, start.month, start.day + 29);

  Member? member = Get.arguments;

  @override
  void initState() {
    if (member != null) {
      if (member?.profileImageURL != null) _imageFile = File(member!.profileImageURL!);
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 16.0,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            buildTextFiled(nameController, 'enterName'.tr, Icons.text_fields, false),
            if (member == null) buildTextFiled(phoneNumberController, 'enterPhone'.tr, Icons.phone, true),
            buildTextFiled(budgetController, 'enterBudget'.tr, Icons.attach_money, true),
            showDatePickerField(startDateController, 'enterStartDate'.tr),
            showDatePickerField(endDateController, 'enterEndDate'.tr),
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
            if (_imageFile != null)
              Column(
                children: [
                  Image.file(
                    _imageFile!,
                    height: 200,
                  ),
                  IconButton(
                    onPressed: () {
                      _imageFile = null;
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
                            profileImageURL: _imageFile?.path,
                            phoneNumber: member!.phoneNumber,
                          ),
                        );
                        Get.back(
                          result: Member(
                            name: nameController.text,
                            startDate: start,
                            endDate: end,
                            subscriptionBudget: budgetController.text.toDouble(),
                            profileImageURL: _imageFile?.path,
                            phoneNumber: member!.phoneNumber,
                          ),
                        );
                        updateDatabase();
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
                      },
                      child: Text('editPlayer'.tr),
                    )
                  : ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.isEmpty && phoneNumberController.text.isEmpty && budgetController.text.isEmpty) {
                          viewSnackBar('completeData'.tr, 'mustFullData'.tr, false);
                          return;
                        }
                        if (memberList.map((member) => member.phoneNumber).contains(phoneNumberController.text)) {
                          viewSnackBar('error'.tr, 'existingOne'.tr, false);
                          return;
                        }
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
                        _imageFile = null;
                        setState(() {});
                      },
                      child: Text('addNewPlayer'.tr),
                    ),
            ),
          ],
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

  Widget buildTextFiled(TextEditingController controller, String hintText, IconData suffixIcon, bool isOnlyNumbers) =>
      TextFormField(
        controller: controller,
        onTapOutside: (event) => FocusScope.of(context).unfocus(),
        inputFormatters: isOnlyNumbers
            ? [
                FilteringTextInputFormatter.digitsOnly,
              ]
            : null,
        keyboardType: isOnlyNumbers ? const TextInputType.numberWithOptions() : null,
        decoration: InputDecoration(
          hintText: hintText,
          fillColor: Colors.grey.withValues(alpha: 0.1),
          suffixIcon: Icon(suffixIcon, color: Colors.grey.withValues(alpha: 0.6)),
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16.0))),
        ),
      );

  Widget showDatePickerField(TextEditingController controller, String labelText) => TextFormField(
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
          suffixIconColor: Colors.black.withValues(alpha: 0.5),
        ),
        controller: controller,
      );
}
