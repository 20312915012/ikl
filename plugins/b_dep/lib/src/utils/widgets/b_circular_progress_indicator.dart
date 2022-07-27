import 'package:flutter/material.dart';

import 'package:b_dep/src/utils/b_stateful_widget.dart';
import 'package:b_dep/src/utils/property_utils.dart';

class BCircularProgressIndicator extends BStatefulWidget {
  BCircularProgressIndicator({
    Key key,
    String id,
    this.onProgresswheelDefaultPropUpdate,
    this.onProgresswheelExtraPropUpdate,
    this.value,
    this.valueColor,
    this.strokeWidth,
    this.backgroundColor,
    this.index,
  }) : super(
          key: key,
          id: id,
        );

  Animation<Color> valueColor;
  Color strokeColor, backgroundColor;
  double value, strokeWidth;
  int index;
  final Function onProgresswheelDefaultPropUpdate;
  final Function onProgresswheelExtraPropUpdate;

  @override
  BState<BStatefulWidget> createState() => _BCircularProgressIndicatorState();
}

class _BCircularProgressIndicatorState extends BState<BCircularProgressIndicator> {
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
    return CircularProgressIndicator(
      value: widget.value,
      valueColor: widget.valueColor,
      strokeWidth: widget.strokeWidth,
      backgroundColor: widget.backgroundColor,
    );
  }

  @override
  void updateValues() {
    if (widget.onProgresswheelExtraPropUpdate != null) {
      widget.onProgresswheelExtraPropUpdate(
        widget.value,
        widget.valueColor,
        widget.strokeWidth,
        widget.backgroundColor,
      );
    }
  }
}
