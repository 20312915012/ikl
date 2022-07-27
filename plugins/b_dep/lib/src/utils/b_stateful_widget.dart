import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

abstract class BStatefulWidget extends StatefulWidget {
  BStatefulWidget({
    Key key,
    this.id,
    this.child,
    this.width,
    this.height,
    this.paddingLeft,
    this.paddingRight,
    this.paddingTop,
    this.paddingBottom,
    this.isHide,
  }) : super(key: key);

  String id;
  Widget child;
  double width;
  double height;
  double paddingLeft, paddingRight, paddingTop, paddingBottom;
  bool isHide;
}

abstract class BState<T extends BStatefulWidget> extends State<T> {
  BWidget bWidget;

  @override
  void initState() {
    super.initState();
    bWidget = BWidget(widget, this);
    BWidget.widgetMap[widget.id] = BWidget(widget, this);
  }

  void updateValues();
}

class BWidget {
  static Map<String, BWidget> widgetMap = {};

  BStatefulWidget widget;
  BState state;
  BWidget(this.widget, this.state);
}
