import 'package:flutter/material.dart';

class MessageBox extends StatelessWidget {
  final String message;
  const MessageBox({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.grey.shade400,
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(child: SelectableText(message)),
      ),
    );
  }
}
