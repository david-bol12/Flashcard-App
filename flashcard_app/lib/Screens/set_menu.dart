import 'package:flutter/material.dart';

class SetMenu extends StatefulWidget {
  const SetMenu({super.key});

  @override
  State<SetMenu> createState() => _SetMenuState();
}

class _SetMenuState extends State<SetMenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(150),
        child: AppBar(
          title: Text('Hello'),
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25))),
        )
      ),
    );
  }
}
