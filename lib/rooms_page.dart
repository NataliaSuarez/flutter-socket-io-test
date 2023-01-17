import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:wstest/chat_room_args.dart';
import 'package:wstest/chat_socket.dart';
import 'package:wstest/stream_socket.dart';

class RoomsPage extends StatefulWidget {
  const RoomsPage({
    super.key,
  });
  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  final IO.Socket socket = ChatSocket().socket!;
  @override
  void initState() {
    joinRooms();
    super.initState();
  }

  StreamSocket streamSocket = StreamSocket();
  void joinRooms() {
    socket.on('new_room', (room) {
      debugPrint('en el event new_room');
      streamSocket.addToList(room);
    });
    socket.emit('event_rooms');
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
}
