
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DownloadService {

  static Future<void> downloadFile(String url) async {

    final dir = await getExternalStorageDirectory();
    final filePath = "${dir!.path}/video.mp4";

    await Dio().download(url, filePath);

  }
}
