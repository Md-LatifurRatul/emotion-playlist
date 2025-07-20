import 'package:dash_chat_2/dash_chat_2.dart';

class ChatUserModel {
  static ChatUser user = ChatUser(id: '1', firstName: "User", lastName: "chat");
  static ChatUser geminiUser = ChatUser(
    id: '2',
    firstName: 'Model',
    lastName: 'AI',
  );

  List<ChatMessage> messages = <ChatMessage>[];
}
