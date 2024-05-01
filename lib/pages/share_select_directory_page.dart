import 'dart:io';

import 'package:flutter/material.dart';
import 'package:playshare/models/directorylist_provider.dart';
import 'package:playshare/pages/tiles/share_dir_tiles.dart';
import 'package:provider/provider.dart';

class ShareSelectDirPage extends StatefulWidget {
  final Function(String pathToSaveSong) onDirTileTap;
  final Function() onPageExit;
  const ShareSelectDirPage(
      {super.key, required this.onDirTileTap, required this.onPageExit});

  @override
  State<ShareSelectDirPage> createState() => _ShareSelectDirPageState();
}

class _ShareSelectDirPageState extends State<ShareSelectDirPage> {
  //get the playlist provider
  late final dynamic directoryListProvider;

  @override
  void initState() {
    super.initState();

    //get directorylist provider
    directoryListProvider =
        Provider.of<DirectoryListProvider>(context, listen: false);
  }

  @override
  void dispose() {
    super.dispose();
    widget.onPageExit();
  }

  void onDirTileTap(String pathToSaveSong) {
    widget.onDirTileTap(pathToSaveSong);
    Navigator.pop(context);
  }

  List<Widget> _buildDirPathTiles(BuildContext context) {
    List<Directory> directoryList = directoryListProvider.directoryList;
    return directoryList
        .map((e) => ShareDirTile(
              dir: e,
              onDirTileTap: onDirTileTap,
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text("S E L E C T  D I R E C T O R Y"),
      ),
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
