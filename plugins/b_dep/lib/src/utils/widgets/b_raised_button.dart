import 'package:flutter/material.dart';

import 'package:b_dep/src/utils/b_stateful_widget.dart';
import 'package:b_dep/src/utils/property_utils.dart';

class BRaisedButton extends BStatefulWidget {
  BRaisedButton({
    Key key,
    String id,
    Widget child,
    this.onClick,
    this.onRaisedbuttonDefaultPropUpdate,
    this.onRaisedbuttonExtraPropUpdate,
    this.color,
    this.splashColor,
    this.hoverColor,
    this.highlightColor,
    this.focusColor,
    this.disabledColor,
    this.elevation,
    this.disabledElevation,
    this.focusElevation,
    this.hoverElevation,
    this.highlightElevation,
    this.shape,
    this.index,
  }) : super(
          key: key,
          id: id,
          child: child,
        );

  Color color, splashColor, hoverColor, highlightColor, focusColor, disabledColor;
  double elevation, disabledElevation, focusElevation, hoverElevation, highlightElevation;
  ShapeBorder shape;
  final Function onClick;
  final Function onRaisedbuttonDefaultPropUpdate;
  final Function onRaisedbuttonExtraPropUpdate;
  int index;

  @override
  BState<BStatefulWidget> createState() => _BRaisedButtonState();
}

class _BRaisedButtonState extends BState<BRaisedButton> {
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
    return RaisedButton(
      onPressed: () {
        PropertyUtils().updateProperties(widget);
        if (widget.onClick != null) {
          if (widget.index != null) {
            widget.onClick(PropertyUtils().getTextFromBTextChild(widget), widget.index);
          } else {
            widget.onClick(PropertyUtils().getTextFromBTextChild(widget));
          }
        }
      },
      child: widget.child,
      color: widget.color,
      splashColor: widget.splashColor,
      hoverColor: widget.hoverColor,
      highlightColor: widget.highlightColor,
      focusColor: widget.focusColor,
      disabledColor: widget.disabledColor,
      elevation: widget.elevation,
      disabledElevation: widget.disabledElevation,
      focusElevation: widget.focusElevation,
      hoverElevation: widget.hoverElevation,
      highlightElevation: widget.highlightElevation,
      shape: widget.shape,
    );
  }

  @override
  void updateValues() {
    if (widget.onRaisedbuttonExtraPropUpdate != null) {
      widget.onRaisedbuttonExtraPropUpdate(
        widget.color,
        widget.splashColor,
        widget.hoverColor,
        widget.highlightColor,
        widget.focusColor,
        widget.disabledColor,
        widget.elevation,
        widget.disabledElevation,
        widget.focusElevation,
        widget.hoverElevation,
        widget.highlightElevation,
        ((widget.shape as RoundedRectangleBorder).borderRadius as BorderRadius).topLeft.x,
      );
    }
  }
}
