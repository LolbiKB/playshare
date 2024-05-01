import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:playshare/models/directorylist_provider.dart';
import 'package:playshare/models/payload.dart';
import 'package:playshare/models/playlist_provider.dart';
import 'package:playshare/models/song.dart';
import 'package:playshare/pages/share_select_directory_page.dart';
import 'package:playshare/pages/tiles/share_song_tile.dart';
import 'package:provider/provider.dart';

class ShareConnectePage extends StatefulWidget {
  final Device device;
  final NearbyService nearbyService;
  const ShareConnectePage(
      {super.key, required this.device, required this.nearbyService});

  @override
  State<ShareConnectePage> createState() => _ShareConnectePageState();
}

class _ShareConnectePageState extends State<ShareConnectePage> {
  // get the playlist provider
  late final DirectoryListProvider directoryListProvider;
  late final dynamic playListProvider;
  late StreamSubscription receivedDataSubscription;

  // handle states
  bool isRequestingToSend = false;
  bool isRequester = false;
  bool isReceiver = false;
  bool isAccepted = false;
  Song? songToSend;
  String? pathToSaveSong;
  String? songFileName;

  //song info
  int? songSize;

  @override
  void initState() {
    super.initState();

    // get playlist provider
    playListProvider = Provider.of<PlayListProvider>(context, listen: false);

    // get directoryList provider

    //get directorylist provider
    directoryListProvider =
        Provider.of<DirectoryListProvider>(context, listen: false);

    directoryListProvider.addListener(_onDirectoryListChanged);

    receivedDataSubscription =
        widget.nearbyService.dataReceivedSubscription(callback: (data) {
      handleReceivedData(data);
    });
  }

  @override
  void dispose() {
    receivedDataSubscription.cancel();
    super.dispose();
  }

  // song tiles
  List<Widget> _buildSongTiles(BuildContext context) {
    List<Song> songs = playListProvider.playlist;
    return songs
        .map((e) => ShareSongTile(
              song: e,
              device: widget.device,
              sendRequest: sendRequest,
            ))
        .toList();
  }

  void _onDirectoryListChanged() {
    setState(() {
      // Update the UI when the directory list changes
    });
  }

