import 'package:flutter/material.dart';

class CustomLayout extends StatelessWidget {
  final String? layout;
  final List<Widget>? children;
  final MainAxisAlignment mainAxisAlignment;
  final double size;
  const CustomLayout({Key? key, 
    this.layout, 
    this.children, 
    this.size = double.infinity,
    this.mainAxisAlignment = MainAxisAlignment.start}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: layout == 'column' ? double.infinity : size,
      width: layout == 'row' ? double.infinity : size,
      child: layout == 'column'
      ? Column(
        mainAxisAlignment: mainAxisAlignment,
        children: children!,
      )
      : Row(
        mainAxisAlignment: mainAxisAlignment,
        children: children!,),
    );
  }
}