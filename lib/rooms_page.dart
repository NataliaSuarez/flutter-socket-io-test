import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:wstest/chat_room_args.dart';
import 'package:wstest/stream_socket.dart';

class RoomsPage extends StatefulWidget {
  const RoomsPage({
    super.key,
  });

  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  final TextEditingController _controller = TextEditingController();
  IO.Socket? socket;
  @override
  void initState() {
    connectAndListen();
    super.initState();
  }
  //

  StreamSocket streamSocket = StreamSocket();
  void connectAndListen() {
    socket = IO.io('http://192.168.1.37:81', <String, dynamic>{
      'autoConnect': false,
      'transports': ['websocket'],
    });
    if (socket != null) {
      // handle connect
      socket!.connect();
      socket!.onConnect((_) {
        debugPrint('Connection established');
      });
      socket!.onConnectError((err) {
        debugPrint('onConnectError');
        debugPrint(err.toString());
      });
      // handle error
      socket!.onError((err) {
        debugPrint('onError');
        debugPrint(err.toString());
      });
      // events
      socket!.on('new_room', (room) {
        debugPrint('en el event new_room');
        streamSocket.addToList(room);
      });
      socket!.emit('event_rooms');
      // dispose
      socket!.onDisconnect((_) => debugPrint('Connection Disconnection'));
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> items = [];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rooms'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: streamSocket.data,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.connectionState == ConnectionState.done) {
                    return const Text('done');
                  } else if (snapshot.hasError) {
                    return const Text('Error!');
                  } else {
                    items = snapshot.data ?? [];
                    return ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return TextButton(
                          onPressed: () {
                            var args = ChatRoomPageArguments(
                                'Chat room', items[index].toString());
                            Navigator.pushNamed(context, '/chat',
                                arguments: args);
                          },
                          child: Text(
                            items[index].toString(),
                          ),
                        );
                      },
                      itemCount: items.length,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
