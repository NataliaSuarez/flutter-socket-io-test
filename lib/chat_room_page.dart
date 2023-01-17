import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:wstest/chat_room_args.dart';
import 'package:wstest/chat_socket.dart';
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
  final IO.Socket socket = ChatSocket().socket!;
  @override
  void initState() {
    joinChat();
    super.initState();
  }
  //

  StreamSocket streamSocket = StreamSocket();
  void joinChat() {
    socket.on('new_message', (data) {
      debugPrint('en el event new_message');
      streamSocket.addToList('${data["message"]} - ${data["sender"]}');
    });
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as ChatRoomPageArguments;
    List<String> items = [];
    socket.emit('event_join', args.room);
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
                      socket.emit('event_message',
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
}
