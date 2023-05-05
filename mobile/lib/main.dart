import 'package:flutter/material.dart';
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
  int _counter = 0;

  void _incrementCounter() {
    debugPrint('_incrementCounter');
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _DirPicker(),
          ],
        ),
      ),
      persistentFooterAlignment: AlignmentDirectional.center,
      persistentFooterButtons: [
        FloatingActionButton(
          onPressed: null,
          tooltip: '上傳同步',
          child: const Icon(Icons.upload),
        ),
        const SizedBox(width: 100),
        FloatingActionButton(
          onPressed: () {},
          tooltip: '下載同步',
          child: const Icon(Icons.download),
        ), //
      ],
    );
  }
}

class _DirPicker extends StatefulWidget {
  const _DirPicker({super.key});

  @override
  State<_DirPicker> createState() => _DirPickerState();
}

class _DirPickerState extends State<_DirPicker> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: const InputDecoration(
        labelText: '選擇資料夾',
      ),
      onTap: () async {
        controller.text = await pickDirectory(context) ?? '';
      },
    );
  }
}
