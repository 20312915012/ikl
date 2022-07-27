import 'package:flutter/material.dart';

import 'package:b_dep/src/utils/b_stateful_widget.dart';
import 'package:b_dep/src/utils/property_utils.dart';

class BDatePicker extends BStatefulWidget {
  BDatePicker({
    Key key,
    String id,
    double width,
    double height,
    this.onDatePickerDefaultPropUpdate,
    this.onDatePickerExtraPropUpdate,
    this.onDateTimeChanged,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.index,
  }) : super(
          key: key,
          id: id,
          width: width,
          height: height,
        );

  DateTime initialDate, firstDate, lastDate;
  final Function onDatePickerDefaultPropUpdate;
  final Function onDatePickerExtraPropUpdate;
  final Function onDateTimeChanged;
  int index;

  @override
  BState<BStatefulWidget> createState() => _BDatePickerState();
}

class _BDatePickerState extends BState<BDatePicker> {
  @override
  void initState() {
    super.initState();
    widget.initialDate = widget.initialDate ?? DateTime.now();
    widget.firstDate = widget.firstDate ?? DateTime(1950);
    widget.lastDate = widget.lastDate ?? DateTime.now().add(const Duration(days: (365 * 5)));
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
        onTap: () {
          showDatePicker(
            context: context,
            initialDate: widget.initialDate,
            firstDate: widget.firstDate,
            lastDate: widget.lastDate,
          ).then((DateTime value) {
            PropertyUtils().updateProperties(widget);
            if (value != null) {
              widget.onDateTimeChanged(value);
            }
          });
        },
        child: SizedBox(
          width: widget.width,
          height: widget.height,
        ),
      ),
    );
  }

  @override
  void updateValues() {
    if (widget.onDatePickerDefaultPropUpdate != null) {
      widget.onDatePickerDefaultPropUpdate(
        widget.width,
        widget.height,
      );
    }
    if (widget.onDatePickerExtraPropUpdate != null) {
      widget.onDatePickerExtraPropUpdate(
        widget.initialDate,
        widget.firstDate,
        widget.lastDate,
      );
    }
  }
}
