import 'package:flutter/material.dart';

class WatermarkBase extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final Widget? bottomNavigationBar;

  const WatermarkBase({
    super.key,
    required this.child,
    this.appBar,
    this.floatingActionButton,
    this.drawer,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white, // Fallback background color
        image: DecorationImage(
          image: AssetImage('assets/images/app_background.png'),
          fit: BoxFit.cover,
          opacity: 0.85, // Increased opacity to 85% as requested
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Make Scaffold transparent to show image
        appBar: appBar,
        drawer: drawer,
        body: child,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar,
      ),
    );
  }
}
