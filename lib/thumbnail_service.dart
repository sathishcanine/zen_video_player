import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ThumbnailService {

  static Future<String?> generateThumbnail(String videoUrl) async {

    final dir = await getTemporaryDirectory();

    final thumbnail = await VideoThumbnail.thumbnailFile(
      video: videoUrl,
      thumbnailPath: dir.path,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 400,
      quality: 75,
    );

    return thumbnail;
  }
}