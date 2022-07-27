import 'package:flutter/material.dart';

import 'package:b_dep/src/utils/b_stateful_widget.dart';
import 'package:b_dep/src/utils/property_utils.dart';

class BSlider extends BStatefulWidget {
  BSlider({
    Key key,
    String id,
    this.onSliderDefaultPropUpdate,
    this.onSliderExtraPropUpdate,
    this.value,
    this.activeColor,
    this.inactiveColor,
    this.divisions,
    this.label,
    this.min,
    this.max,
    this.onChanged,
    this.index,
  }) : super(
          key: key,
          id: id,
        );

  Color strokeColor, backgroundColor;
  double value;
  Color activeColor;
  Color inactiveColor;
  int divisions;
  String label;
  double min;
  double max;
  int index;
  final Function onChanged;
  final Function onSliderDefaultPropUpdate;
  final Function onSliderExtraPropUpdate;

  @override
  BState<BStatefulWidget> createState() => BSliderState();
}

class BSliderState extends BState<BSlider> {
  double value;

  @override
  void initState() {
    super.initState();
    value = widget.value;
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
    return Slider(
      value: value ?? widget.value,
      activeColor: widget.activeColor,
      inactiveColor: widget.inactiveColor,
      divisions: widget.divisions,
      label: widget.label,
      min: widget.min,
      max: widget.max,
      onChanged: (value) {
        setState(() {
          this.value = value;
          widget.onChanged(value);
        });
      },
    );
  }

  @override
  void updateValues() {
    if (widget.onSliderDefaultPropUpdate != null) {
      widget.onSliderDefaultPropUpdate();
    }
    if (widget.onSliderExtraPropUpdate != null) {
      widget.onSliderExtraPropUpdate(
        value ?? widget.value,
        widget.min,
        widget.max,
        widget.divisions,
        widget.label,
        widget.activeColor,
        widget.inactiveColor,
      );
    }
  }
}
