import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ConnectToDevicePage extends StatefulWidget {
  final BluetoothDevice device;

  const ConnectToDevicePage({super.key, required this.device});

  @override
  State<ConnectToDevicePage> createState() => _ConnectToDevicePageState();
}

class _ConnectToDevicePageState extends State<ConnectToDevicePage> {
  bool isConnected = false;

  Future<void> connectToDevice() async {
    try {
      await widget.device.connect();
      setState(() {
        isConnected = true;
      });
    } catch (e) {
      // Connection failed
      Navigator.pop(context); // Navigate back to Devices page
    }
  }

  @override
  void dispose() {
    if (isConnected) {
      widget.device.disconnect();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Connect to Device"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: isConnected ? null : connectToDevice,
          child: Text(isConnected
              ? "Connected to '${widget.device.advName}'"
              : "Connect to Device"),
        ),
      ),
    );
  }
}
