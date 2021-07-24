import 'package:flutter/material.dart';

class CustomTextIconButton extends StatelessWidget {
  final void Function()? onPressed;
  final Widget? icon;
  final Widget? label;

  const CustomTextIconButton({ Key? key, 
    this.onPressed,
    this.icon,
    this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0)),
      onPressed: this.onPressed,
      child: Column(
        children: <Widget>[
          this.icon!,
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
          ),
          this.label!,
        ],
      ),
    );
  }
}