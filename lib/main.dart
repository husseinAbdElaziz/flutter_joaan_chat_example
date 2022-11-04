// import 'dart:io';

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:socket_io_client/socket_io_client.dart';
import 'package:http/http.dart' as http;

import 'chat_class.dart';
import 'debouncer.dart';

int otherUserId = 205;

Future<Chat> fetchChat() async {
  final response = await http.get(
    Uri.parse('https://chat.joaan.me/chat?id=$otherUserId'),
    // Send authorization headers to the backend.
    headers: {
      HttpHeaders.authorizationHeader:
          'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJodXNzZWluX2FiZGVsYXppeiIsInJvbGUiOiIxMDAiLCJjcmVhdGVkIjoxNjY3MDgwNDI3MTMzLCJleHAiOjE2Njc2ODUyMjcsInVzZXJJZCI6MX0.0nTETq9mqz_AdMTXLNq3QVSZsQqYNJzy2cYkdjYmjBW4-0BfKaDzE4PUqPYeTrBjnGSFH3me9sC6D8HQTuEFdg',
    },
  );
  final responseJson = jsonDecode(response.body);

  return Chat.fromJson(responseJson);
}

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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  String _messageToSend = '';
  var _isTyping = false;

  String? _username = '';

  late List<ChatData> _chatData = [];

  late Socket socket;

  final _debouncer = Debouncer(milliseconds: 500);

  @override
  void initState() {
    socket = io(
        'http://chat.joaan.me:9090',
        OptionBuilder().setTransports(['websocket']).setExtraHeaders({
          'authorization':
              'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJodXNzZWluX2FiZGVsYXppeiIsInJvbGUiOiIxMDAiLCJjcmVhdGVkIjoxNjY3MDgwNDI3MTMzLCJleHAiOjE2Njc2ODUyMjcsInVzZXJJZCI6MX0.0nTETq9mqz_AdMTXLNq3QVSZsQqYNJzy2cYkdjYmjBW4-0BfKaDzE4PUqPYeTrBjnGSFH3me9sC6D8HQTuEFdg'
        }).build());

    socket.connect();
    print(socket.ids);

    socket.onConnectError((data) {
      print(data);
    });
    socket.onConnect((data) {
      print('connected');
    });
    socket.on(
        'typing',
        (data) => {
              setState(
                () => _isTyping =
                    data['userId'] == otherUserId ? data['isTyping'] : false,
              )
            });
    socket.on('messageAdded', (data) {
      setState(() {
        ChatData val = ChatData(
            id: data['id'],
            createdAt: data['createdAt'],
            updatedAt: data['updatedAt'],
            isReaded: data['isReaded'],
            message: data['message'],
            messageFrom: data['messageFrom'],
            messageTo: data['messageTo']);
        _chatData.add(val);
      });
    });

    fetchChat().then((value) {
      setState(() {
        _username = value.userData?.displayName;
        _chatData = value.chatData!;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                height: 400,
                alignment: AlignmentDirectional.center,
                child: ListView(
                  children: _chatData
                      .map((item) =>
                          Text(item.message!, textAlign: TextAlign.center))
                      .toList(),
                )),
            Text(_isTyping ? '$_username typing' : ''),
            TextField(
              onChanged: (value) {
                setState(() {
                  _messageToSend = value;
                });

                socket.emit(
                    'onTyping', {'userId': otherUserId, 'isTyping': true});
                _debouncer.run(() => socket.emit(
                    'onTyping', {'userId': otherUserId, 'isTyping': false}));
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Message',
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blue),
              child: const Text('send'),
              onPressed: () {
                socket.emit('addMessage',
                    {'messageTo': otherUserId, 'message': _messageToSend});
              },
            )
          ],
        ),
      ),
    );
  }
}
