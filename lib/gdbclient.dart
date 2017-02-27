// Copyright (c) 2016, Ravi Teja Gudapati. All rights reserved.

import 'dart:async';
import 'dart:io';

const String kCmdReadGeneralRegister = "g";

class Client {
  final ClientCommBase _comm;

  final ClientCodecBase _codec = new ClientCodec();

  Client({ClientCommBase aComm})
      : _comm = aComm {
    if(!aComm.isClosed) {
      throw new Exception("Communication is already open!");
    }
  }

  Future open() async {
    await _comm.open();
  }

  Future close() async {
    await _comm.close();
  }

  bool get isClosed => _comm.isClosed;

  Future<String> getGeneralRegisters() async {
    if(isClosed) {return null;}

    String lCmd = kCmdReadGeneralRegister;
    String lPacked = _codec.pack(lCmd);

    await _comm.sendStr(lPacked);

    //TODO wait for reply

    return "";  //TODO fix this
  }
}

abstract class ClientCodecBase {
  String pack(String aMsg);
}

class ClientCodec extends ClientCodecBase {
  String pack(String aMsg) {
    int lChecksum =
        aMsg.codeUnits.fold(0, (int aPrev, int aNew) => aPrev + aNew);
    lChecksum &= 0xFF;

    String lCsumStr = lChecksum.toRadixString(16);
    if (lCsumStr.length == 1) {
      lCsumStr = "0" + lCsumStr;
    }

    return "\$${aMsg}#${lCsumStr}";
  }
}

abstract class ClientCommBase {
  /// Opens the communication
  Future open();

  /// Closes communication
  Future close();

  Future sendStr(final String aStr);

  bool get isClosed;
}

class ClientComm extends ClientCommBase {
  final String mHost;

  final int mPort;

  ClientComm({this.mHost: "127.0.0.1", this.mPort: 2331}) {}
  Socket _socket;

  Future open() async {
    _socket = await Socket.connect(mHost, mPort);

    _socket.listen((List<int> aRec) {
      String lRec = new String.fromCharCodes(aRec);
      print("Receiving data...");
      print(aRec);
      print(lRec);
    });
  }

  Future close() async {
    if (_socket != null) {
      await _socket.close();
      _socket = null;
    }
  }

  bool get isClosed => _socket == null;

  Future sendStr(final String aStr) async {
    await _socket.write(aStr);
  }

  //TODO
}
