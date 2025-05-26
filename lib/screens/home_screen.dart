import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemini_chat_bot/helper/persion_fuction.dart';
import 'package:gemini_chat_bot/provider/providers.dart';
import 'package:gemini_chat_bot/screens/send_image_screen.dart';
import 'package:gemini_chat_bot/widgets/widget_messages_list.dart';
import 'package:iconsax/iconsax.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final TextEditingController _messageController;
  final apiKey = dotenv.env['API_KEY'] ?? '';

  @override
  void initState() {
    _messageController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer(builder: (context, ref, child) {
                return Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        ref.read(authProvider).signout();
                      },
                      icon: const Icon(
                        Iconsax.logout,
                      ),
                    ),
                    const Text('Logout'),
                  ],
                );
              }),
              // Message List
              Expanded(
                child: MessagesList(
                  userId: FirebaseAuth.instance.currentUser!.uid,
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 3,
                ),
                margin: const EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Row(
                  children: [
                    //! Message Text field
                    Expanded(
                      child: TextField(
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        controller: _messageController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Ask any question',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),

                    // Image Button
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SendImageScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Iconsax.gallery,
                      ),
                    ),

                    // Send Button
                    IconButton(
                        onPressed: sendMessage,
                        icon: const Icon(Iconsax.send_1)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;
    await ref.read(chatProvider).sendTextMessage(
          apiKey: apiKey,
          textPrompt: _messageController.text,
        );
    _messageController.clear();
  }
}
