import 'package:flutter/material.dart';

class CustomTextIconButton extends StatelessWidget {
  final void Function()? onPressed;
  final Widget? icon;
  final Widget? label;
  final Color? color;

  const CustomTextIconButton({ Key? key, 
    this.onPressed,
    this.icon,
    this.label,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(color ?? Color(0xFFF6941D)),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              )
            )
          ),
          onPressed: this.onPressed,
          child: Row(
            children: <Widget>[
              this.label!,
              SizedBox(width: 5,),
              this.icon!,
            ],
          ),
        ),
        SizedBox(width: 10,),
      ],
    ); 
  }
}