import 'package:flutter/material.dart';
import 'package:login_facebook_google/customs_widget/text_style.dart';

class NormalButton extends StatelessWidget {
  final VoidCallback onPressed;

  final String title;

  NormalButton({required this.onPressed,required this.title});

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      minWidth: 200,
      height: 45,
      child: RaisedButton(
        onPressed: onPressed,
        color: Colors.blue,
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(8.0)),
        child: Text(
          title,
          style: textWhiteButtonDefault(),
        ),
      ),
    );
  }
}