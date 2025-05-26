import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:gemini_chat_bot/helper/persion_fuction.dart';
import '/models/message.dart';

class MessageTile extends StatelessWidget {
  final Message message;
  final bool isOutgoing;

  const MessageTile({
    super.key,
    required this.message,
    required this.isOutgoing,
  });

  @override
  Widget build(BuildContext context) {
    // final bgColor =
    //     isOutgoing ? const Color.fromARGB(255, 103, 255, 116) : Colors.white;
    final textColor = isOutgoing ? Colors.black87 : Colors.black87;
    final align = isOutgoing ? Alignment.centerRight : Alignment.centerLeft;

    return Align(
      alignment: align,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          gradient: isOutgoing
              ? const LinearGradient(
                  colors: [
                    Color.fromARGB(
                        255, 177, 201, 253), // deep blue (Google blue variant)
                    Color.fromARGB(
                        255, 126, 255, 238), // teal/greenish (modern AI vibe)
                  ],
                  end: Alignment.topLeft,
                  begin: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.white,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),

          // color: bgColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isOutgoing ? 16 : 0),
            topRight: Radius.circular(isOutgoing ? 0 : 16),
            bottomLeft: const Radius.circular(16),
            bottomRight: const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              blurStyle: BlurStyle.outer,
              color: isOutgoing ? Colors.deepOrange : Colors.green,
              blurRadius: 3,
              // spreadRadius: isOutgoing ? 0 : 1,
              offset: isOutgoing ? const Offset(0, 0) : const Offset(-1, -1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Directionality(
              textDirection: isPersianText(message.message)
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: GestureDetector(
                onLongPress: (){
                  Clipboard.setData(ClipboardData(text: message.message));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Text Copied')));
                },
                child: MarkdownBody(
                  data: message.message,
                  styleSheet: MarkdownStyleSheet(
                    p: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
                    strong: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    em: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: textColor.withOpacity(0.7),
                    ),
                    code: TextStyle(
                      backgroundColor: Colors.grey.shade200,
                      color: Colors.deepPurple,
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            if (message.imageUrl != null) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  message.imageUrl!,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
