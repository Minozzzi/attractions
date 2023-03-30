import 'package:attractions/src/domain/attraction.dart';
import 'package:attractions/src/widget/card.dart';
import 'package:attractions/src/widget/dismissible_list_item.dart';
import 'package:flutter/material.dart';

class AttractionList extends StatelessWidget {
  final List<Attraction> attractions;
  final Function onSlideRight;

  const AttractionList(
      {super.key, required this.attractions, required this.onSlideRight});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: attractions.length,
      itemBuilder: (context, index) {
        return AttractionItem(
            attraction: attractions[index], onSlideRight: onSlideRight);
      },
    );
  }
}

class AttractionItem extends StatelessWidget {
  final Attraction attraction;
  final Function onSlideRight;

  const AttractionItem(
      {super.key, required this.attraction, required this.onSlideRight});

  @override
  Widget build(BuildContext context) {
    return DismissibleListItem(
      key: ValueKey<Attraction>(attraction),
      backgroundColor: Colors.red,
      secondaryBackgroundColor: Colors.blue[800] ?? Colors.blue,
      onDismissed: onDismissed,
      child: itemBuilder(),
    );
  }

  Widget itemBuilder() {
    return ClickableCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attraction.name,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      onTap: () {},
    );
  }

  void onDismissed(DismissDirection direction) {
    if (direction == DismissDirection.startToEnd) {
      onSlideRight(attraction);
    }
  }
}
