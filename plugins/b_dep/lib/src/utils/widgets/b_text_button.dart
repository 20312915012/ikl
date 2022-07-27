import 'package:b_dep/src/utils/b_stateful_widget.dart';
import 'package:b_dep/src/utils/property_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BTextButton extends BStatefulWidget {
  BTextButton({
    Key key,
    String id,
    Widget child,
    this.onClick,
    this.radius,
  }) : super(
          key: key,
          id: id,
          child: child,
        );

  final Function onClick;
  BorderRadius radius;

  @override
  BState<BStatefulWidget> createState() => _BTextButtonState();
}

class _BTextButtonState extends BState<BTextButton> {
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
    return ClipRRect(
        clipBehavior: Clip.hardEdge,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(ScreenUtil().setHeight(widget.radius.topLeft.y)),
          topRight: Radius.circular(ScreenUtil().setHeight(widget.radius.topRight.y)),
          bottomLeft: Radius.circular(ScreenUtil().setHeight(widget.radius.bottomLeft.y)),
          bottomRight: Radius.circular(ScreenUtil().setHeight(widget.radius.bottomRight.y)),
        ),
        child: Material(
            color: Colors.transparent,
            child: InkWell(
                onTap: () {
                  PropertyUtils().updateProperties(widget);
                  if (widget.onClick != null) {
                    widget.onClick();
                  }
                },
                child: SizedBox(
                  height: double.maxFinite,
                  width: double.maxFinite,
                  child: Center(child: widget.child),
                ))));
  }

  @override
  void updateValues() {}
}
