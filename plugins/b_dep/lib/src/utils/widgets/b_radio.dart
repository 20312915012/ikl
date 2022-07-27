import 'package:flutter/material.dart';

import 'package:b_dep/src/utils/b_stateful_widget.dart';
import 'package:b_dep/src/utils/property_utils.dart';

/// Blup - Radio Button
class BRadio extends BStatefulWidget {
  BRadio({
    Key key,
    String id,
    this.onRadioDefaultPropUpdate,
    this.onRadioExtraPropUpdate,
    this.value,
    this.groupValue,
    this.toggleable,
    this.activeColor,
    this.focusColor,
    this.hoverColor,
    this.onChanged,
    this.onClick,
    this.index,
  }) : super(
          key: key,
          id: id,
        );

  Color strokeColor, backgroundColor;
  String value;
  String groupValue;
  bool toggleable;
  Color activeColor;
  Color focusColor;
  Color hoverColor;
  final Function onChanged;
  final Function onClick;
  final Function onRadioDefaultPropUpdate;
  final Function onRadioExtraPropUpdate;
  int index;

  @override
  BState<BStatefulWidget> createState() => _BRadioState();
}

class _BRadioState extends BState<BRadio> {
  String isChecked;

  @override
  void initState() {
    super.initState();
    isChecked = widget.value;
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
    return Radio(
      value: isChecked ?? widget.value,
      groupValue: widget.groupValue,
      toggleable: widget.toggleable,
      activeColor: widget.activeColor,
      focusColor: widget.focusColor,
      hoverColor: widget.hoverColor,
      onChanged: (value) {
        setState(() {
          isChecked = value;
          PropertyUtils().updateProperties(widget);
          if (widget.onChanged != null) {
            widget.onChanged(value);
          }
          if (widget.onClick != null) {
            widget.onClick();
          }
        });
      },
    );
  }

  @override
  void updateValues() {
    if (widget.onRadioDefaultPropUpdate != null) {
      widget.onRadioDefaultPropUpdate();
    }
    if (widget.onRadioExtraPropUpdate != null) {
      widget.onRadioExtraPropUpdate(
        widget.value,
        widget.groupValue,
        widget.toggleable,
        widget.activeColor,
        widget.focusColor,
        widget.hoverColor,
      );
    }
  }
}
