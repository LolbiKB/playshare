import 'package:flutter/material.dart';
import 'package:playshare/components/neu_box.dart';
import 'package:playshare/models/playlist_provider.dart';
import 'package:provider/provider.dart';

class SongPage extends StatefulWidget {
  const SongPage({super.key});

  @override
  State<SongPage> createState() => _SongPageState();
}

class _SongPageState extends State<SongPage> {
  //simply duration(format time: min:sec)
  String formatTime(Duration duration) {
    String secondDigits =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    String formattedTime = "${duration.inMinutes}:$secondDigits";
    return formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayListProvider>(builder: (context, value, child) {
      //get Playlist
      final playlist = value.playlist;

      //get Current song
      final currentSong = playlist[value.currentSongIndex ?? 0];

      //current slider value
      double _currentSliderValue = value.currentDuration.inSeconds.toDouble();

      //return UI
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.only(left: 25, right: 25, bottom: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              //app bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //back button
                  IconButton(
                      onPressed: () => (Navigator.pop(context)),
                      icon: const Icon(Icons.arrow_back)),

                  //title
                  const Text("P L A Y L I S T"),
                  //menu button
                  IconButton(onPressed: () {}, icon: const Icon(Icons.menu))
                ],
              ),

              //album artwork
              NeuBox(
                child: Column(
                  children: [
                    //image
                    ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(currentSong.albumArtImagePath)),

                    //song and artist
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //name
                          Column(
                            children: [
                              //name
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentSong.songName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                  Text(currentSong.artistName)
                                ],
                              )
                            ],
                          ),
                          //fav icon
                          const Icon(
                            Icons.favorite,
                            color: Colors.red,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(
                height: 25,
              ),

              // progress bar
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //start time
                        Text(formatTime(value.currentDuration)),

                        //shuffle
                        const Icon(Icons.shuffle),

                        //repeat
                        const Icon(Icons.repeat),

                        //end time
                        Text(formatTime(value.totalDuration)),
                      ],
                    ),
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 0)),
                    child: Slider(
                      min: 0,
                      max: value.totalDuration.inSeconds.toDouble(),
                      value: _currentSliderValue,
                      activeColor: Colors.green,
                      onChanged: (double double) {
                        _currentSliderValue = double;
                      },
                      onChangeEnd: (double double) {
                        value.seek(Duration(seconds: double.toInt()));
                      },
                    ),
                  )
                ],
              ),

              const SizedBox(
                height: 10,
              ),

              // player controls
              Row(
                children: [
                  //skip previous
                  Expanded(
                      child: GestureDetector(
                          onTap: value.playPreviousSong,
                          child:
                              const NeuBox(child: Icon(Icons.skip_previous)))),

                  const SizedBox(
                    width: 20,
                  ),

                  //play/pause
                  Expanded(
                      flex: 2,
                      child: GestureDetector(
                          onTap: value.pauseOrResume,
                          child: NeuBox(
                              child: Icon(value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow)))),

                  const SizedBox(
                    width: 20,
                  ),

                  //skip forward
                  Expanded(
                      child: GestureDetector(
                          onTap: value.playNextSong,
                          child: const NeuBox(child: Icon(Icons.skip_next)))),
                ],
              )
            ],
          ),
        )),
      );
    });
  }
}
