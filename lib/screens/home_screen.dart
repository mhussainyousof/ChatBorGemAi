import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemini_chat_bot/helper/persion_fuction.dart';
import 'package:gemini_chat_bot/provider/providers.dart';
import 'package:gemini_chat_bot/repo/chat_repo.dart';
import 'package:gemini_chat_bot/screens/send_image_screen.dart';
import 'package:gemini_chat_bot/utils/image_picker.dart';
import 'package:gemini_chat_bot/widgets/widget_messages_list.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final TextEditingController _messageController;
  final apiKey = dotenv.env['API_KEY'] ?? '';
  XFile? selectedImage;

  Future<void> _pickImage() async {
    final pickedImage = await pickImage(); // your own util function
    if (pickedImage != null) {
      setState(() {
        selectedImage = pickedImage;
      });
    }
  }

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
             
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   if (selectedImage != null)
                    Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(selectedImage!.path),
                          height: 100,
                          width: 100,
                          fit: BoxFit.fill,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedImage = null;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(Icons.close,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:  const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 3,
                    ),
                    margin:   EdgeInsets.only(top:  selectedImage != null ? 5 : 20),
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
                          onPressed: _pickImage,
                          // () {
                          //   Navigator.of(context).push(
                          //     MaterialPageRoute(
                          //       builder: (_) => const SendImageScreen(),
                          //     ),
                          //   );
                          // },
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
            ],
          ),
        ),
      ),
    );
  }

  Future sendMessage() async {
    final message = _messageController.text.trim();

    if (message.isEmpty && selectedImage == null) return;

    try {
      if (selectedImage != null) {
        await ref.read(chatProvider).sendMessage(
              image: selectedImage,
              apiKey: apiKey,
              promptText: message,
            );
      } else {}
      await ref
          .read(chatProvider)
          .sendTextMessage(textPrompt: message, apiKey: apiKey);
      _messageController.clear();
      setState(() {
        selectedImage = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
