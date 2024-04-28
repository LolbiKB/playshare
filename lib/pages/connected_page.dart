import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
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
  late final dynamic playListProvider;
  late StreamSubscription receivedDataSubscription;

  // handle states
  bool isRequestingToSend = false;
  bool isRequester = false;
  bool isReceiver = false;
  bool isAccepted = false;
  Song? songToSend;
  String? pathToSaveSong;

  @override
  void initState() {
    super.initState();

    // get playlist provider
    playListProvider = Provider.of<PlayListProvider>(context, listen: false);

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

  /* sending */
  Future<Uint8List> readFile(String filePath) async {
    File file = File(filePath);
    return await file.readAsBytes();
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
                Timer(Duration(seconds: 10), () {
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

  Future<void> sendRequestAccept() async {
    try {
      // Create payload with the message type (RequestToSendSong) and 4 bytes of all ones
      Payload payload = Payload(MessageType.requestToSendSong,
          Uint8List.fromList([255, 255, 255, 255]));

      // Encode payload into JSON format
      String jsonPayload = jsonEncode({
        'type': payload.type.index,
        'data': base64Encode(payload.data),
      });

      // Send the JSON-encoded payload
      await widget.nearbyService
          .sendMessage(widget.device.deviceId, jsonPayload);

      // Optionally, you may perform any other necessary actions here after sending the request
    } catch (e) {
      // Handle errors
      debugPrint('Error sending request accept: $e');
      // Show error dialog or handle error as needed
    }
  }

  Future<void> sendRequestReadyToReceive() async {
    try {
      // Create payload with the message type (RequestToSendSong) and 4 bytes of all ones
      Payload payload = Payload(MessageType.requestToSendSong,
          Uint8List.fromList([0, 255, 255, 255]));

      // Encode payload into JSON format
      String jsonPayload = jsonEncode({
        'type': payload.type.index,
        'data': base64Encode(payload.data),
      });

      // Send the JSON-encoded payload
      await widget.nearbyService
          .sendMessage(widget.device.deviceId, jsonPayload);

      // Optionally, you may perform any other necessary actions here after sending the request
    } catch (e) {
      // Handle errors
      debugPrint('Error sending ready to receive: $e');
      // Show error dialog or handle error as needed
    }
  }

  Future<void> sendRequestCancel() async {
    try {
      // Create payload with the message type (RequestToSendSong) and 4 bytes of all zeroes
      Payload payload = Payload(
          MessageType.requestToSendSong, Uint8List.fromList([0, 0, 0, 0]));

      // Encode payload into JSON format
      String jsonPayload = jsonEncode({
        'type': payload.type.index,
        'data': base64Encode(payload.data),
      });

      // Send the JSON-encoded payload
      await widget.nearbyService
          .sendMessage(widget.device.deviceId, jsonPayload);

      // Optionally, you may perform any other necessary actions here after sending the request
    } catch (e) {
      // Handle errors
      debugPrint('Error sending request cancel: $e');
      // Show error dialog or handle error as needed
    }
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

  // Function to send song
  Future<void> sendSong(String filePath) async {
    // Read the file data
    Uint8List fileData = await readFile(filePath);

    // Create payload with the message type and file data
    Payload payload = Payload(MessageType.sendingSong, fileData);

    // Encode payload into JSON format
    String jsonPayload = jsonEncode({
      'type': payload.type.index,
      'data': base64Encode(payload.data),
    });

    // Send the JSON-encoded payload
    await widget.nearbyService.sendMessage(widget.device.deviceId, jsonPayload);
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
    String? messageString = data['message'] as String?;

    // Check if the message string is present
    if (messageString == null) {
      debugPrint('Error: Received data is missing the "message" field.');
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

    // Check if 'typeIndex' and 'base64Data' are null
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
      case MessageType.sendingSong:
        handleSendingSong(payload);
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
      // Decode payload data from Base64 into bytes

      Uint8List dataBytes = Uint8List.fromList(payload.data);

      // check for all zeroes or all ones
      if (isRequestingToSend) {
        // Check if the first 4 bytes of the received data are all zeroes or all ones
        bool isAccepted = dataBytes.length >= 4 &&
            dataBytes[0] == 0 &&
            dataBytes[1] == 0 &&
            dataBytes[2] == 0 &&
            dataBytes[3] == 0;
        bool isRejected = dataBytes.length >= 4 &&
            dataBytes[0] == 255 &&
            dataBytes[1] == 255 &&
            dataBytes[2] == 255 &&
            dataBytes[3] == 255;
        bool isReadyToAccept = dataBytes.length >= 4 &&
            dataBytes[0] == 0 &&
            dataBytes[1] == 255 &&
            dataBytes[2] == 255 &&
            dataBytes[3] == 255;
        if (isAccepted) {
          // accepted
          this.isAccepted = isAccepted;
        } else if (isRejected) {
          resetStateRequester();
        } else if (this.isAccepted || isReadyToAccept) {
          debugPrint("Passed this point!");
          // proceed to send
          sendSong(songToSend!.audioPath);
        }

        return;
      }

      // Convert bytes into a JSON string
      String jsonString = utf8.decode(dataBytes);

      // Parse JSON string into a map
      Map<String, dynamic> songMap = jsonDecode(jsonString);

      // Check if required fields are present in the song map
      if (!songMap.containsKey('songName') ||
          !songMap.containsKey('artistName')) {
        throw const FormatException(
            'Invalid song data: Missing required fields');
      }

      // is requesting set state
      if (!isRequestingToSend) {
        setState(() {
          isRequestingToSend = true;
          isRequester = true;
        });
      } else {
        setState(() {
          isRequestingToSend = false;
        });
        throw const FormatException('Multiple requests to send');
      }

      // Now you can use the song object as needed
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Sending Request"),
            content: Center(
                child:
                    Text('${songMap['songName']} by ${songMap['artistName']}')),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                  child: const Text("Accept"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ShareSelectDirPage(
                                onDirTileTap: onDirTileTap)));
                  }),
            ],
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
    //reset all states
    setState(() {
      // handle states
      isRequestingToSend = false;
      isRequester = false;
      isReceiver = false;
      isAccepted = false;
    });
  }

  void handleSendingSong(Payload payload) {
    try {
      // get song name
      // Find the index of the last '/' character to get the start of the file name
      int fileNameStartIndex = songToSend!.audioPath.lastIndexOf('/') + 1;
      String songFullName = songToSend!.audioPath.substring(fileNameStartIndex);

      // Convert payload data to base64-encoded string
      String base64Data = utf8.decode(payload.data);

      // Decode base64 data back into bytes
      Uint8List dataBytes = base64Decode(base64Data);

      // Construct the full file path including the file name
      String fullPath = '$pathToSaveSong/$songFullName';

      // Write the received song data to the specified file path
      File(fullPath).writeAsBytes(dataBytes);

      // Optionally, you may perform any other necessary actions here after saving the song data
    } catch (e) {
      // Handle errors
      debugPrint('Error handling receiving song: $e');
      // Show error dialog or handle error as needed
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
    });
  }

  void resetStateReceiver() {
    setState(() {
      // handle states
      isReceiver = false;
    });
  }

  void onDirTileTap(String pathToSaveSong) {
    this.pathToSaveSong = pathToSaveSong;
    sendRequestReadyToReceive();
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
