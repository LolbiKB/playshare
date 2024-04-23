import 'dart:io';

import 'package:flutter/material.dart';
import 'package:playshare/components/neu_box.dart';

class ContentDirTile extends StatelessWidget {
  final Directory dir;
  final Function(Directory) onDelete;
  const ContentDirTile({super.key, required this.dir, required this.onDelete});

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
    return ExpansionTile(
      title: Text(getLastDirectoryName(dir.toString())),
      subtitle: Text(dir.toString()),
      children: [
        Row(
          children: [
            //skip previous
            Expanded(
                child: GestureDetector(
              onTap: () {
                onDelete(dir);
              },
              child: const NeuBox(child: Icon(Icons.delete_outline_outlined)),
            )),
          ],
        )
      ],
    );
  }
}
