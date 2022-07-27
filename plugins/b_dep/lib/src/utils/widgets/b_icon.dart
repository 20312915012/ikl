import 'package:flutter/material.dart';

import 'package:b_dep/src/utils/b_stateful_widget.dart';
import 'package:b_dep/src/utils/property_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:b_dep/src/utils/variables.dart' as variables;

class BIcon extends BStatefulWidget {
  BIcon(
    this.iconData, {
    Key key,
    String id,
    this.size,
    this.color,
    this.onIconDefaultPropUpdate,
    this.onIconExtraPropUpdate,
    this.index,
  }) : super(
          key: key,
          id: id,
        );

  IconData iconData;
  Color color;
  double size;
  int index;

  final Function onIconDefaultPropUpdate;
  final Function onIconExtraPropUpdate;

  @override
  BState<BStatefulWidget> createState() => _BIconState();
}

class _BIconState extends BState<BIcon> {
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
    scrUtilConversion();
    PropertyUtils().updateProperties(widget);
    return Center(
      child: Icon(
        widget.iconData,
        size: widget.size,
        color: widget.color,
      ),
    );
  }

  void scrUtilConversion() {
    ///BlupVersion check to make sure older Blup Versions are safe.
    if (variables.blupVersion.toString() != "null") {
      widget.size = widget.size == null ? null : ScreenUtil().setWidth(widget.size);
    }
  }

  @override
  void updateValues() {
    if (widget.onIconExtraPropUpdate != null) {
      widget.onIconExtraPropUpdate(
        widget.iconData,
        widget.size,
        widget.color,
      );
    }
  }
}
