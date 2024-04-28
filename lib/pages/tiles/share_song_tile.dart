import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:playshare/components/neu_box.dart';
import 'package:playshare/models/song.dart';

class ShareSongTile extends StatelessWidget {
  final Song song;
  final Device device;
  final Function(String, Song) sendRequest;
  const ShareSongTile(
      {super.key,
      required this.song,
      required this.device,
      required this.sendRequest});

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
              onTap: () {
                sendRequest(device.deviceId, song);
              },
              child: const NeuBox(child: Icon(Icons.media_bluetooth_on)),
            )),
          ],
        )
      ],
    );
  }
}
