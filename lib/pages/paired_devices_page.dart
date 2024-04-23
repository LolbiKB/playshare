import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:playshare/pages/connect_to_device_page.dart';

class PairedDevicesPage extends StatefulWidget {
  const PairedDevicesPage({super.key});

  @override
  State<PairedDevicesPage> createState() => _PairedDevicesPageState();
}

class _PairedDevicesPageState extends State<PairedDevicesPage> {
  List<ScanResult> scanResults = [];
  bool isScanning = false;

  Future<void> startScanning() async {
    if (isScanning) {
      return; // Prevent multiple scans
    }

    setState(() {
      isScanning = true;
    });

    await FlutterBluePlus.startScan(withServices: [
      Guid('bf27730d-860a-4e09-889c-2d8b6a9e0fe7'),
    ], timeout: const Duration(seconds: 5));

    var subscription = FlutterBluePlus.onScanResults.listen(
      (results) {
        if (results.isNotEmpty) {
          ScanResult r = results.last;
          setState(() {
            // Check if the same device is already detected
            if (!scanResults.contains(r)) {
              scanResults.add(r); // Add the most recently found device
              debugPrint(
                  '${r.device.remoteId}: "${r.advertisementData.advName}" found!');
            }
          });
        }
      },
      onError: (e) => debugPrint(e),
    );

    // Cleanup: cancel subscription when scanning stops
    FlutterBluePlus.cancelWhenScanComplete(subscription);

    // Wait for scanning to stop
    await FlutterBluePlus.isScanning.where((val) => val == false).first;

    setState(() {
      isScanning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text("DEVICES"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: scanResults.isEmpty ? 1 : scanResults.length,
              itemBuilder: (context, index) {
                if (scanResults.isEmpty) {
                  return ListTile(
                    title: const Text("No Devices Found"),
                    subtitle: const Text("Tap below to start scanning."),
                    leading: const Icon(Icons.devices),
                    onTap: isScanning ? null : startScanning,
                  );
                } else {
                  final ScanResult eachScanResult = scanResults[index];
                  return ListTile(
                    title: Text(eachScanResult.device.advName),
                    subtitle: Text(eachScanResult.device.remoteId.toString()),
                    leading: const Icon(Icons.devices),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConnectToDevicePage(
                              device: eachScanResult.device),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: ElevatedButton(
              onPressed: isScanning ? null : startScanning,
              child: const Text("Scan"),
            ),
          ),
        ],
      ),
    );
  }
}
