import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audio_picker/audio_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String audioPath = '';
  String videoPath = '/storage/emulated/0/DCIM/Camera/IMG20210107001520.jpg';
  final _picker = ImagePicker();

  final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();

  Future getVideoPath() async {
    PickedFile file = await _picker.getImage(source: ImageSource.gallery);
    setState(() {
      videoPath = file != null ? file.path : '';
    });
  }

  Future getAudioPath() async {
    final path = await AudioPicker.pickAudio();
    if (path != null && path.isNotEmpty) {
      setState(() {
        audioPath = path;
      });
    } else {
      // User canceled the picker
    }
  }

  Future mixingVideo() async {
    if (audioPath.isEmpty || videoPath.isEmpty) return;

    final localPath = await _localPath;
    final resultPath = '/storage/emulated/0/result2.mkv';
    print('resultPath = $resultPath');
    var command = [
      //image
      "-loop",
      "1",
      "-framerate",
      "1",
      //end
      "-i",
      videoPath,
      "-i",
      audioPath,
      //image
      "-shortest",
      "-c",
      "copy",
      resultPath

      //video
      // "-c:v",
      // "copy",
      // "-c:a",
      // "aac",
      // "-strict",
      // "experimental",
      // "-map",
      // "0:v:0",
      // "-map",
      // "1:a:0",
      // resultPath
    ];
    return _flutterFFmpeg.executeWithArguments(command);
  }

  Future<String> get _localPath async {
    final directory = await getExternalStorageDirectory();

    return directory.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(
                onPressed: () => getVideoPath(),
                child: Text(videoPath.isEmpty ? 'Pick video' : videoPath)),
            FlatButton(
                onPressed: () => getAudioPath(),
                child: Text(audioPath.isEmpty ? 'Pick audio' : audioPath)),
            FlatButton(
                onPressed: () async {
                  showDialog(
                      context: context,
                      useRootNavigator: true,
                      builder: (context) => Center(
                            child: CircularProgressIndicator(),
                          ));
                  final resultCode = await mixingVideo();
                  Navigator.of(context).pop();
                  print('resultCode = $resultCode');
                },
                child: Text("Mixing"))
          ],
        ),
      ),
    );
  }
}
