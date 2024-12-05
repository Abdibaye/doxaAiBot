import 'package:flutter/material.dart';
import 'package:doxabot/hive/chat_history.dart';

class ChatDetailScreen extends StatelessWidget {
  final ChatHistory chat;

  const ChatDetailScreen({Key? key, required this.chat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Parse messages from the saved chat prompt.
    final messages = _extractMessages(chat.promt);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat Details"),
      ),
      body: SafeArea(
        child: messages.isEmpty
            ? const Center(
                child: Text("No messages in this session"),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isUser = message['role'] == 'User';

                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      decoration: BoxDecoration(
                        color: isUser
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.all(15),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        message['text'] ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          color: isUser
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  // Helper function to parse messages from the prompt.
  List<Map<String, String>> _extractMessages(String promt) {
    final List<Map<String, String>> messageList = [];
    final lines = promt.split('\n');

    for (final line in lines) {
      if (line.startsWith('User:')) {
        messageList
            .add({'role': 'User', 'text': line.replaceFirst('User: ', '')});
      } else if (line.startsWith('Assistant:')) {
        messageList.add({
          'role': 'Assistant',
          'text': line.replaceFirst('Assistant: ', '')
        });
      }
    }

    return messageList;
  }
}
