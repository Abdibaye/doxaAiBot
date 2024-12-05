import 'package:doxabot/constant.dart';
import 'package:doxabot/model/message.dart';
import 'package:doxabot/provider/chat_provider.dart';
import 'package:doxabot/widget/assistant_message_widget.dart';
import 'package:doxabot/widget/my_message_widget.dart';
import 'package:doxabot/widget/widget_bottom_chat.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Provider.of<ChatProvider>(context, listen: false)
        .loadMessagesFromDB(chatId: Constant.chatMessagsBox);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            centerTitle: true,
            title: const Text(
              "Doxa",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () async {
                  final shouldStartNewChat = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Start New Chat"),
                        content: const Text(
                            "Are you sure you want to start a new chat?"),
                        actions: <Widget>[
                          TextButton(
                            child: const Text("Cancel"),
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                          ),
                          TextButton(
                            child: const Text("Yes"),
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                          ),
                        ],
                      );
                    },
                  );

                  if (shouldStartNewChat == true) {
                    chatProvider.finishChat();
                    chatProvider.startNewChat();
                    _textController.clear();
                  }
                },
                icon: Icon(
                  Icons.add_circle_outlined,
                  // color: Theme.of(context).colorScheme.surfaceVariant,
                  size: 45,
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Expanded(
                    child: chatProvider.inchatMessage.isEmpty
                        ? const Center(
                            child: Text("No messages yet"),
                          )
                        : ListView.builder(
                            itemCount: chatProvider.inchatMessage.length,
                            itemBuilder: (context, index) {
                              final message = chatProvider.inchatMessage[index];
                              if (message.role == Role.user) {
                                return MyMessageWidget(message: message);
                              } else {
                                return AssistantWidget(
                                    message: message.message.toString());
                              }
                            },
                          ),
                  ),
                  BottomChatFiel(
                    chatProvider: chatProvider,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
