import 'package:flutter/material.dart';
import 'package:playshare/components/neu_box.dart';
import 'package:playshare/models/song.dart';

class ShareSongTile extends StatelessWidget {
  final Song song;
  final bool isConnected;
  const ShareSongTile(
      {super.key, required this.song, required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(song.songName),
      subtitle: Text(song.artistName),
      leading: Image.asset(song.albumArtImagePath),
      children: [
        Row(
          children: [
            //skip previous
            Expanded(
                child: GestureDetector(
              onTap: () {},
              child: const NeuBox(child: Icon(Icons.media_bluetooth_on)),
            )),
          ],
        )
      ],
    );
  }
}
