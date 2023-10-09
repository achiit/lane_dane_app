import 'package:flutter/material.dart';

class ChatMessageOptions extends StatelessWidget {
  const ChatMessageOptions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children:const [
        ChatInputField(),
      ],
    );
  }
}

class ChatInputField extends StatelessWidget {
  const ChatInputField({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(      
      padding: const EdgeInsets.symmetric(horizontal:10,vertical:5),
      decoration : const BoxDecoration(
        color: Colors.grey,
      ),
      child: SafeArea(
        child: Row(
          children:[
           const Icon(Icons.mic, color: Colors.green),
            const SizedBox(width:15),
            Expanded(child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Row(
                children:const [
                  Icon(Icons.sentiment_satisfied_alt_outlined,color:Colors.pinkAccent),
                  SizedBox(width:5),
                  Expanded(child: TextField(
                    decoration: InputDecoration(
                      hintText:"Type Message",
                      border:InputBorder.none,
                    ),
                  ),
                  ),
                ],
              ),
            ),)
        ],
      ),
      ),
    );
  }
}