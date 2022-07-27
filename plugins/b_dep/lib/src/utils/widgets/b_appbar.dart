import 'package:flutter/material.dart';

import 'package:b_dep/src/utils/b_stateful_widget.dart';
import 'package:b_dep/src/utils/property_utils.dart';

class BAppBar extends BStatefulWidget {
  BAppBar({
    Key key,
    String id,
    this.onAppbarDefaultPropUpdate,
    this.onAppbarExtraPropUpdate,
    this.backgroundColor,
    this.shadowColor,
    this.elevation,
    this.centerTitle,
    this.title,
    this.titleSpacing,
    this.toolbarHeight,
    this.toolbarOpacity,
    this.shape,
    this.index,
  }) : super(
          key: key,
          id: id,
        );

  Color backgroundColor;
  Color shadowColor;
  double elevation;
  bool centerTitle;
  Widget title;
  double titleSpacing;
  double toolbarHeight;
  double toolbarOpacity;
  ShapeBorder shape;
  int index;
  final Function onAppbarDefaultPropUpdate;
  final Function onAppbarExtraPropUpdate;

  @override
  BState<BStatefulWidget> createState() => _BAppBarState();
}

class _BAppBarState extends BState<BAppBar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    PropertyUtils().updateProperties(widget);
    return AppBar(
      backgroundColor: widget.backgroundColor,
      shadowColor: widget.shadowColor,
      elevation: widget.elevation,
      centerTitle: widget.centerTitle,
      title: widget.title,
      titleSpacing: widget.titleSpacing,
      toolbarHeight: widget.toolbarHeight ?? 22.0, //To fix the title text: top-margin bug.
      toolbarOpacity: widget.toolbarOpacity,
      shape: widget.shape,
    );
  }

  @override
  void updateValues() {
    if (widget.onAppbarDefaultPropUpdate != null) {
      widget.onAppbarDefaultPropUpdate();
    }
    if (widget.onAppbarExtraPropUpdate != null) {
      widget.onAppbarExtraPropUpdate(
        widget.backgroundColor,
        widget.shadowColor,
        widget.elevation,
        widget.centerTitle,
        widget.titleSpacing,
        widget.toolbarHeight,
        widget.toolbarOpacity,
        //widget.shape,
      );
    }
  }
}
