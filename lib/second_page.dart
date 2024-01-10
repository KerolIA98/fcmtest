import 'package:flutter/material.dart';

class SecondPage extends StatelessWidget {
  final String title;
  final String body;
  const SecondPage({Key? key, required this.title, required this.body})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Text(body),
      ),
    );
  }
}
