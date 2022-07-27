import 'package:flutter/material.dart';

import 'package:b_dep/src/utils/b_stateful_widget.dart';
import 'package:b_dep/src/utils/property_utils.dart';

class BLinearProgressIndicator extends BStatefulWidget {
  BLinearProgressIndicator({
    Key key,
    String id,
    this.onProgressbarDefaultPropUpdate,
    this.onProgressbarExtraPropUpdate,
    this.value,
    this.valueColor,
    this.backgroundColor,
    this.index,
  }) : super(
          key: key,
          id: id,
        );

  Animation<Color> valueColor;
  Color strokeColor, backgroundColor;
  double value;
  int index;
  final Function onProgressbarDefaultPropUpdate;
  final Function onProgressbarExtraPropUpdate;

  @override
  BState<BStatefulWidget> createState() => _BLinearProgressIndicatorState();
}

class _BLinearProgressIndicatorState extends BState<BLinearProgressIndicator> {
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
    return LinearProgressIndicator(
      value: widget.value,
      valueColor: widget.valueColor,
      backgroundColor: widget.backgroundColor,
    );
  }

  @override
  void updateValues() {
    if (widget.onProgressbarExtraPropUpdate != null) {
      widget.onProgressbarExtraPropUpdate(
        widget.value,
        widget.valueColor,
        widget.backgroundColor,
      );
    }
  }
}