  void checkTransferComplete() {
    // Create a periodic timer that runs every 500 milliseconds
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      // proccess saving to the selected
      Directory('/storage/emulated/0/Download/.nearby')
          .listSync()
          .forEach((entity) {
        if (entity is File && entity.lengthSync() >= songSize!) {
          // moving file
          debugPrint("moveing $entity to $pathToSaveSong/$songFileName");
          String newFilePath = '$pathToSaveSong/$songFileName';
          entity.renameSync(newFilePath);

          // refresh UI
          setState(() {
            directoryListProvider.refreshDirectoryList();
          });

          // send transfer complete
          sendFileTransferComplete();

          // reset receiver
          resetStateReceiver();

          // cancel timer
          timer.cancel();
        } else if (entity is File) {
          // show progress
          double percentage =
              (entity.lengthSync() / songSize! * 100).toDouble();
          showToast("Transfer: $percentage %",
              context: context,
              axis: Axis.horizontal,
              alignment: Alignment.center,
              position: StyledToastPosition.bottom);
        }
      });
    });
  }

  // Modify the function signature to accept a Song object
  Future<void> sendRequest(String deviceID, Song song) async {
    // set song to send
    setState(() {
      songToSend = song;
    });

    // Encode the song object into JSON format
    String songJson = jsonEncode(song.toJson());

    // Convert the JSON string to bytes
    Uint8List songData = utf8.encode(songJson);

    // Create payload with the message type (RequestToSendSong) and song data
    Payload payload = Payload(MessageType.requestToSendSong, songData);

    // Encode payload into JSON format
    String jsonPayload = jsonEncode({
      'type': payload.type.index,
      'data': base64Encode(payload.data),
    });

    // Send the JSON-encoded payload
    await widget.nearbyService.sendMessage(deviceID, jsonPayload);

    // set to requester
    setState(() {
      isRequestingToSend = true;
      isRequester = true;
    });

    //show waiting dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Request Sent"),
          content: const Center(child: Text('Waiting for confirmation')),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                // Start the timer
                Timer(const Duration(seconds: 10), () {
                  if (isRequestingToSend) {
                    // Timer expired, handle timeout
                    handleConfirmationTimeout();
                  }
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Function to send a message with payload
  Future<void> sendAcceptRequest() async {
    // Encode message into bytes
    Uint8List messageBytes = utf8.encode('accept_request');

    // Create payload with the specified message type (GenericMessage) and message data
    Payload payload = Payload(MessageType.acceptRequest, messageBytes);

    // Encode payload into JSON format
    String jsonPayload = jsonEncode({
      'type': payload.type.index,
      'data': base64Encode(payload.data),
    });

    // Send the JSON-encoded payload
    await widget.nearbyService.sendMessage(widget.device.deviceId, jsonPayload);
  }

  // Function to send a message with payload
  Future<void> sendReadyToReceive() async {
    // Encode message into bytes
    Uint8List messageBytes = utf8.encode('ready_request');

    // Create payload with the specified message type (GenericMessage) and message data
    Payload payload = Payload(MessageType.readyToReceiveSong, messageBytes);

    // Encode payload into JSON format
    String jsonPayload = jsonEncode({
      'type': payload.type.index,
      'data': base64Encode(payload.data),
    });

    // Send the JSON-encoded payload
    await widget.nearbyService.sendMessage(widget.device.deviceId, jsonPayload);
  }

  // Function to send a message with payload
  Future<void> sendCancelRequest() async {
    // Encode message into bytes
    Uint8List messageBytes = utf8.encode('cancel_request');

    // Create payload with the specified message type (GenericMessage) and message data
    Payload payload = Payload(MessageType.cancelRequest, messageBytes);

    // Encode payload into JSON format
    String jsonPayload = jsonEncode({
      'type': payload.type.index,
      'data': base64Encode(payload.data),
    });

    // Send the JSON-encoded payload
    await widget.nearbyService.sendMessage(widget.device.deviceId, jsonPayload);
  }

  // Function to send a message with payload
  Future<void> sendFileTransferComplete() async {
    // Encode message into bytes
    Uint8List messageBytes = utf8.encode('file_transfer_complete');

    // Create payload with the specified message type (GenericMessage) and message data
    Payload payload = Payload(MessageType.fileTransferComplete, messageBytes);

    // Encode payload into JSON format
    String jsonPayload = jsonEncode({
      'type': payload.type.index,
      'data': base64Encode(payload.data),
    });

    // Send the JSON-encoded payload
    await widget.nearbyService.sendMessage(widget.device.deviceId, jsonPayload);
  }

  Future<void> sendFileInfo() async {
    File file = File(songToSend!.audioPath);
    int fileSize = file.lengthSync();
    // Encode file info into bytes
    Uint8List infoBytes = utf8.encode(fileSize.toString());

    // Create payload with the message type (FileInfo) and info data
    Payload payload = Payload(MessageType.fileInfo, infoBytes);

    // Encode payload into JSON format
    String jsonPayload = jsonEncode({
      'type': payload.type.index,
      'data': base64Encode(payload.data),
    });

    // Send the JSON-encoded payload
    await widget.nearbyService.sendMessage(widget.device.deviceId, jsonPayload);
  }

  // Function to send a message with payload
  Future<void> sendMessage(String deviceID, String message) async {
    // Encode message into bytes
    Uint8List messageBytes = utf8.encode(message);

    // Create payload with the specified message type (GenericMessage) and message data
    Payload payload = Payload(MessageType.genericMessage, messageBytes);

    // Encode payload into JSON format
    String jsonPayload = jsonEncode({
      'type': payload.type.index,
      'data': base64Encode(payload.data),
    });

    // Send the JSON-encoded payload
    await widget.nearbyService.sendMessage(deviceID, jsonPayload);
  }

  //send error
  Future<void> sendError() async {
    // Create payload with the specified message type (Error) and 4 bytes of all zeroes
    Payload payload =
        Payload(MessageType.error, Uint8List.fromList([0, 0, 0, 0]));

    // Encode payload into JSON format
    String jsonPayload = jsonEncode({
      'type': payload.type.index,
      'data': base64Encode(payload.data),
    });

    // Send the JSON-encoded payload
    await widget.nearbyService.sendMessage(widget.device.deviceId, jsonPayload);
  }

  /* receiving */
  void handleReceivedData(Map<dynamic, dynamic> data) {
    // Extract the message string from the data
    dynamic messageString = data['message'];

    // Check if the message string is valid and of type String
    if (messageString is Uint8List) {
      debugPrint("file transfer progress");
      checkTransferComplete();
      return;
    }

    // Decode the message string into a Map
    Map<String, dynamic>? message;
    try {
      message = jsonDecode(messageString);
    } catch (e) {
      debugPrint('Error decoding message string: $e');
      return;
    }

    // Check if the message map is valid
    if (message == null) {
      debugPrint('Error: Decoded message is null.');
      return;
    }

    // Extract payload type and data from the message
    int? typeIndex = message['type'] as int?;
    String? base64Data = message['data'] as String?;

    // Check if 'typeIndex' and 'base64Data' are present
    if (typeIndex == null || base64Data == null) {
      debugPrint('Error: Received data has invalid format.');
      return;
    }

    // Decode base64 data back into bytes
    Uint8List dataBytes = base64Decode(base64Data);

    // Create payload object from decoded data
    MessageType messageType = MessageType.values[typeIndex];
    Payload payload = Payload(messageType, dataBytes);

    // Process payload based on its type
    switch (payload.type) {
      case MessageType.requestToSendSong:
        handleRequestToSendSong(payload);
        break;
      case MessageType.acceptRequest:
        handleAcceptRequest(payload);
        break;
      case MessageType.cancelRequest:
        handleCancelRequest(payload);
        break;
      case MessageType.readyToReceiveSong:
        handleReadyToReceiveSong(payload);
        break;
      case MessageType.fileTransferComplete:
        handlefileTransferComplete(payload);
        break;
      case MessageType.fileInfo:
        handlefileInfo(payload);
        break;
      case MessageType.genericMessage:
        handleGenericMessage(payload);
        break;
      case MessageType.error:
        handleErrorMessage(payload);
        break;
    }
  }

  void handleRequestToSendSong(Payload payload) {
    try {
      Uint8List dataBytes = Uint8List.fromList(payload.data);
      // Convert bytes into a JSON string
      String jsonString = utf8.decode(dataBytes);

      // Parse JSON string into a map
      Map<String, dynamic> songMap = jsonDecode(jsonString);

      // Check if required fields are present in the song map
      if (!songMap.containsKey('songName') ||
          !songMap.containsKey('artistName') ||
          !songMap.containsKey('audioPath')) {
        throw const FormatException(
            'Invalid song data: Missing required fields');
      }

      // is requesting set state
      if (!isRequestingToSend) {
        setState(() {
          isRequestingToSend = true;
          isReceiver = true;
        });
      } else {
        setState(() {
          isRequestingToSend = false;
        });
        throw const FormatException('Multiple requests sent');
      }

      // set songFileName
      String audioPath = songMap['audioPath'];
      String audioFileName = Uri.file(audioPath).pathSegments.last;
      setState(() {
        songFileName = audioFileName;
      });

      showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Request to Send"),
                ListTile(
                  title: Center(
                    child: Text(
                        '${songMap['songName']} by ${songMap['artistName']}'),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      child: const Text("Cancel"),
                      onPressed: () {
                        sendCancelRequest();
                        resetStateReceiver();
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text("Accept"),
                      onPressed: () {
                        sendAcceptRequest();
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShareSelectDirPage(
                              onDirTileTap: onDirTileTap,
                              onPageExit: checkIfDirSelected,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      // Handle any errors that occur during decoding or parsing
      debugPrint('Error handling request to send song: $e');
      sendError();
      // Optionally, you can show an error dialog to the user
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: Text("Failed to handle request to send song: $e."),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void handleAcceptRequest(Payload payload) {
    setState(() {
      isAccepted = true;
      sendFileInfo();
    });
  }

  void handleCancelRequest(Payload payload) {
    resetStateRequester();
  }

  void handleReadyToReceiveSong(Payload payload) {
    if (isAccepted) {
      debugPrint(songToSend!.audioPath);
      widget.nearbyService
          .sendFile(widget.device.deviceId, songToSend!.audioPath.toString());
    }
  }

  void handlefileTransferComplete(Payload payload) async {
    resetStateReceiver();
  }

  void handleGenericMessage(Payload payload) {
    // Handle generic message

    // You can simply display or process the message data
    String message = utf8.decode(payload.data); // Decode bytes into string

    //show pop up
    showToast(jsonEncode(message),
        context: context,
        axis: Axis.horizontal,
        alignment: Alignment.center,
        position: StyledToastPosition.bottom);

    debugPrint('Received generic message: $message');
  }

  void handleErrorMessage(Payload payload) {
    // Handle error message
    // You can display or log the error message
    debugPrint('Transaction error!');
    sendError();
    resetStateReceiver();
    resetStateRequester();
    //reset all states
    setState(() {
      // handle states
      isRequestingToSend = false;
      isRequester = false;
      isReceiver = false;
      isAccepted = false;
    });
  }

  // Implement the handle function for handling file information
  void handlefileInfo(Payload payload) {
    try {
      // Decode the file info data from payload
      String info = utf8.decode(payload.data);
      setState(() {
        songSize = int.parse(info);
      });

      // Handle the file information as needed
      // For example, you can display the file info or use it in your application logic
    } catch (e) {
      // Handle any errors that occur during processing file info
      debugPrint('Error handling file information: $e');
      // Optionally, you can show an error dialog to the user
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: Text("Failed to handle file information: $e."),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void handleConfirmationTimeout() {
    // reset state
    resetStateRequester();
  }

  void resetStateRequester() {
    setState(() {
      // handle states
      isRequestingToSend = false;
      isRequester = false;
      isAccepted = false;
      songToSend = null;
    });
  }

  void resetStateReceiver() {
    setState(() {
      // handle states
      isReceiver = false;
      pathToSaveSong = null;
      songFileName = null;
      songSize = null;
    });
  }

  void checkIfDirSelected() {
    if (pathToSaveSong == null) {
      debugPrint("pathToSong is null");
      sendCancelRequest();
      resetStateReceiver();
    }
  }

  void onDirTileTap(String pathToSaveSong) async {
    setState(() {
      this.pathToSaveSong = pathToSaveSong;
    });

    // You can request multiple permissions at once.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.manageExternalStorage,
    ].request();
    debugPrint(statuses[Permission.manageExternalStorage].toString());
    if (await Permission.manageExternalStorage.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
      sendReadyToReceive();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text("C O N N E C T E D"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.bluetooth_connected),
              title: Text('Connected to ${widget.device.deviceName}'),
            ),
            ..._buildSongTiles(context),
          ],
        ),
      ),
    );
  }
}
