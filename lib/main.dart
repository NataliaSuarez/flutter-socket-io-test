import 'package:flutter/material.dart';
import 'package:wstest/chat_room_page.dart';
import 'package:wstest/rooms_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const title = 'Chat Demo';
    return MaterialApp(
      title: title,
      initialRoute: '/',
      routes: {
        '/': (context) => const RoomsPage(),
        ChatRoomPage.routeName: (context) => const ChatRoomPage(),
      },
    );
  }
}
