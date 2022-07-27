import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:b_dep/src/utils/b_stateful_widget.dart';
import 'package:b_dep/src/utils/property_utils.dart';

class BCupertinoTimerPicker extends BStatefulWidget {
  BCupertinoTimerPicker({
    Key key,
    String id,
    double width,
    double height,
    this.onIosTimePickerDefaultPropUpdate,
    this.onIosTimePickerExtraPropUpdate,
    this.onTimerDurationChanged,
    this.themeType,
    this.mode,
    this.index,
  }) : super(
          key: key,
          id: id,
          width: width,
          height: height,
        );

  String themeType, mode;
  int index;
  final Function onIosTimePickerDefaultPropUpdate;
  final Function onIosTimePickerExtraPropUpdate;
  final Function onTimerDurationChanged;

  @override
  BState<BStatefulWidget> createState() => _BCupertinoTimerPickerState();
}

class _BCupertinoTimerPickerState extends BState<BCupertinoTimerPicker> {
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
      child: CupertinoTimerPicker(
        mode: widget.mode == null
            ? null
            : CupertinoTimerPickerMode.values.where((element) => element.toString().contains(widget.mode)).first,
        onTimerDurationChanged: (Duration d) {
          PropertyUtils().updateProperties(widget);
          widget.onTimerDurationChanged(d);
        },
      ),
    );
  }

  @override
  void updateValues() {
    if (widget.onIosTimePickerDefaultPropUpdate != null) {
      widget.onIosTimePickerDefaultPropUpdate(
        widget.width,
        widget.height,
      );
    }
    if (widget.onIosTimePickerExtraPropUpdate != null) {
      widget.onIosTimePickerExtraPropUpdate(
        widget.mode,
        widget.themeType,
      );
    }
  }
}
