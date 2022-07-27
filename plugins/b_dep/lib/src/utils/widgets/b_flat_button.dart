import 'package:flutter/material.dart';

import 'package:b_dep/src/utils/b_stateful_widget.dart';
import 'package:b_dep/src/utils/property_utils.dart';

class BFlatButton extends BStatefulWidget {
  BFlatButton({
    Key key,
    String id,
    Widget child,
    this.onClick,
    this.onFlatbuttonDefaultPropUpdate,
    this.onFlatbuttonExtraPropUpdate,
    this.color,
    this.splashColor,
    this.hoverColor,
    this.highlightColor,
    this.focusColor,
    this.disabledColor,
    this.disabledTextColor,
    this.shape,
    this.index,
  }) : super(
          key: key,
          id: id,
          child: child,
        );

  Color color, splashColor, hoverColor, highlightColor, focusColor, disabledColor, disabledTextColor;
  ShapeBorder shape;
  final Function onClick;
  final Function onFlatbuttonDefaultPropUpdate;
  final Function onFlatbuttonExtraPropUpdate;

  int index;

  @override
  BState<BStatefulWidget> createState() => _BFlatButtonState();
}

class _BFlatButtonState extends BState<BFlatButton> {
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
    return FlatButton(
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
      disabledTextColor: widget.disabledTextColor,
      shape: widget.shape,
    );
  }

  @override
  void updateValues() {
    if (widget.onFlatbuttonExtraPropUpdate != null) {
      widget.onFlatbuttonExtraPropUpdate(
        widget.color,
        widget.splashColor,
        widget.hoverColor,
        widget.highlightColor,
        widget.focusColor,
        widget.disabledColor,
        widget.disabledTextColor,
        ((widget.shape as RoundedRectangleBorder).borderRadius as BorderRadius).topLeft.x,
      );
    }
  }
}
