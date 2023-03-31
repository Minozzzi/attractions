import 'package:attractions/src/domain/attraction.dart';
import 'package:attractions/src/presentation/attraction/attraction_modal.dart';
import 'package:attractions/src/widget/card.dart';
import 'package:attractions/src/widget/dismissible_list_item.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttractionList extends StatelessWidget {
  final List<Attraction> attractions;
  final Function onSlideRight;
  final Function onTapCard;

  const AttractionList(
      {super.key,
      required this.attractions,
      required this.onSlideRight,
      required this.onTapCard});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: attractions.length,
      itemBuilder: (context, index) {
        return AttractionItem(
            attraction: attractions[index],
            onSlideRight: onSlideRight,
            onTapCard: onTapCard);
      },
    );
  }
}

class AttractionItem extends StatelessWidget {
  final Attraction attraction;
  final Function onSlideRight;
  final Function onTapCard;

  const AttractionItem(
      {super.key,
      required this.attraction,
      required this.onSlideRight,
      required this.onTapCard});

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
    List<Widget> children = [
      Text(
        attraction.name,
        style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      Text(attraction.description),
    ];

    if (attraction.differentials?.isNotEmpty ?? false) {
      children.add(const SizedBox(height: 8));
      children.add(Text(attraction.differentials!));
    }

    return ClickableCard(
      onTap: () => onTapCard(attraction),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
            Text(DateFormat('dd/MM/yyyy').format(attraction.createdAt)),
          ],
        ),
      ),
    );
  }

  void onDismissed(DismissDirection direction) {
    if (direction == DismissDirection.startToEnd) {
      onSlideRight(attraction);
    }
  }
}
