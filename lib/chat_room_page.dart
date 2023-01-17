import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:wstest/chat_room_args.dart';
import 'package:wstest/stream_socket.dart';

class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage({
    super.key,
  });
  static const routeName = '/chat';

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
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
      socket!.on('new_message', (data) {
        debugPrint('en el event new_message');
        streamSocket.addToList('${data["message"]} - ${data["sender"]}');
      });
      // socket!.emit('event_join', 'test');
      // dispose
      socket!.onDisconnect((_) => debugPrint('Connection Disconnection'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as ChatRoomPageArguments;
    List<String> items = [];
    socket!.emit('event_join', args.room);
    return Scaffold(
      appBar: AppBar(
        title: Text('${args.title} - ${args.room}'),
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
                        return Text(items[index].toString());
                      },
                      itemCount: items.length,
                    );
                  }
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Form(
                    child: TextFormField(
                      controller: _controller,
                      decoration:
                          const InputDecoration(labelText: 'Send a message'),
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      socket!.emit('event_message',
                          {"room": args.room, "message": _controller.text});
                      _controller.clear();
                    },
                    icon: Icon(
                      Icons.send,
                      color: Colors.blueAccent[200],
                    )),
              ],
            )
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
