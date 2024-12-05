import 'package:flutter/material.dart';
import 'package:doxabot/hive/chat_history.dart';
import 'package:doxabot/chat_detail_screen.dart';
import 'package:doxabot/provider/chat_provider.dart';
import 'package:provider/provider.dart';

class ChatHistoryScreen extends StatelessWidget {
  const ChatHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(builder: (context, chatProvider, child) {
      final chatHistories = chatProvider.chatHistory;

      return Scaffold(
        appBar: AppBar(
          title: const Text("Chat History"),
        ),
        body: SafeArea(
          child: chatHistories.isEmpty
              ? const Center(
                  child: Text("No chat sessions found"),
                )
              : ListView.builder(
                  itemCount: chatHistories.length,
                  itemBuilder: (context, index) {
                    final chat = chatHistories[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatDetailScreen(chat: chat),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: Text(
                          chat.promt
                              .split('\n')
                              .first, // Display the first line of the prompt.
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).textTheme.bodyText1?.color ??
                                    Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      );
    });
  }
}
