import 'package:flutter/material.dart';

import 'package:b_dep/src/utils/b_stateful_widget.dart';
import 'package:b_dep/src/utils/property_utils.dart';

class BTimePicker extends BStatefulWidget {
  BTimePicker({
    Key key,
    String id,
    double width,
    double height,
    this.onTimePickerDefaultPropUpdate,
    this.onTimePickerExtraPropUpdate,
    this.onTimerDurationChanged,
    this.initialTime,
    this.index,
  }) : super(
          key: key,
          id: id,
          width: width,
          height: height,
        );

  DateTime initialTime;
  int index;
  final Function onTimePickerDefaultPropUpdate;
  final Function onTimePickerExtraPropUpdate;
  final Function onTimerDurationChanged;

  @override
  BState<BStatefulWidget> createState() => _BTimePickerState();
}

class _BTimePickerState extends BState<BTimePicker> {
  @override
  void initState() {
    super.initState();
    widget.initialTime = widget.initialTime ?? DateTime.now();
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
    return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: (){
            showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(widget.initialTime),
            ).then((value) {
              PropertyUtils().updateProperties(widget);
              if (widget.onTimerDurationChanged != null) {
                widget.onTimerDurationChanged(value);
              }
            });
          },
          child: SizedBox(
            width: widget.width,
            height: widget.height,
          ),
        )
    );
  }

  @override
  void updateValues() {
    if (widget.onTimePickerDefaultPropUpdate != null) {
      widget.onTimePickerDefaultPropUpdate(
        widget.width,
        widget.height,
      );
    }
    if (widget.onTimePickerExtraPropUpdate != null) {
      widget.onTimePickerExtraPropUpdate(
        widget.initialTime,
      );
    }
  }
}
