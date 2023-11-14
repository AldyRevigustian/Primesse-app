import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:primesse_app/utils/constant.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart'; // Import paket path dengan alias path

class AudioPlayerScreen extends StatefulWidget {
  final String url;
  final String name;
  const AudioPlayerScreen({
    super.key,
    required this.url,
    required this.name,
  });

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class PositionData {
  const PositionData(this.position, this.bufferedPosition, this.duration);
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late AudioPlayer _audioPlayer;

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          _audioPlayer.positionStream,
          _audioPlayer.bufferedPositionStream,
          _audioPlayer.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));
  @override
  void initState() {
    _audioPlayer = AudioPlayer()..setUrl(widget.url);

    super.initState();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              FluentIcons.arrow_download_20_regular,
              size: 30,
            ),
            onPressed: () async {
              launchUrl(Uri.parse(widget.url));
            },
          ),
        ],
        leading: IconButton(
          icon: Icon(
            FluentIcons.chevron_left_20_filled,
            size: 30,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        foregroundColor: CustColors.secondaryColor,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FluentIcons.music_note_2_20_filled,
                color: Colors.white,
                size: 200,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                widget.name,
                style: TextStyle(fontFamily: "Poppins", color: Colors.white),
              ),
              SizedBox(
                height: 20,
              ),
              StreamBuilder(
                  stream: _positionDataStream,
                  builder: (context, snapshot) {
                    final positionData = snapshot.data;
                    return ProgressBar(
                      barHeight: 8,
                      timeLabelTextStyle:
                          TextStyle(color: Colors.white, fontFamily: "Poppins"),
                      baseBarColor: CustColors.secondaryColor.withOpacity(0.2),
                      bufferedBarColor: Colors.white,
                      thumbColor: CustColors.primaryColor,
                      progress: positionData?.position ?? Duration.zero,
                      total: positionData?.duration ?? Duration.zero,
                      buffered: positionData?.bufferedPosition ?? Duration.zero,
                      onSeek: _audioPlayer.seek,
                      // colo
                    );
                  }),
              Control(audio_player: _audioPlayer)
            ],
          ),
        ),
      ),
    );
  }
}

class Control extends StatelessWidget {
  final AudioPlayer audio_player;
  const Control({super.key, required this.audio_player});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: audio_player.playerStateStream,
        builder: (context, snapshot) {
          final playerState = snapshot.data;
          final processingState = playerState?.processingState;
          final playing = playerState?.playing;

          if (!(playing ?? false)) {
            return IconButton(
                color: Colors.white,
                onPressed: audio_player.play,
                icon: Icon(Icons.play_arrow_rounded));
          } else if (processingState != ProcessingState.completed) {
            return IconButton(
                color: Colors.white,
                onPressed: audio_player.pause,
                icon: Icon(Icons.pause_rounded));
          }
          return const Icon(Icons.play_arrow);
        });
  }
}
