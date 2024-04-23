import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:playshare/models/directorylist_provider.dart';
import 'package:playshare/pages/tiles/content_dir_tiles.dart';
import 'package:provider/provider.dart';

class ContentPage extends StatefulWidget {
  const ContentPage({super.key});

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  //get the playlist provider
  late final dynamic directoryListProvider;

  @override
  void initState() {
    super.initState();

    //get directorylist provider
    directoryListProvider =
        Provider.of<DirectoryListProvider>(context, listen: false);

    directoryListProvider.addListener(_onDirectoryListChanged);
  }

  void _onDirectoryListChanged() {
    setState(() {
      // Update the UI when the directory list changes
    });
  }

  void pickADirectory() async {
    if (await Permission.storage.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
    }
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      setState(() {
        directoryListProvider.addDirectory(Directory(selectedDirectory));
      });
    }
  }

  // remove a directory
  void deleteDirectory(Directory directory) {
    setState(() {
      directoryListProvider.removeDirectory(directory);
    });
  }

  Widget buildAddDirectoryButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: pickADirectory,
      child: const Icon(Icons.add_to_photos_rounded),
    );
  }

  List<Widget> _buildDirPathTiles(BuildContext context) {
    List<Directory> directoryList = directoryListProvider.directoryList;
    return directoryList
        .map((e) => ContentDirTile(
              dir: e,
              onDelete: deleteDirectory,
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text("C O N T E N T"),
      ),
      floatingActionButton: buildAddDirectoryButton(context),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ..._buildDirPathTiles(context),
          ],
        ),
      ),
    );
  }
}
