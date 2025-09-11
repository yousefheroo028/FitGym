import 'package:get/get.dart';
import 'package:share_handler/share_handler.dart';

class ShareController extends GetxController {
  final Rxn<SharedMedia> sharedMedia = Rxn<SharedMedia>();
  final ShareHandlerPlatform shareHandler = ShareHandlerPlatform.instance;

  bool isLoaded = false;

  Future<void> initShareHandler() async {
    if (isLoaded) return;
    isLoaded = true;

    // أول داتا جاية مع تشغيل التطبيق
    final media = await shareHandler.getInitialSharedMedia();
    if (media != null) {
      sharedMedia.value = media;
    }

    // لو في مشاركة أثناء ما التطبيق مفتوح
    shareHandler.sharedMediaStream.listen((SharedMedia media) {
      sharedMedia.value = media;
    });
  }
}
