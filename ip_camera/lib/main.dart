import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: "assets/.env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foo IP Camera',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CameraScreen(),
    );
  }
}

class CameraScreen extends StatefulWidget {
  CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final String streamUrl = dotenv.env["URL"]!;
  VlcPlayerController _videoPlayerController = VlcPlayerController.network('');
  late bool _isPlaying = true;
  Future<void> initializePlayer() async {}

  @override
  void initState() {
    super.initState();

    _videoPlayerController = VlcPlayerController.network(
      streamUrl,
      hwAcc: HwAcc.full,
      autoPlay: true,
      options: VlcPlayerOptions(
        advanced: VlcAdvancedOptions([
          VlcAdvancedOptions.networkCaching(2000),
        ]),
        subtitle: VlcSubtitleOptions([
          VlcSubtitleOptions.boldStyle(true),
          VlcSubtitleOptions.fontSize(30),
          VlcSubtitleOptions.outlineColor(VlcSubtitleColor.yellow),
          VlcSubtitleOptions.outlineThickness(VlcSubtitleThickness.normal),
          VlcSubtitleOptions.color(VlcSubtitleColor.navy),
        ]),
        rtp: VlcRtpOptions([
          VlcRtpOptions.rtpOverRtsp(true),
        ]),
        audio: VlcAudioOptions([
          VlcAudioOptions.audioTimeStretch(true),
        ]),
      ),
    );
  }

  @override
  void dispose() async {
    super.dispose();
    await _videoPlayerController.stopRendererScanning();
    await _videoPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Foo ip camera")),
      body: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 255,
            child: VlcPlayer(
              controller: _videoPlayerController,
              aspectRatio: 16 / 9,
              placeholder: const Center(child: CircularProgressIndicator()),
            ),
          ),
          Container(
            child: Row(
              children: [
                _isPlaying
                    ? TextButton(
                        onPressed: () {
                          _videoPlayerController.pause();
                          setState(() {
                            _isPlaying = false;
                          });
                        },
                        child: const Icon(
                          Icons.pause,
                          size: 50,
                        ),
                      )
                    : TextButton(
                        onPressed: () {
                          setState(() {
                            _isPlaying = true;
                            _videoPlayerController.play();
                          });
                        },
                        child: const Icon(
                          Icons.play_arrow,
                          size: 50,
                        ),
                      ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
