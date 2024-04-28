import 'dart:io';

import 'package:flutter/material.dart';

class ShareDirTile extends StatelessWidget {
  final Directory dir;
  final Function(String pathToSaveSong) onDirTileTap;
  const ShareDirTile(
      {super.key, required this.dir, required this.onDirTileTap});

  String getLastDirectoryName(String path) {
    List<String> pathSegments = path.split('/');
    // Removing any trailing empty strings
    pathSegments.removeWhere((element) => element.isEmpty);

    if (pathSegments.isNotEmpty) {
      return pathSegments.last;
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(getLastDirectoryName(dir.toString())),
      subtitle: Text(dir.toString()),
      onTap: () {
        onDirTileTap(dir.path);
      },
    );
  }
}
