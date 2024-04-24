import 'package:flutter/material.dart';
import 'package:playshare/models/directorylist_provider.dart';
import 'package:playshare/models/playlist_provider.dart';
import 'package:playshare/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'pages/home_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => DirectoryListProvider()),
        ChangeNotifierProxyProvider<DirectoryListProvider, PlayListProvider>(
          create: (_) => PlayListProvider(),
          update: (_, directoryListProvider, playListProvider) {
            playListProvider
                ?.updateDirectoryList(directoryListProvider.directoryList);
            return playListProvider ?? PlayListProvider();
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}
