import 'package:flutter/material.dart';

class DismissibleListItem extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color? iconColor;
  final Color secondaryBackgroundColor;
  final Color? secondaryIconColor;
  final Function onDismissed;

  const DismissibleListItem({
    Key? key,
    required this.child,
    required this.backgroundColor,
    this.iconColor,
    required this.secondaryBackgroundColor,
    this.secondaryIconColor,
    required this.onDismissed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(key),
      background: Container(
        color: backgroundColor,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const SizedBox(
                width: 20,
              ),
              Icon(
                Icons.delete,
                color: iconColor ?? Colors.white,
              ),
              const Text(
                "Excluir",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
      ),
      secondaryBackground: Container(
        color: secondaryBackgroundColor,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const SizedBox(
                width: 20,
              ),
              Icon(
                Icons.edit,
                color: secondaryIconColor ?? Colors.white,
              ),
              const Text(
                "Editar",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
      ),
      child: child,
      onDismissed: (DismissDirection direction) {
        onDismissed(direction);
      },
    );
  }
}
