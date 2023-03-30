import 'package:flutter/material.dart';

class ClickableCard extends StatelessWidget {
  final Widget child;
  final void Function() onTap;

  const ClickableCard({
    Key? key,
    required this.child,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: child,
      ),
    );
  }
}
