import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app/repository/messages_repository.dart';
import '../models/message.dart';

class MessagesPage extends ConsumerStatefulWidget {

  const MessagesPage({Key? key}) : super(key: key);


  @override
  ConsumerState<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends ConsumerState<MessagesPage> {

  @override
  void initState() {
    Future.delayed(Duration.zero).then((value) => ref.read(unreadedMessagesProvider.notifier).reset());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final messagesRepository = ref.watch(messagesProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Messages"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messagesRepository.messages.length,
              itemBuilder: (context, index) {
                // bool myMessage = Random().nextBool();

                return MessageView(messagesRepository.messages[
                    messagesRepository.messages.length - index - 1]);
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                  child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 2),
                        borderRadius: const BorderRadius.all(Radius.circular(25)),
                      ),
                      child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15.0),
                          child: TextField()))),
              ElevatedButton(
                onPressed: () {},
                child: const Icon(Icons.send),
              )
            ],
          )
        ],
      ),
    );
  }
}

class MessageView extends StatelessWidget {
  final Message message;

  const MessageView(
    this.message, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.sender == "John"
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.lightGreen.shade200,
            border: Border.all(color: Colors.grey, width: 2),
            borderRadius: const BorderRadius.all(Radius.circular(15)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(message.text),
          ),
        ),
      ),
    );
  }
}
