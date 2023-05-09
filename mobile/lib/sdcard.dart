import 'dart:io';

import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

/// 選擇資料夾(限定SD card內)
Future<String?> pickFolder(BuildContext context) async {
  // Directory? externalStorageDirectory = await getExternalStorageDirectory();
  // Directory sdcard = Directory.fromUri(Uri.directory('/storage/emulated/0/'));
  Directory sdcard = Directory.fromUri(Uri.directory('/storage/'));

  Map<Permission, PermissionStatus> statuses = await [
    Permission.manageExternalStorage,
    Permission.storage,
  ].request();

  // debugPrint('externalStorageDirectory=$externalStorageDirectory');
  debugPrint('dir=$sdcard');
  PermissionStatus? manageExternalStorage =
      statuses[Permission.manageExternalStorage];
  PermissionStatus? storage = statuses[Permission.storage];
  debugPrint('manageExternalStorage=$manageExternalStorage, storage=$storage');

  Directory dirRoot = sdcard; // externalStorageDirectory ?? dir;
  String? selectedDirectory = await FilesystemPicker.openDialog(
    context: context,
    rootDirectory: sdcard,
    // rootName: 'SD card',
    rootName: 'storage',
    title: '選擇資料夾',
    requestPermission: () => Permission.storage.request().isGranted,
  );

  debugPrint('pickDirectory=$selectedDirectory');
  return selectedDirectory;
}

class LocalFolder {
  final String folderPath;

  const LocalFolder(this.folderPath);

  Future<bool> exists() async {
    return await Directory(folderPath).exists();
  }

  Future<List<String>> getFiles() {
    return _getFiles(folderPath);
  }

  Future<void> downloadFile(Uri url, String savePath) async {
    debugPrint('downloadFile $url -> $savePath');
    var request = http.Request('GET', url);
    var response = await request.send();

    final fullPath = path.join(folderPath, savePath);
    debugPrint('downloadFile fullPath = $fullPath');

    Directory(fullPath).parent.createSync(recursive: true);
    var file = File(fullPath);
    await response.stream.pipe(file.openWrite());
  }

  Future<void> deleteFile(String subpath) async {
    debugPrint('deleteFile $subpath');
    final fullPath = path.join(folderPath, subpath);
    debugPrint('deleteFile fullPath = $fullPath');
    File(fullPath).deleteSync();
  }

  Future<void> createTxtFile(String savePath, String text) async {
    debugPrint('createTxtFile $savePath');
    final fullPath = path.join(folderPath, savePath);
    debugPrint('createTxtFile fullPath = $fullPath');

    Directory(fullPath).parent.createSync(recursive: true);
    var file = File(fullPath);
    await file.create();
    // 寫入檔案內容
    await file.writeAsString(text);
  }
}

/// 取得資料夾中所有檔案路徑
Future<List<String>> _getFiles(String rootDirPath) {
  Directory rootDir = Directory.fromUri(Uri.directory(rootDirPath));
  debugPrint('getFiles=$rootDir');
  return rootDir.list(recursive: true).where(_isFile).map(_getPath).toList();
}

bool _isFile(FileSystemEntity f) {
  debugPrint('_isFile ${f.path}');
  return f.statSync().type == FileSystemEntityType.file;
}

String _getPath(FileSystemEntity f) {
  return f.path;
}
