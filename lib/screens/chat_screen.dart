import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  String _response = "";

  static const String subscriptionKey = '4d8a58bdb2f144ba9a480e4015ad03f8';
  static const String endpoint = 'https://md-jelani-ai-chatbot.openai.azure.com/openai/deployments/gpt-35-turbo/completions?api-version=2024-05-01-preview';

  Future<void> _sendMessage(String message) async {
    final url = Uri.parse(endpoint);

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'api-key': subscriptionKey,
        },
        body: json.encode({
          "model": "gpt-35-turbo",
          "messages": [
            {"role": "system", "content": "You are an AI assistant that helps people find information."},
            {"role": "user", "content": message}
          ],
          "max_tokens": 800,
          "temperature": 0.7,
          "top_p": 0.95,
          "frequency_penalty": 0,
          "presence_penalty": 0,
          "stop": null,
          "stream": false
        }),
      );

      print('Request body: ${json.encode({
        "model": "gpt-35-turbo",
        "messages": [
          {"role": "system", "content": "You are an AI assistant that helps people find information."},
          {"role": "user", "content": message}
        ],
        "max_tokens": 800,
        "temperature": 0.7,
        "top_p": 0.95,
        "frequency_penalty": 0,
        "presence_penalty": 0,
        "stop": null,
        "stream": false
      })}'); // Debugging line

      print('Response body: ${response.body}'); // Debugging line

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          _response = jsonResponse['choices'][0]['message']['content'];
        });
      } else {
        final errorResponse = json.decode(response.body);
        setState(() {
          _response = 'Error: ${response.reasonPhrase} - ${errorResponse['error']['message']}';
        });
      }
    } catch (error) {
      setState(() {
        _response = 'Error: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat with AI')),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _response.isNotEmpty ? _response : 'Ask something...',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      _sendMessage(_controller.text);
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
