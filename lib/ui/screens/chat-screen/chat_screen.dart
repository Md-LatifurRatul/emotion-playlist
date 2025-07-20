import 'dart:io';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:emo_music_app/model/chat_user_model.dart';
import 'package:emo_music_app/services/ai_service.dart';
import 'package:emo_music_app/ui/screens/chat-screen/widgets/model_submit_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _textController = TextEditingController();
  final ChatUserModel chatUserModel = ChatUserModel();
  // final SpeechToText _speechToText = SpeechToText();
  late AiService aiService;
  FlutterTts flutterTts = FlutterTts();
  bool isTTS = false;
  bool speechEnabled = false;
  // String _lastWords = '';
  String results = "";

  late ImagePicker imagePicker;

  bool selectedImage = false;
  late File imageSelected;
  bool isDark = false;

  @override
  void initState() {
    super.initState();
    aiService = AiService();
    imagePicker = ImagePicker();
    // _initSpeech();
    loadSpeachData();
  }

  loadSpeachData() async {
    flutterTts.setLanguage('en-US');
    flutterTts.setVoice({"name": "en-us-x-iol-local", "locale": "en-US"});

    // flutterTts.setLanguage('ja-JP');

    // flutterTts.setLanguage('ur-PK');
  }

  // void _initSpeech() async {
  //   speechEnabled = await _speechToText.initialize();
  //   setState(() {});
  // }

  // void _startListening() async {
  //   await _speechToText.listen(onResult: _onSpeechResult);
  //   setState(() {});
  // }

  // void stopListening() async {
  //   await _speechToText.stop();
  //   setState(() {});
  // }

  // void _onSpeechResult(SpeechRecognitionResult result) {
  //   _lastWords = result.recognizedWords;
  //   _textController.text = _lastWords;
  //   if (result.finalResult) {
  //     setState(() {
  //       processWithAiModel();
  //     });
  //   }
  // }

  Future<void> _pickImage() async {
    final XFile? image = await imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      selectedImage = true;
      imageSelected = File(image.path);

      ChatMessage chatMessage = ChatMessage(
        user: ChatUserModel.user,
        createdAt: DateTime.now(),
        text: '',
        medias: [
          ChatMedia(
            url: image.path,
            fileName: image.name,
            type: MediaType.image,
          ),
        ],
      );
      chatUserModel.messages.insert(0, chatMessage);
      setState(() {});
    }
  }

  void processWithAiModel() async {
    String userInput = _textController.text;
    _textController.clear();

    ChatMessage chatMessage = ChatMessage(
      user: ChatUserModel.user,
      createdAt: DateTime.now(),
      text: userInput,
    );
    chatUserModel.messages.insert(0, chatMessage);
    setState(() {});

    if (selectedImage) {
      _imageChatFeature(userInput);
    } else {
      bool isFirst = true;
      results = "";

      aiService
          .generateContentStreamChat(userInput)
          .listen(
            (response) {
              if (isFirst) {
                isFirst = false;
              } else {
                chatUserModel.messages.removeAt(0);
              }

              if (response.text != null && response.text!.isNotEmpty) {
                results += response.text!;
                ChatMessage chatMessageAI = ChatMessage(
                  user: ChatUserModel.geminiUser,
                  createdAt: DateTime.now(),
                  text: results,
                );

                if (chatUserModel.messages.isNotEmpty &&
                    chatUserModel.messages[0].user ==
                        ChatUserModel.geminiUser) {
                  chatUserModel.messages[0] = chatMessageAI;
                } else {
                  chatUserModel.messages.insert(0, chatMessageAI);
                }

                setState(() {});
              }
            },
            onError: (error) {
              print('Error streaming response: $error');

              ChatMessage chatMessageAI = ChatMessage(
                user: ChatUserModel.geminiUser,
                createdAt: DateTime.now(),
                text: "Error generating response.",
              );
              chatUserModel.messages.insert(0, chatMessageAI);
              setState(() {});
            },
            onDone: () {
              handleDone();
              print('Streaming done');
            },
          );
    }
  }

  Future<void> _imageChatFeature(String userInput) async {
    selectedImage = false;

    try {
      String? response = await aiService.getResponseWithImage(
        userInput,
        imageSelected,
      );

      results = response ?? 'No response received';

      if (isTTS) {
        flutterTts.speak(results);
      }

      ChatMessage chatMessageAI = ChatMessage(
        user: ChatUserModel.geminiUser,
        createdAt: DateTime.now(),
        text: results,
      );
      chatUserModel.messages.insert(0, chatMessageAI);
      setState(() {});
    } catch (e) {
      print('Error processing image: $e');
      ChatMessage chatMessageAI = ChatMessage(
        user: ChatUserModel.geminiUser,
        createdAt: DateTime.now(),
        text: 'Error processing image.',
      );
      chatUserModel.messages.insert(0, chatMessageAI);
      setState(() {});
    }
  }

  void handleDone() {
    if (isTTS) {
      flutterTts.speak(results);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI-Chat'),

        centerTitle: true,
        backgroundColor: Colors.blue,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),

        leading: _appBarChangeModeButton(),
        actions: [_appBarVoiceModeButton()],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg.png"),
            fit: BoxFit.cover,
            invertColors: isDark,
          ),
        ),
        child: Form(
          key: _formKey,

          child: Column(
            children: [
              _promtOutputText(),
              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(child: _textInputField()),
                    const SizedBox(width: 5),
                    // ModelSubmitButton(
                    //   bgColor: Colors.green.shade400,
                    //   icon: Icon(Icons.mic),
                    //   onPressed: () {
                    //     _startListening();
                    //   },
                    // ),
                    ModelSubmitButton(
                      bgColor: Colors.blue,
                      icon: Icon(Icons.send),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          processWithAiModel();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _promtOutputText() {
    return Expanded(
      child: DashChat(
        currentUser: ChatUserModel.user,
        onSend: (ChatMessage m) {},
        messages: chatUserModel.messages,
        readOnly: true,
      ),
    );
  }

  Widget _appBarVoiceModeButton() {
    return IconButton(
      onPressed: () {
        setState(() {
          if (isTTS) {
            isTTS = false;
          } else {
            isTTS = true;
          }
        });
      },
      icon: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(isTTS ? Icons.surround_sound : Icons.mic_off, size: 30),
      ),
    );
  }

  Widget _appBarChangeModeButton() {
    return IconButton(
      onPressed: () {
        setState(() {
          if (isDark) {
            isDark = false;
          } else {
            isDark = true;
          }
        });
      },
      icon: isDark ? Icon(Icons.sunny) : Icon(Icons.nightlight_round_outlined),
    );
  }

  Widget _textInputField() {
    return TextFormField(
      autofocus: true,
      style: TextStyle(color: Colors.black),
      onFieldSubmitted: (value) {},
      validator: (value) {
        if (value!.isEmpty) {
          return "Please Provide Text";
        }
        return null;
      },
      controller: _textController,
      onEditingComplete: () {
        processWithAiModel();
      },

      decoration: InputDecoration(
        hintText: 'Enter the question?',
        suffixIcon: IconButton(
          onPressed: () {
            _pickImage();
          },
          icon: Icon(Icons.image),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
