import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  void downloadOverwrite() async {
    if (grpcPort == null || httpPort == null) {
      debugPrint('grpcPort == null || httpPort == null');
      return;
    }
    LocalFolder folder = LocalFolder(folderPath);
    if (!folder.exists()) {
      debugPrint('folder not exists');
      return;
    }

    RemoteGrpcServer remote = RemoteGrpcServer(ip, grpcPort!);
    try {
      Future<List<String>> remoteFsFuture = remote.getRemoteFiles();
      Future<List<String>> localFsFuture = folder.getFiles();
      Future.wait([remoteFsFuture, localFsFuture]);

      List<String> remoteFs = await remoteFsFuture;
      remoteFs.sort();
      List<String> localFs = await localFsFuture;
      localFs.sort();

      for (String path in remoteFs) {
        if (binarySearch(localFs, path) < 0) {
          folder.downloadFile('http://$ip:$httpPort/$path', path);
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
          onPressed: () => {},
          tooltip: '上傳同步',
          child: const Icon(Icons.upload),
        ),
        const SizedBox(width: 100),
        FloatingActionButton(
          onPressed: downloadOverwrite,
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
