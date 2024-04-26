import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:playshare/models/song.dart';

class PlayListProvider extends ChangeNotifier {
  //list of content directories
  List<Directory> _directoryList = [];
  final String defaultArtistName = 'Unknown Artist';
  final String defaultImgPath = 'assets/img/default.png';
  final Map<String, String> _artistDataBaseImgSrcMap = {
    'ed_sheeran': 'assets/img/ed_sheeran.jpg',
    'shawn_mendes': 'assets/img/shawn_mendes.jpg',
    'guns_n_roses': 'assets/img/guns_n_roses.jpg',
  };
  // playlist of songs
  final List<Song> _playlist = [];

  void updateDirectoryList(List<Directory> directories) {
    _directoryList = directories;
    _playlist.clear();
    // Rescan for songs based on the updated directory list
    rescanForSongs();
  }

  void rescanForSongs() {
    // Logic to scan for songs in the directories
    for (Directory directory in _directoryList) {
      addSongsFromDirectory(directory);
    }
  }

  void addSongsFromDirectory(Directory directory) {
    List<FileSystemEntity> files = directory.listSync(followLinks: false);

    for (FileSystemEntity entity in files) {
      if (entity is! File) {
        debugPrint("No files match in directory");
        continue;
      }

      String filePath = entity.path;
      String fileName = filePath.split(Platform.pathSeparator).last;

      // Check if the file has the .mp3 extension before processing
      if (!(fileName.toLowerCase().endsWith('.mp3') ||
          fileName.toLowerCase().endsWith('.m4a'))) {
        debugPrint("No audio files matched in directory");
        //if not matched audio extension
        continue;
      }

      String fileNameWithoutExtension =
          fileName.substring(0, fileName.lastIndexOf('.'));

      if (fileNameWithoutExtension.isEmpty) {
        debugPrint("File name without extension is empty");
        continue;
      }

      String songName = fileNameWithoutExtension;
      String artistName = defaultArtistName;
      String imgPath = defaultImgPath;
      String audioPath = filePath;

      // maybe special case
      if (fileNameWithoutExtension.contains('-')) {
        List<String> parts = fileNameWithoutExtension.split('-');
        if (parts.length >= 2) {
          String textBeforeHyphen = parts[0];
          String textAfterHyphen = parts.sublist(1).join('-');
          // songName
          songName = textBeforeHyphen;

          // format artistName
          artistName = textAfterHyphen.replaceAll('_', ' ');
          artistName = artistName
              .split(' ')
              .map((word) => word[0].toUpperCase() + word.substring(1))
              .join(' ');

          // if match defaultImgSrc
          if (_artistDataBaseImgSrcMap.containsKey(textAfterHyphen)) {
            imgPath = _artistDataBaseImgSrcMap[textAfterHyphen]!;
          }
        }
      }

      //final add to List
      debugPrint("Song added:");
      debugPrint("  songName: $songName");
      debugPrint("  artist: $artistName");
      debugPrint("  imgPath: $imgPath");
      debugPrint("  audio: $audioPath");

      addSong(Song(
        songName: songName,
        artistName: artistName,
        albumArtImagePath: imgPath,
        audioPath: audioPath,
      ));
    }
  }

  void addSong(Song songToAdd) {
    _playlist.add(songToAdd);

    // Notify listeners about any changes
    notifyListeners();
  }

  // Other methods and logic

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

  // play song
  void play() async {
    final String path = _playlist[_currentSongIndex!].audioPath;
    await _audioPlayer.stop(); // stop current song
    await _audioPlayer.play(DeviceFileSource(path)); // play song
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
    _isPlaying = true;
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
