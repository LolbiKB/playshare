import 'package:ble_peripheral/ble_peripheral.dart';
import 'package:flutter/material.dart';
import 'dart:convert' show utf8;

class BlePeripheralPage extends StatefulWidget {
  const BlePeripheralPage({super.key});

  @override
  State<BlePeripheralPage> createState() => _BlePeripheralPageState();
}

class _BlePeripheralPageState extends State<BlePeripheralPage> {
  bool advertisingState = false;
  String transferService = "28196115-20ec-475a-87c4-31fcc87d18cd";
  String transferCharacteristic = "90296f47-c44f-4490-a30b-796bf4eeeb32";

  void initServices() async {
    await BlePeripheral.initialize();

    await BlePeripheral.addService(
      BleService(
        uuid: transferService,
        primary: true,
        characteristics: [
          BleCharacteristic(
            uuid: transferCharacteristic,
            properties: [
              CharacteristicProperties.read.index,
              CharacteristicProperties.write.index,
              CharacteristicProperties.notify.index
            ],
            value: null,
            permissions: [
              AttributePermissions.readable.index,
              AttributePermissions.writeable.index
            ],
          ),
        ],
      ),
    );
  }

  void startAdvertising() async {
    /// set callback for advertising state
    BlePeripheral.setAdvertisingStatusUpdateCallback(
        (bool advertising, String? error) {
      debugPrint("AdvertisingStatus: $advertising Error $error");
    });

    // Start advertising
    await BlePeripheral.startAdvertising(
      services: [transferService],
      localName: "playshare",
    );

    setState(() {
      advertisingState = true;
    });
  }

  void stopAdvertising() async {
    await BlePeripheral.stopAdvertising();

    setState(() {
      advertisingState = false;
    });
  }

  void showAvailableDevices() {
    // Common for Android/Apple
    BlePeripheral.setBleCentralAvailabilityCallback(
        (String deviceId, bool isAvailable) {
      debugPrint("OnDeviceAvailabilityChange: $deviceId : $isAvailable");
    });
  }

  void testSend() async {
    try {
      await BlePeripheral.updateCharacteristic(
        deviceId: '0C:C4:13:40:1E:95',
        characteristicId: transferCharacteristic,
        value: utf8.encode("hello world"),
      );
    } catch (e) {
      debugPrint("UpdateCharacteristicError: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text("A D V E R T I S E"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: MaterialButton(
              onPressed: () {
                if (!advertisingState) {
                  initServices();
                  startAdvertising();
                } else {
                  stopAdvertising();
                }
              },
              child: !advertisingState
                  ? const Text(
                      "Advertise",
                      style: TextStyle(fontSize: 20),
                    )
                  : const Text(
                      "Stop",
                      style: TextStyle(fontSize: 20),
                    ),
            ),
          ),
          Center(
            child: MaterialButton(
              onPressed: () {
                showAvailableDevices();
              },
              child: const Text(
                "Show Devices",
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
          Center(
            child: MaterialButton(
              onPressed: () {
                testSend();
              },
              child: const Text(
                "Send hello world",
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
