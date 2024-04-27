import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:playshare/pages/ble_peripheral_page.dart';
import 'package:playshare/pages/bluetooth_serial/MainPage.dart';
import 'package:playshare/pages/bluetooth_test_page.dart';
import 'package:playshare/pages/flutter_blue_plus_example/main_bluetooth.dart';
import 'package:playshare/pages/paired_devices_page.dart';
import 'package:playshare/pages/share_near_page.dart';

class SharePage extends StatefulWidget {
  const SharePage({super.key});

  @override
  State<SharePage> createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  @override
  void initState() {
    super.initState();

    // get bluetooth permission
    getBluetoothPermission();
  }

  void getBluetoothPermission() async {
    await Permission.location.request();

    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
    ].request();

    if (statuses[Permission.bluetoothScan] == PermissionStatus.granted &&
        statuses[Permission.bluetoothAdvertise] == PermissionStatus.granted &&
        statuses[Permission.bluetoothConnect] == PermissionStatus.granted) {
      debugPrint("All bluetooth permission granted");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("S H A R E"),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(25),
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MaterialButton(
              child: const Text("Advertise"),
              onPressed: () => (Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const BluetoothSerialPage()))),
            ),
            MaterialButton(
              child: const Text("Discover Devices"),
              onPressed: () => (Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FlutterBlueApp()))),
            ),
          ],
        )),
      ),
    );
  }
}
