import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:remote_file_sync_mobile/remote.dart';
import 'package:remote_file_sync_mobile/sdcard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController ipController = TextEditingController();
  TextEditingController grpcPortController = TextEditingController();
  TextEditingController httpPortController = TextEditingController();
  TextEditingController folderController = TextEditingController();

  String get ip => ipController.text;
  int? get grpcPort => int.tryParse(grpcPortController.text);
  int? get httpPort => int.tryParse(httpPortController.text);
  String get folderPath => folderController.text;

  @override
  void initState() {
    super.initState();
    ipController.text = '172.30.80.1';
    grpcPortController.text = '61090';
    httpPortController.text = '61091';
  }

  @override
  void dispose() {
    ipController.dispose();
    grpcPortController.dispose();
    httpPortController.dispose();
    super.dispose();
  }

  Future<bool> checkInput() async {
    if (grpcPort == null || httpPort == null) {
      showMsg(context, 'grpcPort和httpPort為必填');
      debugPrint('grpcPort == null || httpPort == null');
      return false;
    }
    LocalFolder folder = LocalFolder(folderPath);
    if (!await folder.exists()) {
      showMsg(context, '資料夾不存在');
      debugPrint('folder not exists: $folderPath');
      return false;
    }
    return true;
  }

  void download(_DownloadOptions options) async {
    LocalFolder folder = LocalFolder(folderPath);
    RemoteGrpcServer remote = RemoteGrpcServer(ip, grpcPort!);
    try {
      Future<List<String>> remoteFsFuture = remote.getRemoteFiles();
      Future<List<String>> localFsFuture = folder.getFiles();
      Future.wait([remoteFsFuture, localFsFuture]);

      List<String> remoteFs = await remoteFsFuture;
      remoteFs.sort();
      List<String> localFs = await localFsFuture;
      localFs.sort();

      if (options.deleteFileIfRemoteNotExists) {
        for (String path in localFs) {
          if (binarySearch(remoteFs, path) < 0) {
            await folder.deleteFile(path);
          }
        }
      }

      for (String path in remoteFs) {
        if (binarySearch(localFs, path) < 0) {
          Uri url = Uri.parse('http://$ip:$httpPort/download/').resolve(path);
          await folder.downloadFile(url, path);
        }
      }
    } catch (e) {
      debugPrint('Caught error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _FolderPicker(folderController),
            _IpInput(ipController),
            Row(
              children: [
                Expanded(
                  child: _PortInput(grpcPortController, '輸入gRPC Port'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PortInput(httpPortController, '輸入Http Port'),
                ),
              ],
            ),
          ],
        ),
      ),
      persistentFooterAlignment: AlignmentDirectional.center,
      persistentFooterButtons: [
        FloatingActionButton(
          onPressed: () async {
            Map<Permission, PermissionStatus> statuses = await [
              Permission.manageExternalStorage,
              Permission.storage,
            ].request();

            PermissionStatus? manageExternalStorage =
                statuses[Permission.manageExternalStorage];
            PermissionStatus? storage = statuses[Permission.storage];
            debugPrint(
                'manageExternalStorage=$manageExternalStorage, storage=$storage');

            await Permission.manageExternalStorage.shouldShowRequestRationale;
            Permission.manageExternalStorage.isRestricted;

            try {
              LocalFolder folder = LocalFolder(folderPath);
              await folder.createTxtFile('aaa.txt', 'aaa');
              showMsg(context, '新增檔案成功');
            } catch (e) {
              debugPrint('新增檔案失敗 $e');
              showMsg(context, '新增檔案失敗');
            }
          },
          tooltip: '上傳同步',
          child: const Icon(Icons.upload),
        ),
        const SizedBox(width: 100),
        FloatingActionButton(
          onPressed: () async {
            if (!await checkInput()) return;

            Future<_DownloadOptions?> optionsFuture =
                DownloadDialog.show(context);
            optionsFuture.then((options) {
              if (options == null) return;
              download(options);
            });
          },
          tooltip: '下載同步',
          child: const Icon(Icons.download),
        ), //
      ],
    );
  }
}

class _FolderPicker extends StatelessWidget {
  final TextEditingController controller;

  const _FolderPicker(this.controller);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: const InputDecoration(
        labelText: '選擇資料夾',
      ),
      onTap: () async {
        controller.text = await pickFolder(context) ?? '';
      },
    );
  }
}

class _IpInput extends StatelessWidget {
  final TextEditingController controller;

  const _IpInput(this.controller);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: '輸入遠端IP',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }
}

class _PortInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _PortInput(this.controller, this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }
}

void showMsg(BuildContext context, String text) {
  final snackBar = SnackBar(
    content: Text(text),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void showSnackBar(BuildContext context, SnackBar snackBar) {
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

class _DownloadOptions {
  bool deleteFileIfRemoteNotExists = false;
}

class DownloadDialog extends StatefulWidget {
  const DownloadDialog({super.key});

  static Future<_DownloadOptions?> show(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return const DownloadDialog();
      },
    );

    debugPrint('DownloadDialog.result= $result');
    if (result == null) return null;

    _DownloadOptions options = _DownloadOptions();
    options.deleteFileIfRemoteNotExists = result['deleteFileIfRemoteNotExists'];
    return options;
  }

  @override
  _DownloadDialogState createState() => _DownloadDialogState();
}

class _DownloadDialogState extends State<DownloadDialog> {
  bool _deleteFileIfRemoteNotExists = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      title: const Text('下載選項'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CheckboxListTile(
            title: const Text('刪除遠端不存在的檔案'),
            value: _deleteFileIfRemoteNotExists,
            onChanged: (bool? value) {
              setState(() {
                _deleteFileIfRemoteNotExists = value ?? false;
              });
            },
          ),
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          child: const Text('下載'),
          onPressed: () {
            Navigator.of(context).pop({
              'deleteFileIfRemoteNotExists': _deleteFileIfRemoteNotExists,
            });
          },
        ),
      ],
    );
  }
}
