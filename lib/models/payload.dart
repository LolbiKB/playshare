enum MessageType {
  requestToSendSong,
  acceptRequest,
  cancelRequest,
  readyToReceiveSong,
  fileTransferComplete,
  fileInfo,
  genericMessage,
  error
}

class Payload {
  MessageType type;
  List<int> data;

  Payload(this.type, this.data);

  List<int> encode() {
    // Encode type into the first byte
    int firstByte = type.index << 6;

    // Combine the first byte with the second byte (reserved)
    List<int> header = [firstByte, 0];

    // Combine the header with the payload data
    List<int> encodedData = [...header, ...data];

    return encodedData;
  }

  static Payload decode(List<int> encodedData) {
    // Decode type from the first 2 bits of the first byte
    MessageType type = MessageType.values[encodedData[0] >> 6];

    // Extract payload data (excluding the header)
    List<int> data = encodedData.sublist(2);

    return Payload(type, data);
  }
}
