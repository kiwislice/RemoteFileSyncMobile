import 'dart:io';

import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// 選擇資料夾(限定SD card內)
Future<String?> pickDirectory(BuildContext context) async {
  // Directory? externalStorageDirectory = await getExternalStorageDirectory();
  Directory sdcard = Directory.fromUri(Uri.directory('/storage/emulated/0/'));

  // debugPrint('externalStorageDirectory=$externalStorageDirectory');
  debugPrint('dir=$sdcard');

  Directory dirRoot = sdcard; // externalStorageDirectory ?? dir;
  String? selectedDirectory = await FilesystemPicker.openDialog(
    context: context,
    rootDirectory: sdcard,
    rootName: 'SD card',
    title: '選擇資料夾',
    requestPermission: () => Permission.storage.request().isGranted,
  );

  debugPrint('pickDirectory=$selectedDirectory');
  return selectedDirectory;
}

/// 取得資料夾中所有檔案路徑
Future<List<String>> getFiles(String rootDirPath) {
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
