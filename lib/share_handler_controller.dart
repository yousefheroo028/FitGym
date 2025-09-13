import 'package:get/get.dart';
import 'package:share_handler/share_handler.dart';

class ShareController extends GetxController {
  final Rxn<SharedMedia> sharedMedia = Rxn<SharedMedia>();
  late final String? hiveFile; // هنا هيتخزن كل .hive
  final ShareHandlerPlatform shareHandler = ShareHandlerPlatform.instance;

  bool isLoaded = false;

  Future<void> initShareHandler() async {
    if (isLoaded) return;
    isLoaded = true;

    // أول داتا جاية مع تشغيل التطبيق
    final media = await shareHandler.getInitialSharedMedia();
    if (media != null) {
      _filterHiveFiles(media);
    }

    // لو في مشاركة أثناء ما التطبيق مفتوح
    shareHandler.sharedMediaStream.listen((SharedMedia media) {
      _filterHiveFiles(media);
    });
  }

  void _filterHiveFiles(SharedMedia media) {
    sharedMedia.value = media;

    final attachments = media.attachments ?? [];
    final file = attachments.firstWhere((a) => (a?.path ?? "").toLowerCase().endsWith(".hive"))?.path;

    hiveFile = file;
  }
}
