import 'package:flutter/material.dart';
import 'package:playshare/pages/content_page.dart';
import 'package:playshare/pages/near_by_share_page.dart';
import 'package:playshare/pages/settings_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Column(
        children: [
          //logo
          DrawerHeader(
              child: Center(
            child: Icon(
              Icons.music_note_sharp,
              size: 40,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          )),

          //home tile
          Padding(
            padding: const EdgeInsets.only(left: 25, top: 25),
            child: ListTile(
              title: const Text("H O M E"),
              leading: const Icon(Icons.home),
              onTap: () => Navigator.pop(context),
            ),
          ),

          //share tile
          Padding(
            padding: const EdgeInsets.only(left: 25, top: 25),
            child: ListTile(
              title: const Text("S H A R E"),
              leading: const Icon(Icons.share),
              onTap: () {
                //pop drawer
                Navigator.pop(context);

                //navigate to share page
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NearBySharePage()));
              },
            ),
          ),

          //content tile
          Padding(
            padding: const EdgeInsets.only(left: 25, top: 25),
            child: ListTile(
              title: const Text("C O N T E N T"),
              leading: const Icon(Icons.folder),
              onTap: () {
                //pop drawer
                Navigator.pop(context);

                //navigate to share page
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContentPage(),
                    ));
              },
            ),
          ),

          //setting tile
          Padding(
            padding: const EdgeInsets.only(left: 25, top: 25),
            child: ListTile(
              title: const Text("S E T T I N G S"),
              leading: const Icon(Icons.settings),
              onTap: () {
                //pop drawer
                Navigator.pop(context);

                //navigate to settings page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
