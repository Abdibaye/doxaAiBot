import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AssistantWidget extends StatelessWidget {
  const AssistantWidget({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft, // Align content to the left
      child: Container(
        constraints: BoxConstraints(
          // Restrict max height based on the screen height (if applicable)
          maxHeight: MediaQuery.of(context).size.height * 3,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.only(bottom: 8),
        child: (message?.isEmpty ?? true)
            ? const SizedBox(
                width: 50,
                height: 24,
                child: SpinKitThreeBounce(
                  color: Colors.blue,
                  size: 20.0,
                ),
              )
            : MarkdownBody(
                selectable: true,
                data: message,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
      ),
    );
  }
}
