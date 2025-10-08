import 'package:fit_gym/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'member.dart';

class ImageViewer extends StatelessWidget {
  const ImageViewer({super.key});

  @override
  Widget build(BuildContext context) {
    final Member member = memberBox.get(Get.arguments)!;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('imageOf'.trParams({"name": member.name})),
      ),
      body: Center(
        child: Hero(
          tag: member.phoneNumber,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: member.profileImageMetadata != null
                    ? MemoryImage(member.profileImageMetadata!)
                    : const AssetImage('assets/icon/placeholder.jpeg'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
