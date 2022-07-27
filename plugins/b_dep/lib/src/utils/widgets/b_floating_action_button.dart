import 'package:flutter/material.dart';

import 'package:b_dep/src/utils/b_stateful_widget.dart';
import 'package:b_dep/src/utils/property_utils.dart';

class BFloatingActionButton extends BStatefulWidget {
  BFloatingActionButton({
    Key key,
    String id,
    Widget child,
    this.onClick,
    this.onFABDefaultPropUpdate,
    this.onFABExtraPropUpdate,
    this.backgroundColor,
    this.splashColor,
    this.hoverColor,
    this.focusColor,
    this.foregroundColor,
    this.tooltip,
    this.elevation,
    this.disabledElevation,
    this.focusElevation,
    this.hoverElevation,
    this.highlightElevation,
    this.heroTag,
    this.index,
  }) : super(
          key: key,
          id: id,
          child: child,
        );

  Color backgroundColor, splashColor, hoverColor, focusColor, foregroundColor;
  String tooltip;
  double elevation;
  double disabledElevation;
  double focusElevation;
  double hoverElevation;
  double highlightElevation;
  String heroTag;
  int index;

  final Function onClick;
  final Function onFABDefaultPropUpdate;
  final Function onFABExtraPropUpdate;

  @override
  BState<BStatefulWidget> createState() => _BFloatingActionButtonState();
}

class _BFloatingActionButtonState extends BState<BFloatingActionButton> {
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
    return FloatingActionButton(
      onPressed: () {
        PropertyUtils().updateProperties(widget);
        if (widget.onClick != null) {
          if (widget.index != null) {
            widget.onClick(widget.index);
          } else {
            widget.onClick();
          }
        }
      },
      child: widget.child,
      backgroundColor: widget.backgroundColor,
      splashColor: widget.splashColor,
      hoverColor: widget.hoverColor,
      focusColor: widget.focusColor,
      foregroundColor: widget.foregroundColor,
      tooltip: widget.tooltip,
      elevation: widget.elevation,
      disabledElevation: widget.disabledElevation,
      focusElevation: widget.focusElevation,
      hoverElevation: widget.hoverElevation,
      highlightElevation: widget.highlightElevation,
      heroTag: widget.heroTag,
    );
  }

  @override
  void updateValues() {
    if (widget.onFABExtraPropUpdate != null) {
      widget.onFABExtraPropUpdate(
        widget.backgroundColor,
        widget.splashColor,
        widget.hoverColor,
        widget.focusColor,
        widget.foregroundColor,
        widget.tooltip,
        widget.elevation,
        widget.disabledElevation,
        widget.focusElevation,
        widget.hoverElevation,
        widget.highlightElevation,
      );
    }
  }
}
