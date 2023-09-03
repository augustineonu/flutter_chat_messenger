import 'package:flutter/material.dart';

class CallsPage extends StatelessWidget {
  const CallsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
         centerTitle: true,
         shape:
            Border(bottom: BorderSide(color: Colors.grey.shade300, width: 4)),
        backgroundColor: Colors.white,
        title: Text("Calls",
        style: TextStyle(fontWeight: FontWeight.w700),)),
    );
  }
}