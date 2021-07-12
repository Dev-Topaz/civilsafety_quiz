import 'package:flutter/material.dart';

class CustomBanner extends StatelessWidget {
  final bool isBanner;
  final String? message;
  final Widget? child;

  const CustomBanner({Key? key, this.isBanner = true, this.message, this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: isBanner
          ? Banner(
              message: message!,
              location: BannerLocation.topEnd,
              child: child,
            )
          : child,
    );
  }
}
