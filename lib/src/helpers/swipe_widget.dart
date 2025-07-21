// lib/helpers/swipe_widget.dart (your OnSlide widget file)

import 'dart:async';
import 'package:flutter/material.dart';
import './size_change_notifier.dart'; // Make sure the path is correct

class ActionItems extends Object {
  ActionItems({required this.icon, required this.onPress, this.backgroundColor= Colors.grey}); // Fixed typo here!

  final Widget icon;
  final VoidCallback onPress;
  final Color backgroundColor; // Fixed typo!
}

class OnSlide extends StatefulWidget {
  OnSlide({super.key, required this.items, required this.child, this.backgroundColor= Colors.white})   {
    assert(items.length <= 6);
  }

  final List<ActionItems> items;
  final Widget child;
  final Color backgroundColor;

  @override
  State<StatefulWidget> createState() {
    return _OnSlideState();
  }
}

class _OnSlideState extends State<OnSlide> {
  ScrollController controller = ScrollController();
  bool isOpen = false;

  Size? childSize; // This is the crucial variable we're tracking

  @override
  void initState() {
    super.initState();
    print('OnSlide(State): initState called.');
  }

  bool _handleScrollNotification(dynamic notification) {
    if (notification is ScrollEndNotification) {
      // Calculate target scroll position based on the actual item width (60.0)
      double snapToOpenPosition = widget.items.length * 60.0;
      double snapThreshold = snapToOpenPosition / 2;

      if (notification.metrics.pixels >= snapThreshold && notification.metrics.pixels < snapToOpenPosition) {
        scheduleMicrotask(() {
          controller.animateTo(snapToOpenPosition, duration: Duration(milliseconds: 300), curve: Curves.decelerate);
        });
        isOpen = true; // Update state if it snapped open
      } else if (notification.metrics.pixels > 0.0 && notification.metrics.pixels < snapThreshold) {
        scheduleMicrotask(() {
          controller.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.decelerate);
        });
        isOpen = false; // Update state if it snapped closed
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    print('OnSlide(State): build called. Current childSize: $childSize'); // Debug: See childSize value

    if (childSize == null) {
      print('OnSlide(State): childSize is null. Returning NotificationListener for size detection.');
      // First build pass: wrap child in LayoutSizeChangeNotifier to get its size
      return NotificationListener<LayoutSizeChangeNotification>( // Specify type for clarity
        child: LayoutSizeChangeNotifier(
          child: widget.child,
        ),
        onNotification: (LayoutSizeChangeNotification notification) {
          childSize = notification.newSize;
          print('OnSlide(State): LayoutSizeChangeNotification received! New size: $childSize'); // Debug: CRITICAL print
          // Only call setState if the widget is still mounted
          if (mounted) {
            scheduleMicrotask(() {
              setState(() {}); // Trigger a rebuild once childSize is known
            });
          }
          return true;
        },
      );
    }

    print('OnSlide(State): childSize is NOT null ($childSize). Building the swipe UI.');

    // If childSize is determined, proceed to build the actual swipe UI
    List<Widget> above = <Widget>[
      Container( // This is the main content of the notification item that slides
        width: childSize!.width,
        height: childSize!.height,
        color: widget.backgroundColor, // Use widget's background color
        child: widget.child,
      ),
    ];
    List<Widget> under = <Widget>[]; // These are your background action buttons

    for (ActionItems item in widget.items) {
      under.add(Container(
        alignment: Alignment.center,
        color: item.backgroundColor, // Fixed typo here!
        width: 60.0,
        height: childSize!.height,
        child: item.icon,
      ));

      // This is a transparent InkWell placed over the background button
      // It handles the tap even when the main content is fully covering it.
      above.add(InkWell(
          child: Container(
            alignment: Alignment.center,
            width: 60.0,
            height: childSize!.height,
          ),
          onTap: () {
            // After tap, you usually want to close the swipe
            if (mounted) { // Ensure widget is mounted before interacting with controller
              controller.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.decelerate);
              setState(() { isOpen = false; }); // Update state
            }
            item.onPress(); // Execute the action item's onPress
          }));
    }

    Widget items = Container(
      width: childSize!.width, // The width of the entire OnSlide widget
      height: childSize!.height,
      color: widget.backgroundColor, // Background color for the full widget
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end, // Align buttons to the right
        children: under, // The actual colored action buttons
      ),
    );

    Widget scrollview = NotificationListener<ScrollNotification>( // Specify type
      onNotification: _handleScrollNotification,
      child: ListView(
        controller: controller,
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(), // Added for smoother scrolling
        children: above, // Contains the main child and the transparent tap areas
      ),
    );

    return Stack(
      children: <Widget>[
        items, // Background layer (action buttons)
        Positioned( // Foreground layer (main content, slides over actions)
          left: 0.0,
          bottom: 0.0,
          right: 0.0,
          top: 0.0,
          child: scrollview,
        )
      ],
    );
  }
}