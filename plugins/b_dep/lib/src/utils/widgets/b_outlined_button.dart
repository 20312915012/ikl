import 'package:flutter/material.dart';

import 'package:b_dep/src/utils/b_stateful_widget.dart';
import 'package:b_dep/src/utils/property_utils.dart';

class BOutlineButton extends BStatefulWidget {
  BOutlineButton({
    Key key,
    String id,
    Widget child,
    this.onClick,
    this.onOutlinebuttonDefaultPropUpdate,
    this.onOutlinebuttonExtraPropUpdate,
    this.color,
    this.splashColor,
    this.hoverColor,
    this.highlightColor,
    this.focusColor,
    this.borderColor,
    this.borderWidth,
    this.highlightedBorderColor,
    this.disabledBorderColor,
    this.highlightElevation,
    this.shape,
    this.index,
  }) : super(
          key: key,
          id: id,
          child: child,
        );

  Color color, splashColor, hoverColor, highlightColor, focusColor;
  BorderSide borderSide;
  Color highlightedBorderColor;
  Color disabledBorderColor, borderColor;
  double highlightElevation, borderWidth;
  ShapeBorder shape;
  final Function onClick;
  final Function onOutlinebuttonDefaultPropUpdate;
  final Function onOutlinebuttonExtraPropUpdate;
  int index;

  @override
  BState<BStatefulWidget> createState() => _BOutlineButtonState();
}

class _BOutlineButtonState extends BState<BOutlineButton> {
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
    return OutlineButton(
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
      borderSide: BorderSide(
        color: widget.borderColor,
        width: widget.borderWidth,
      ),
      highlightedBorderColor: widget.highlightedBorderColor,
      disabledBorderColor: widget.disabledBorderColor,
      highlightElevation: widget.highlightElevation,
      shape: widget.shape,
    );
  }

  @override
  void updateValues() {
    if (widget.onOutlinebuttonExtraPropUpdate != null) {
      widget.onOutlinebuttonExtraPropUpdate(
        widget.color,
        widget.splashColor,
        widget.hoverColor,
        widget.highlightColor,
        widget.focusColor,
        widget.borderColor,
        widget.borderWidth,
        widget.highlightedBorderColor,
        widget.disabledBorderColor,
        widget.highlightElevation,
        ((widget.shape as RoundedRectangleBorder).borderRadius as BorderRadius).topLeft.x,
      );
    }
  }
}
