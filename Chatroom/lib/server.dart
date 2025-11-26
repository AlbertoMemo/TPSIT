import 'dart:io';
import 'dart:convert';

class ClientInfo {
  Socket socket;
  String? username;
  ClientInfo(this.socket);
}

void main(List<String> args) async {
  final host = InternetAddress.anyIPv4;
  final port = 4567;
  final server = await ServerSocket.bind(host, port);
  final clients = <ClientInfo>[];

  server.listen((Socket clientSocket) {
    final client = ClientInfo(clientSocket);
    clients.add(client);

    clientSocket
        .cast<List<int>>()
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
      (data) {
        data = data.trim();
        if (client.username == null) {
          client.username = data;
          _broadcast(clients, '${client.username} si è connesso.');
        } else {
          final msg = '${client.username}: $data';
          _broadcast(clients, msg);
        }
      },
      onDone: () {
        clients.remove(client);
        if (client.username != null) {
          _broadcast(clients, '${client.username} si è disconnesso.');
        }
        clientSocket.destroy();
      },
      onError: (e) {
        clients.remove(client);
        clientSocket.destroy();
      },
    );
  });
}

void _broadcast(List<ClientInfo> clients, String message) {
  for (final c in List<ClientInfo>.from(clients)) {
    try {
      c.socket.writeln(message);
    } catch (e) {
      try {
        c.socket.destroy();
      } catch (e) {}
      clients.remove(c);
    }
  }
}
