import 'dart:io';

Map<WebSocket, String> clients = {};

void main() async {
  var server = await HttpServer.bind(
    InternetAddress.anyIPv4,
    8080,
  );

  print("Chatroom server listening on port 8080");

  server.listen((HttpRequest request) async {
    if (WebSocketTransformer.isUpgradeRequest(request)) {
      var socket = await WebSocketTransformer.upgrade(request);
      handleClient(socket);
    } else {
      request.response
        ..statusCode = HttpStatus.forbidden
        ..write("WebSocket connections only")
        ..close();
    }
  });
}

void handleClient(WebSocket socket) {
  print("Client connected");

  String? username;

  socket.listen(
    (data) {
      final msg = data.toString();
      if (username == null) {
        username = msg;
        clients[socket] = username!;
        broadcast("SERVER: $username è entrato nella chat");
        return;
      }
      broadcast("$username: $msg");
    },
    onDone: () {
      if (username != null) {
        clients.remove(socket);
        broadcast("SERVER: $username ha lasciato la chat");
      }
      print("Client disconnected");
    },
  );
}

void broadcast(String message) {
  print(message);
  for (var client in clients.keys) {
    client.add(message);
  }
}
