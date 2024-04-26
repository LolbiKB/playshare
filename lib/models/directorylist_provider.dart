import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DirectoryListProvider extends ChangeNotifier {
  final List<Directory> _directoryList = [];
  final String _fileName = 'ContentDirectoryList';
  Future<Directory?>? _appDocumentsDirectory;
  late Directory contentDiskDir;

  final bool _isFetchedOnce = false;

  DirectoryListProvider() {
    _initializeDirectories();
  }

  void _initializeDirectories() async {
    _appDocumentsDirectory = getApplicationDocumentsDirectory();
    contentDiskDir = (await _appDocumentsDirectory)!;
    fetchAndReadFileToDirectoryList();
  }

  void fetchAndReadFileToDirectoryList() async {
    try {
      File file = File('${contentDiskDir.path}/$_fileName.json');

      if (file.existsSync()) {
        String fileContents = await file.readAsString();
        List<dynamic> jsonData = json.decode(fileContents);
        jsonData.forEach((directory) {
          debugPrint('Directory Path: $directory}');
        });

        _directoryList.clear(); // Clear the existing list
        for (dynamic item in jsonData) {
          addDirectory(Directory(
              item)); // Convert path to Directory object and add to the list
        }

        debugPrint('Data from $_fileName added to _directoryList.');
      } else {
        debugPrint('File $_fileName not found in the directory.');
      }
    } catch (e) {
      debugPrint('Error while reading file: $e');
    }
  }

  void addDirectory(Directory newDirectory) async {
    String newPath = newDirectory.path;
    bool isDuplicate =
        _directoryList.any((directory) => directory.path == newPath);

    if (!isDuplicate) {
      _directoryList.add(newDirectory);
      saveListToDisk();
      notifyListeners();
      debugPrint('Directory added: $newPath');
    } else {
      debugPrint('Duplicate directory: $newPath. Not added.');
    }
  }

  void removeDirectory(Directory directoryToRemove) {
    _directoryList
        .removeWhere((directory) => directory.path == directoryToRemove.path);
    saveListToDisk();
    notifyListeners();
    debugPrint('Directory removed: ${directoryToRemove.path}');
  }

  void saveListToDisk() {
    try {
      File file = File('${contentDiskDir.path}/$_fileName.json');

      List<String> directoryPaths =
          _directoryList.map((directory) => directory.path).toList();

      String jsonData = json.encode(directoryPaths);

      file.writeAsStringSync(jsonData);

      if (file.existsSync()) {
        debugPrint('File $_fileName saved successfully with data: $jsonData');
      } else {
        debugPrint('Failed to save file $_fileName.');
      }
    } catch (e) {
      debugPrint('Error while saving file: $e');
    }
  }

  List<Directory> get directoryList => _directoryList;
  bool get isFetchedOnce => _isFetchedOnce;
}
