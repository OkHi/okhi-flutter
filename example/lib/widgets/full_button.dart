import 'package:flutter/material.dart';

class FullButton extends StatelessWidget {
  final void Function()? onPressed;
  final String title;
  final bool dis;
  const FullButton({Key? key, this.onPressed, required this.title, disabled})
      : dis = disabled ?? false,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return ElevatedButton(
      onPressed: _handlePress,
      child: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: dis ? Colors.grey.shade300 : Colors.lightBlue,
        minimumSize: Size(
          width,
          35,
        ), // double.infinity is the width and 30 is the height
      ),
    );
  }

  _handlePress() {
    if (!dis && onPressed != null) {
      onPressed!();
    }
  }
}
