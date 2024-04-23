import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:playshare/models/song.dart';

class PlayListProvider extends ChangeNotifier {
  // playlist of songs
  final List<Song> _playlist = [
    // song 1
    Song(
      songName: "Wonder",
      artistName: "Shawn Mendes",
      albumArtImagePath: "assets/img/shawn_mendes.jpg",
      audioPath: "music/wonder-shawn_mendes.mp3",
    ),

    // song 2
    Song(
      songName: "Perfect",
      artistName: "Ed Sheeran",
      albumArtImagePath: "assets/img/ed_sheeran.jpg",
      audioPath: "music/perfect-ed_sheeran.mp3",
    ),

    // song 3
    Song(
      songName: "Estranged",
      artistName: "Guns N Roses",
      albumArtImagePath: "assets/img/guns_n_roses.jpg",
      audioPath: "music/estranged-guns_n_roses.mp3",
    ),
  ];

  //current song playign index
  int? _currentSongIndex;

  // audio player
  final AudioPlayer _audioPlayer = AudioPlayer();

  // duration
  Duration _currentDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;

  // constructor
  PlayListProvider() {
    listenToDuration();
  }

  // init not playing
  bool _isPlaying = false;

  // fetch file path and name
  void fetchFilePathsAndNames(Directory directory) {
    List<FileSystemEntity> files = directory.listSync();

    for (FileSystemEntity file in files) {
      if (file is File) {
        String filePath = file.path;
        String fileName = file.path.split(Platform.pathSeparator).last;
        debugPrint('File Name: $fileName, File Path: $filePath');
      }
    }
  }

  // play song
  void play() async {
    final String path = _playlist[_currentSongIndex!].audioPath;
    await _audioPlayer.stop(); // stop current song
    await _audioPlayer.play(AssetSource(path)); // play song
    _isPlaying = true;
    notifyListeners();
  }

  // pause song
  void pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  // resume
  void resume() async {
    await _audioPlayer.resume();
    _isPlaying = false;
    notifyListeners();
  }

  // pause or resume
  void pauseOrResume() async {
    if (_isPlaying) {
      pause();
    } else {
      resume();
    }
  }

  // seek
  void seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  // play next
  void playNextSong() {
    if (_currentSongIndex == null) return;
    if (_currentSongIndex! < _playlist.length - 1) {
      currentSongIndex = _currentSongIndex! + 1;
    } else {
      currentSongIndex = 0;
    }
  }

  // play previous
  void playPreviousSong() async {
    //skip back if more than 3 secs, restart
    if (_currentDuration.inSeconds > 3) {
      seek(Duration.zero);
    } else {
      if (_currentSongIndex! > 0) {
        currentSongIndex = _currentSongIndex! - 1;
      } else {
        currentSongIndex = playlist.length - 1;
      }
    }
  }

  // list to duration
  void listenToDuration() {
    // total
    _audioPlayer.onDurationChanged.listen((newDuration) {
      _totalDuration = newDuration;
      notifyListeners();
    });

    // current
    _audioPlayer.onPositionChanged.listen((newPosition) {
      _currentDuration = newPosition;
      notifyListeners();
    });

    // complete
    _audioPlayer.onPlayerComplete.listen((event) {
      playNextSong();
    });
  }

  // dispose of audio player

  // getters
  List<Song> get playlist => _playlist;
  int? get currentSongIndex => _currentSongIndex;
  bool get isPlaying => _isPlaying;
  Duration get currentDuration => _currentDuration;
  Duration get totalDuration => _totalDuration;

  //setters
  set currentSongIndex(int? newIndex) {
    //update song
    _currentSongIndex = newIndex;

    if (newIndex != null) {
      play();
    }

    //update UI
    notifyListeners();
  }
}
