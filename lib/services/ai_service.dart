import 'dart:io';

import 'package:emo_music_app/core/ai_model.dart';
import 'package:emo_music_app/core/secret_key.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mime/mime.dart';

class AiService {
  late GenerativeModel model;
  late ChatSession chat;

  List<Content> conversationHistory = [];

  final String _modelName = aiModel;
  AiService() {
    model = GenerativeModel(model: _modelName, apiKey: SecretKey.apiKey);

    chat = model.startChat();
  }

  Future<String?> getResponse(String prompt) async {
    try {
      final content = [Content.text(prompt)];

      final response = await model.generateContent(content);
      // print(response.text);
      return response.text;
    } catch (e) {
      print('Error from ai_chat: ${e.toString()}');
      return null;
    }
  }

  Future<String?> getResponseWithImage(String prompt, File imageFile) async {
    try {
      final imageData = await imageFile.readAsBytes();
      final mimeType = lookupMimeType(imageFile.path) ?? "image/jpeg";
      final content = Content.multi([
        TextPart(prompt),
        DataPart(mimeType, imageData),
      ]);
      final response = await model.generateContent([content]);
      // print(response.text);
      return response.text;
    } catch (e) {
      print('Error from ai_model (image): ${e.toString()}');
      return null;
    }
  }

  Future<String?> getResponseChat(String userMessage) async {
    try {
      final response = await chat.sendMessage(Content.text(userMessage));

      if (response.text != null && response.text!.isNotEmpty) {
        return response.text;
      } else {
        return "No response received";
      }
    } catch (e) {
      print("Error from model: $e");
      return "Error processing request";
    }
  }

  Stream<GenerateContentResponse> generateContentStreamChat(
    String userMessage,
  ) {
    return chat.sendMessageStream(Content.text(userMessage));
  }
}
