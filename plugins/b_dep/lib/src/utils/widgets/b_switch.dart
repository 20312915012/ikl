import 'package:flutter/material.dart';

import 'package:b_dep/src/utils/b_stateful_widget.dart';
import 'package:b_dep/src/utils/property_utils.dart';

class BSwitch extends BStatefulWidget {
  BSwitch({
    Key key,
    String id,
    this.onSwitchDefaultPropUpdate,
    this.onSwitchExtraPropUpdate,
    this.value,
    this.activeColor,
    this.focusColor,
    this.hoverColor,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.inactiveThumbColor,
    this.onChanged,
    this.index,
  }) : super(
          key: key,
          id: id,
        );

  Color strokeColor, backgroundColor;
  bool value;
  Color activeColor;
  Color focusColor;
  Color hoverColor;
  Color activeTrackColor;
  Color inactiveTrackColor;
  Color inactiveThumbColor;
  int index;
  final Function onChanged;
  final Function onSwitchDefaultPropUpdate;
  final Function onSwitchExtraPropUpdate;

  @override
  BState<BStatefulWidget> createState() => BSwitchState();
}

class BSwitchState extends BState<BSwitch> {
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
    return Switch(
      value: isChecked ?? widget.value,
      activeColor: widget.activeColor,
      focusColor: widget.focusColor,
      hoverColor: widget.hoverColor,
      activeTrackColor: widget.activeTrackColor,
      inactiveTrackColor: widget.inactiveTrackColor,
      inactiveThumbColor: widget.inactiveThumbColor,
      onChanged: (value) {
        setState(() {
          isChecked = value;
          widget.onChanged(value);
        });
      },
    );
  }

  @override
  void updateValues() {
    if (widget.onSwitchDefaultPropUpdate != null) {
      widget.onSwitchDefaultPropUpdate();
    }
    if (widget.onSwitchExtraPropUpdate != null) {
      widget.onSwitchExtraPropUpdate(
        isChecked ?? widget.value,
        widget.activeColor,
        widget.focusColor,
        widget.hoverColor,
        widget.activeTrackColor,
        widget.inactiveTrackColor,
        widget.inactiveThumbColor,
      );
    }
  }
}
