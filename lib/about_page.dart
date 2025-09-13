import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('aboutDeveloper'.tr),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 8.0,
          children: [
            Image.asset('assets/icon/logo.png', height: 200),
            const Text(
              "FIT GYM",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'appDescribtion'.tr,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const Divider(),
            Text(
              'developerInfo'.tr,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () async => await launchUrl(
                    Uri.parse('https://www.linkedin.com/in/youssefhassanfahmy2004/'),
                    mode: LaunchMode.externalApplication,
                  ),
                  icon: const FaIcon(FontAwesomeIcons.linkedinIn),
                ),
                IconButton(
                  onPressed: () async => await launchUrl(
                    Uri.parse('https://github.com/yousefheroo028/'),
                    mode: LaunchMode.externalApplication,
                  ),
                  icon: const FaIcon(FontAwesomeIcons.github),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ListTile(
                    trailing: const Icon(Icons.phone),
                    title: const Text('01140169448'),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                    onTap: () => launchUrl(mode: LaunchMode.externalApplication, Uri.parse('tel:01140169448')),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    trailing: const Icon(FontAwesomeIcons.whatsapp),
                    title: const Text('01140169448'),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                    onTap: () => launchUrl(mode: LaunchMode.externalApplication, Uri.parse('https://wa.me/+201140169448')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
