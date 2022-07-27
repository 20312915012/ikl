import 'package:flutter/material.dart';

import 'package:b_dep/src/utils/b_stateful_widget.dart';
import 'package:b_dep/src/utils/property_utils.dart';

class BCheckbox extends BStatefulWidget {
  BCheckbox({
    Key key,
    String id,
    this.onCheckboxDefaultPropUpdate,
    this.onCheckboxExtraPropUpdate,
    this.value,
    this.tristate,
    this.checkColor,
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
  bool value;
  bool tristate;
  Color checkColor;
  Color activeColor;
  Color focusColor;
  Color hoverColor;
  int index;
  final Function onChanged;
  final Function onClick;
  final Function onCheckboxDefaultPropUpdate;
  final Function onCheckboxExtraPropUpdate;

  @override
  BState<BStatefulWidget> createState() => BCheckboxState();
}

class BCheckboxState extends BState<BCheckbox> {
  bool isChecked;

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
    return Checkbox(
      value: isChecked ?? widget.value,
      tristate: widget.tristate,
      checkColor: widget.checkColor,
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
    if (widget.onCheckboxDefaultPropUpdate != null) {
      widget.onCheckboxDefaultPropUpdate();
    }
    if (widget.onCheckboxExtraPropUpdate != null) {
      widget.onCheckboxExtraPropUpdate(
        isChecked ?? widget.value,
        widget.tristate,
        widget.checkColor,
        widget.activeColor,
        widget.focusColor,
        widget.hoverColor,
      );
    }
  }
}
