import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'STOMP Chat'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final String stompUrl = "ws://localhost:8080/chat";
  late StompClient _client;
  List<dynamic> messages = [];
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _client = StompClient(
        config: StompConfig(
            url: stompUrl,
            onConnect: onConnectCallback
        )
    );
    _client.activate();
  }

  void onConnectCallback(StompFrame connectFrame) {
    _client.subscribe(
      destination: "/sub/chat",
      headers: {},
      callback: (frame) {
        print(frame.body);
        setState(() {
          messages.add(jsonDecode(frame.body!));
        });
      },
    );
  }

  void _sendMessage() {
    final message = _textController.text;
    if (message.isNotEmpty) {
      _client.send(
        destination: "/pub/message",
        body: json.encode(message)
      );
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery
        .of(context)
        .size
        .height - 250;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              child: TextFormField(
                controller: _textController,
                decoration: const InputDecoration(labelText: "Send a message"),
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            SingleChildScrollView(
              child: Container(
                height: screenHeight,
                child: ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    String item = messages[index];
                    return ListTile(
                      title: Text(item),
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendMessage,
        tooltip: "Send message",
        child: const Icon(Icons.send),
      ),
    );
  }

  @override
  void dispose() {
    _client.deactivate();
    _textController.dispose();
    super.dispose();
  }
}
