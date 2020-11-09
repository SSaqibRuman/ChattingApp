import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'app_constants.dart';

class DownloadAttachmentCard extends StatelessWidget {
  final String url;
  DownloadAttachmentCard(this.url);

  Future<bool> _requestStoragePermission() async {
    bool result = false;
    if (Platform.isAndroid) {
      print("Platform.isAndroid : ${Platform.isAndroid}");
      if (!await Permission.storage.isGranted) {
        PermissionStatus status = await Permission.storage.request();
        result = status == PermissionStatus.granted ? true : false;
      } else {
        result = true;
        print(
            "Permission.storage.isGranted: ${await Permission.storage.isGranted}");
      }
    } else if (Platform.isIOS) {
      if (!await Permission.storage.isGranted) {
        PermissionStatus status = await Permission.mediaLibrary.request();
        result = status == PermissionStatus.granted ? true : false;
      } else {
        result = true;
        print(
            "Permission.storage.isGranted: ${await Permission.storage.isGranted}");
      }
    } else {
      print("Invalid Platform");
    }

    return result;
  }

  void _downloadFile(String url) async {
    bool isDownloadable = await _requestStoragePermission();

    if (isDownloadable) {
      var directory = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();

      String path = Platform.isAndroid
          ? "${directory.path.toString().substring(0, directory.path.toString().indexOf("0") + 2) + "Download"}"
          : directory.path;

      print("Mime Type: ${lookupMimeType(url)}");

      final taskId = await FlutterDownloader.enqueue(
        url: url,
        savedDir: path,
        fileName: _getFileName(url),
        requiresStorageNotLow: true,
        headers: {
          "Content-Type":"${lookupMimeType(_getFileName(url))}"
        },
        showNotification:
            true, // show download progress in status bar (for Android)
        openFileFromNotification:
            true, // click on notification to open downloaded file (for Android)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(5),
            child: _getFileIcon(url),
          ),
          Container(
            width: 180,
            child: Text(_getFileName(url)),
          ),
          GestureDetector(
            onTap: () {
              _downloadFile(url);
            },
            child: Container(
              margin: EdgeInsets.all(5),
              child: Image(
                height: 30,
                width: 30,
                image: AssetImage(AppImages.DOWNLOAD_ARROW),
              ),
            ),
          )
        ],
      ),
    );
  }

  String _getFileName(String url) {
    return url.substring(url.lastIndexOf("/") + 1).replaceAll("%20", " ");
  }

  Widget _getFileIcon(String url) {
    final String fileName = _getFileName(url);
    List<String> docExtensions = List();
    docExtensions.add(
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document");
    docExtensions.add("application/msword");

    List<String> imageExtensions = List();
    imageExtensions.add("image/png");
    imageExtensions.add("image/jpeg");

    List<String> pdfExtensions = List();
    pdfExtensions.add("application/pdf");

    List<String> pptExtensions = List();
    pptExtensions.add("application/vnd.ms-powerpoint");
    pptExtensions.add(
        "application/vnd.openxmlformats-officedocument.presentationml.presentation");

    List<String> exceltExtensions = List();
    exceltExtensions.add("application/vnd.ms-excel");
    exceltExtensions.add(
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");

    if (pdfExtensions.contains(lookupMimeType(fileName))) {
      return Image(
        height: 30,
        width: 30,
        image: AssetImage(AppImages.PDF_FILE),
      );
    } else if (imageExtensions.contains(lookupMimeType(fileName))) {
      return Image(
        height: 30,
        width: 30,
        image: NetworkImage(url),
      );
    } else if (docExtensions.contains(lookupMimeType(fileName))) {
      return Image(
        height: 30,
        width: 30,
        image: AssetImage(AppImages.DOC_FILE),
      );
    } else {
      return Image(
        height: 30,
        width: 30,
        image: AssetImage(AppImages.GENERIC_FILE),
      );
    }
  }
}
