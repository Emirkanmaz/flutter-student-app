import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message.dart';

class MessagesRepository extends ChangeNotifier {
  final List messages = [
    Message("Hi howdy?", "John",
        DateTime.now().subtract(const Duration(minutes: 5))),
    Message("Yea Im good how are you?", "Jane",
        DateTime.now().subtract(const Duration(minutes: 4))),
    Message("Where are you", "Jane",
        DateTime.now().subtract(const Duration(minutes: 3))),
    Message("school????", "Jane",
        DateTime.now().subtract(const Duration(minutes: 3))),
    Message("Yea bro :)", "John",
        DateTime.now().subtract(const Duration(minutes: 1))),
  ];
}

final messagesProvider = ChangeNotifierProvider((ref) {
  return MessagesRepository();
});

class UnreadedMessages extends StateNotifier<int> {
  UnreadedMessages(super.state);

  void reset() {
    state = 0;
  }
}

final unreadedMessagesProvider = StateNotifierProvider<UnreadedMessages, int>((ref) {
  return UnreadedMessages(5);
},);




