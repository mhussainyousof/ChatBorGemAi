import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemini_chat_bot/provider/providers.dart';
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
  late final ScrollController _scrollController;
  bool _showScrollToBottomBtn = false;
   bool _isSending = false;


  @override
  void initState() {
    _messageController = TextEditingController();
    _scrollController = ScrollController();
 SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _scrollController.addListener(() {
      final atBottom = _scrollController.offset <=
          _scrollController.position.minScrollExtent + 20;

      if (atBottom && _showScrollToBottomBtn) {
        setState(() => _showScrollToBottomBtn = false);
      } else if (!atBottom && !_showScrollToBottomBtn) {
        setState(() => _showScrollToBottomBtn = true);
      }
    });

    super.initState();
  }

  Future<void> _pickImage() async {
    final pickedImage = await pickImage(); 
    if (pickedImage != null) {
      setState(() {
        selectedImage = pickedImage;
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return
        Scaffold(
          floatingActionButton: _showScrollToBottomBtn  ? Align(
            
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 90),
              child: FloatingActionButton.small(
                
                backgroundColor: Colors.black45,
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
                onPressed: () {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                },
                child: const Icon(Iconsax.arrow_down_1),
              ),
            ),
          ): null,
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: true,
          body: AnnotatedRegion<SystemUiOverlayStyle>(
             value: const SystemUiOverlayStyle(
          
        ),
            child: SafeArea(
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
                          const Text(
                            "Let's Talk 🐦‍🔥 ",
                            style: TextStyle(fontSize: 20),
                          ),
                          const Spacer(),
                          const Text('Logout'),
                          IconButton(
                            onPressed: () {
                              ref.read(authProvider).signout(ref);
                            },
                            icon: const Icon(
                              Iconsax.logout,
                            ),
                          ),
                        ],
                      );
                    }),
                    // Message List
                    Expanded(
                      child: MessagesList(
                        scrollController: _scrollController,
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
                                          color: Colors.white, size: 15),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 3,
                          ),
                          margin: EdgeInsets.only(
                              top: selectedImage != null ? 5 : 20),
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
                                    hintText: 'Waiting for your question',
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
                                icon: const Icon(
                                  Iconsax.gallery,
                                ),
                              ),
            
                              //! Send Button
                              IconButton(
                                  onPressed: _isSending ? null :   sendMessage,
                                  icon:  _isSending ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                     child: CircularProgressIndicator(strokeWidth: 2),
                                  )  : const Icon(Iconsax.send_1)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
              ),
            ),
          ),
        );
  }

  Future sendMessage() async {
    final message = _messageController.text.trim();

    if (message.isEmpty && selectedImage == null) return;
      setState(() {
    _isSending = true;
      _messageController.clear();
  });

    try {
      if (selectedImage != null) {
        await ref.read(chatProvider).sendMessage(
              image: selectedImage,
              apiKey: apiKey,
              promptText: message,
            );
      } else {
        await ref
            .read(chatProvider)
            .sendTextMessage(textPrompt: message, apiKey: apiKey);
      setState(() {
        selectedImage = null;
      });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }finally{
      setState(() {
        _isSending = false;
      });
    }
  }
}
