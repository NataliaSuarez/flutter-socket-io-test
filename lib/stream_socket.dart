import 'dart:async';

class StreamSocket {
  final StreamController<List<String>> _controller =
      StreamController.broadcast();

  Stream<List<String>> get data => _controller.stream;

  List<String> _list = [];

  void updateList(List<String> list) {
    _list = list;
    _dispatch();
  }

  void addToList(String value) {
    _list.add(value);
    _dispatch();
  }

  void _dispatch() {
    _controller.sink.add(_list);
  }

  void dispose() {
    _list = [];
    _controller.close();
  }
}
