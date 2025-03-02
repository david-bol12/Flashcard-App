import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'topic.dart';
import 'set.dart';


class HomeSpeedDial extends StatefulWidget {
  const HomeSpeedDial({
    super.key,
    required this.collectionPath
  });

  final String collectionPath;

  @override
  State<HomeSpeedDial> createState() => _HomeSpeedDialState();
}

class _HomeSpeedDialState extends State<HomeSpeedDial> {
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);
  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      icon: Icons.add_rounded,
      activeIcon: Icons.close_rounded,
      openCloseDial: isDialOpen,
      spaceBetweenChildren: 10,
      childrenButtonSize: const Size (60, 60.0),
      overlayColor: Colors.black,
      overlayOpacity: .1,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.add_box, size: 25,),
          label: 'Create Set',
          shape: const CircleBorder(),
          onTap: () => showDialog<String>(
            context: context,
            builder: (BuildContext context) => Dialog(
              backgroundColor: Theme.of(context).dialogBackgroundColor,
              child: CreateSet(collectionPath: widget.collectionPath)
            ),
          ),
        ),
        SpeedDialChild(
          child: const Icon(Icons.topic_rounded),
          label: 'Create Topic',
          shape: const CircleBorder(),
          onTap: () => showDialog<String>(
            context: context,
            builder: (BuildContext context) => Dialog(
              child: CreateTopic(collectionPath: widget.collectionPath,),
            )
          )
        ),
      ],
    );
  }
}
