import 'package:flutter/material.dart';

Route createRoute(Widget location) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => location,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

AppBar mainAppBar({
    required String title,
    required TextEditingController searchBarController,
    required Function(String) onSearch,
    List<Widget>? actions,
  }) {
  return AppBar(
    backgroundColor: Color(0xff2176ff),
    title: Text(title),
    bottom: PreferredSize(
        preferredSize: const Size.fromHeight(73),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 25),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              hintText: 'Search Topics or Sets...',
              hintStyle: TextStyle(
                  color: Colors.grey.shade700
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
            controller: searchBarController,
            onChanged: (value) {
              onSearch(value);
            },
          ),
        )
    ),
    actions: actions,
  );
}