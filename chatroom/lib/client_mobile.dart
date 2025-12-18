import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

void main() {
  runApp(const ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatroom',
      theme: ThemeData(useMaterial3: true),
      home: const ConnectPage(),
    );
  }
}

class ConnectPage extends StatefulWidget {
  const ConnectPage({Key? key}) : super(key: key);
  @override
  State<ConnectPage> createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
  final _hostCtrl = TextEditingController(text: '192.168.3.3');
  final _portCtrl = TextEditingController(text: '4567');
  final _userCtrl = TextEditingController();

  @override
  void dispose() {
    _hostCtrl.dispose();
    _portCtrl.dispose();
    _userCtrl.dispose();
    super.dispose();
  }

  void _connect() {
    final host = _hostCtrl.text.trim();
    final port = int.tryParse(_portCtrl.text.trim()) ?? 4567;
    final username = _userCtrl.text.trim();
    if (username.isEmpty) return;
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ChatPage(host: host, port: port, username: username)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connect to chat')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
                controller: _hostCtrl,
                decoration: const InputDecoration(labelText: 'Server host')),
            TextField(
                controller: _portCtrl,
                decoration: const InputDecoration(labelText: 'Port'),
                keyboardType: TextInputType.number),
            TextField(
                controller: _userCtrl,
                decoration: const InputDecoration(labelText: 'Username')),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _connect, child: const Text('Connect')),
          ],
        ),
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  final String host;
  final int port;
  final String username;
  const ChatPage(
      {Key? key,
      required this.host,
      required this.port,
      required this.username})
      : super(key: key);
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Socket? _socket;
  final _messages = <String>[];
  final _inputCtrl = TextEditingController();

  StreamSubscription<String>? _sub;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _socket?.destroy();
    _inputCtrl.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    try {
      final s = await Socket.connect(widget.host, widget.port,
          timeout: const Duration(seconds: 5));
      setState(() => _socket = s);
      s.writeln(widget.username);
      final transformer = s
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter());
      _sub = transformer.listen((line) {
        setState(() => _messages.add(line));
      }, onDone: () {
        setState(() => _messages.add('Disconnected from server.'));
      }, onError: (e) {
        setState(() => _messages.add('Socket error: $e'));
      });
    } catch (e) {
      setState(() => _messages.add('Unable to connect: $e'));
    }
  }

  void _send() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    _socket?.writeln(text);
    _inputCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat - ${widget.username}')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, i) => ListTile(title: Text(_messages[i])),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                        controller: _inputCtrl,
                        onSubmitted: (_) => _send(),
                        decoration:
                            const InputDecoration(hintText: 'Type a message'))),
                IconButton(icon: const Icon(Icons.send), onPressed: _send),
              ],
            ),
          )
        ],
      ),
    );
  }
}
