import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:b_dep/src/utils/b_stateful_widget.dart';
import 'package:b_dep/src/utils/property_utils.dart';

class BCupertinoDatePicker extends BStatefulWidget {
  BCupertinoDatePicker({
    Key key,
    String id,
    double width,
    double height,
    this.onIosDatePickerDefaultPropUpdate,
    this.onIosDatePickerExtraPropUpdate,
    this.onDateTimeChanged,
    this.themeType,
    this.mode,
    this.use24hFormat,
    this.index,
  }) : super(
          key: key,
          id: id,
          width: width,
          height: height,
        );

  String themeType, mode;
  bool use24hFormat;
  int index;
  final Function onIosDatePickerDefaultPropUpdate;
  final Function onIosDatePickerExtraPropUpdate;
  final Function onDateTimeChanged;

  @override
  BState<BStatefulWidget> createState() => _BCupertinoDatePickerState();
}

class _BCupertinoDatePickerState extends BState<BCupertinoDatePicker> {
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
    return CupertinoTheme(
      data: CupertinoThemeData(
        brightness: widget.themeType == null
            ? null
            : Brightness.values.where((element) => element.toString().contains(widget.themeType)).first,
      ),
      child: CupertinoDatePicker(
        use24hFormat: widget.use24hFormat,
        mode: widget.mode == null
            ? null
            : CupertinoDatePickerMode.values.where((element) => element.toString().contains(widget.mode)).first,
        onDateTimeChanged: (DateTime dT) {
          PropertyUtils().updateProperties(widget);
          widget.onDateTimeChanged(dT);
        },
      ),
    );
  }

  @override
  void updateValues() {
    if (widget.onIosDatePickerDefaultPropUpdate != null) {
      widget.onIosDatePickerDefaultPropUpdate(
        widget.width,
        widget.height,
      );
    }
    if (widget.onIosDatePickerExtraPropUpdate != null) {
      widget.onIosDatePickerExtraPropUpdate(
        widget.use24hFormat,
        widget.mode,
        widget.themeType,
      );
    }
  }
}
