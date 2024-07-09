import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Just Audio Flutter'),
        ),
        body: Home()
      ),
    );
  }
}


class Home extends StatefulWidget {
  String? path;
  Home({Key? key, this.path}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final player = AudioPlayer();

  String formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60); // Corrected to inSeconds for seconds
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  void handlePlayPause() {
    if (player.playing) {
      player.pause();
    } else {
      player.play();
    }
  }

  void handleSeek(double value) {
    player.seek(Duration(seconds: value.toInt()));
  }

  Duration position = Duration.zero;
  Duration duration = Duration.zero;

  @override
  void initState() {
    super.initState();

    // Example URL to test
    String audioUrl = "https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3";
    String audiolocal =  widget.path ?? "";

    // player.setUrl(audioUrl); // Set the audio URL
    player.setAsset(audiolocal); // Set the audio URL

    player.positionStream.listen((p) {
      setState(() {
        position = p;
      });
    });

    player.durationStream.listen((d) {
      setState(() {
        duration = d!;
      });
    });

    player.playerStateStream.listen((state) {
     if(state.processingState == ProcessingState.completed){
       setState(() {
         position = Duration.zero;
       });
       player.pause();
       player.seek(position);
     }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Text(formatDuration(position)),
          Slider(
            min: 0.0,
            max: duration.inSeconds.toDouble(),
            value: position.inSeconds.toDouble(),
            onChanged: handleSeek,
          ),
          Text(formatDuration(duration)),
          IconButton(onPressed: handlePlayPause,
              icon: Icon(player.playing ? Icons.play_arrow_sharp : Icons.stop ))
        ],
      ),
    );
  }
}

