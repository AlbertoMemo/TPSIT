import 'dart:io';
import 'dart:convert';

Future<void> main() async {
  final defaultHost = '192.168.3.3';
  final port = 4567;

  stdout.write('Enter server host (default $defaultHost): ');
  final h = stdin.readLineSync();
  final serverHost = (h != null && h.isNotEmpty) ? h : defaultHost;

  stdout.write('Enter username: ');
  final username = stdin.readLineSync();
  if (username == null || username.trim().isEmpty) exit(1);

  final socket = await Socket.connect(serverHost, port);
  socket.writeln(username.trim());

  socket
      .cast<List<int>>()
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .listen((line) {
    print(line);
  }, onDone: () {
    exit(0);
  });

  stdin.listen((data) {
    final text = String.fromCharCodes(data).trim();
    if (text.toLowerCase() == '/quit') {
      socket.destroy();
      exit(0);
    }
    if (text.isNotEmpty) socket.writeln(text);
  });
}

