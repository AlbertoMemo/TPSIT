import 'dart:convert';
import 'dart:io';

void main() async {
  stdout.write("Inserisci username: ");
  var username = stdin.readLineSync()!;
  var socket = await WebSocket.connect("ws://localhost:8080");
  socket.add(username);
  socket.listen((data) {
    print(data);
  });
  stdin.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
    socket.add(line);
  });
}
