import 'dart:developer';

import 'package:doxabot/provider/chat_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class BottomChatFiel extends StatefulWidget {
  const BottomChatFiel({super.key, required this.chatProvider});

  final ChatProvider chatProvider;
  @override
  State<BottomChatFiel> createState() => _BottomChatFielState();
}

class _BottomChatFielState extends State<BottomChatFiel> {
  final TextEditingController textController = TextEditingController();

  final FocusNode textFocus = FocusNode();

  @override
  void dispose() {
    textController.dispose();
    textFocus.dispose();
    super.dispose();
  }

  Future<void> sendChatMessage(
      {required String message,
      required ChatProvider chatProvider,
      required bool isTextOnly}) async {
    try {
      await chatProvider.sendMessage(message: message, isTextOnly: isTextOnly);
    } catch (e) {
      log('error : $e ');
    } finally {
      textController.clear();
      textFocus.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(
              color: Theme.of(context).textTheme.titleLarge!.color!)),
      child: Row(
        children: [
          IconButton(
              onPressed: () {
                //Pick image
              },
              icon: Icon(Icons.image)),
          SizedBox(
            height: 5,
          ),
          Expanded(
              child: TextField(
            focusNode: textFocus,
            controller: textController,
            textInputAction: TextInputAction.send,
            onSubmitted: (String value) {
              if (value.isNotEmpty) {
                sendChatMessage(
                    message: textController.text,
                    chatProvider: widget.chatProvider,
                    isTextOnly: true);
              }
            },
            decoration: InputDecoration.collapsed(
                hintText: 'Enter a promt...',
                border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(30))),
          )),
          GestureDetector(
            onTap: () {
              //Send Image
              if (textController.text.isNotEmpty) {
                sendChatMessage(
                    message: textController.text,
                    chatProvider: widget.chatProvider,
                    isTextOnly: true);
              }
            },
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.deepPurple),
                margin: const EdgeInsets.all(5.0),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.arrow_upward,
                    color: Colors.white,
                  ),
                )),
          )
        ],
      ),
    );
  }
}
