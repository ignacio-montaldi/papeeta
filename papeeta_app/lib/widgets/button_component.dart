import 'package:flutter/material.dart';

class ButtonComponent extends StatelessWidget {
  final String text;
  final Function onPressed;

  const ButtonComponent({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        elevation: WidgetStateProperty.all(2),
        shape: WidgetStateProperty.all(const StadiumBorder()),
        backgroundColor: WidgetStateProperty.all(Color(0xFF3C1642)),
      ),
      onPressed: () => onPressed(),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: Center(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 17),
          ),
        ),
      ),
    );
  }
}
