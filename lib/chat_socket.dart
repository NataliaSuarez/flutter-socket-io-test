import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatSocket {
  IO.Socket? _socket;
  IO.Socket? get socket => _socket;

  ChatSocket() {
    _connectAndListen();
  }
  //

  void _connectAndListen() {
    _socket = IO.io('http://192.168.1.37:81', <String, dynamic>{
      'autoConnect': false,
      'transports': ['websocket'],
    });
    if (_socket != null) {
      // handle connect
      _socket!.connect();
      _socket!.onConnect((_) {
        debugPrint('Connection established');
      });
      _socket!.onConnectError((err) {
        debugPrint('onConnectError');
        debugPrint(err.toString());
      });
      // handle error
      _socket!.onError((err) {
        debugPrint('onError');
        debugPrint(err.toString());
      });
      // dispose
      _socket!.onDisconnect((_) => debugPrint('Connection Disconnection'));
    }
  }

  void dispose() {
    _socket!.disconnect();
    _socket!.dispose();
  }
}
