import 'package:flutter/material.dart';

class ProFileScreen extends StatefulWidget {
  @override
  _ProFileScreenState createState() => _ProFileScreenState();
}

class _ProFileScreenState extends State<ProFileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile'),),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),

    );
  }
}
