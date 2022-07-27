import 'package:b_dep/b_dep.dart';
import 'package:b_dep/src/utils/variables.dart' as variables;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BStack extends BStatefulWidget {
  BStack({
    Key key,
    String id,
    double width,
    double height,
    double paddingLeft,
    double paddingRight,
    double paddingTop,
    double paddingBottom,
    bool isHide = false,
    this.children,
    this.onPropertiesUpdate,
    this.onGroupDefaultPropUpdate,
    this.onGroupExtraPropUpdate,
    this.enumStackCompTypeValueStr,
    this.extraData,
    this.onClick,
    this.index,
  }) : super(
    key: key,
    id: id,
    width: width,
    height: height,
    paddingLeft: paddingLeft,
    paddingRight: paddingRight,
    paddingTop: paddingTop,
    paddingBottom: paddingBottom,
    isHide: isHide,
  );

  List<Widget> children = [];
  dynamic extraData;

  final Function onPropertiesUpdate;
  final Function onGroupDefaultPropUpdate;
  final Function onGroupExtraPropUpdate;

  String enumStackCompTypeValueStr;
  Function onClick;
  int index;

  @override
  BState<BStatefulWidget> createState() => _BStackState();
}

class _BStackState extends BState<BStack> {
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
    if (widget.isHide) {
      return const SizedBox();
    } else {
      return SizedBox(
        width: widget.enumStackCompTypeValueStr == enumStackCompType.Row.toString() ? null : widget.width,
        height: widget.enumStackCompTypeValueStr == enumStackCompType.Column.toString() ? null : widget.height,
        child: Padding(
          padding: EdgeInsets.only(
            left: widget.paddingLeft ?? 0,
            right: widget.paddingRight ?? 0,
            top: widget.paddingTop ?? 0,
            bottom: widget.paddingBottom ?? 0,
          ),
          child: MouseRegion(
            cursor: widget.onClick != null ? SystemMouseCursors.click : MouseCursor.defer,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onClick != null
                  ? () {
                PropertyUtils().updateProperties(widget);
                if (widget.index != null) {
                  widget.onClick(widget.index);
                } else {
                  widget.onClick();
                }
              }
                  : null,
              child: SizedBox(
                  width: widget.enumStackCompTypeValueStr == enumStackCompType.Row.toString() ? null : widget.width,
                  height: widget.enumStackCompTypeValueStr == enumStackCompType.Column.toString() ? null : widget
                      .height,
                  child: getMainWidget()),
            ),),
        ),
      );
    }
  }

  void scrUtilConversion() {
    ///BlupVersion check to make sure older Blup Versions are safe.
    if (variables.blupVersion.toString() != "null") {
      if (widget.width != widget.height) {
        widget.width = widget.width == null ? null : ScreenUtil().setWidth(widget.width);
        widget.height = widget.height == null ? null : ScreenUtil().setHeight(widget.height);
      } else {
        widget.width = widget.width == null ? null : ScreenUtil().setWidth(widget.width);
        widget.height = widget.height == null ? null : ScreenUtil().setWidth(widget.height);
      }
    }
  }

  Widget getMainWidget() {
    if (widget.enumStackCompTypeValueStr != null) {
      for (enumStackCompType val in enumStackCompType.values) {
        if (val.toString().contains(widget.enumStackCompTypeValueStr)) {
          switch (val) {
            case enumStackCompType.Stack:
              return Stack(
                children: widget.children ?? [],
              );
              break;
            case enumStackCompType.Column:
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.children ?? [],
              );
              break;
            case enumStackCompType.Row:
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: widget.children ?? [],
              );
              break;
          }
        }
      }
    }
    return Stack(
      children: widget.children ?? [],
    );
  }

  @override
  void updateValues() {
    if (widget.onGroupDefaultPropUpdate != null) {
      widget.onGroupDefaultPropUpdate(
        widget.width,
        widget.height,
        widget.isHide,
        widget.extraData,
      );
    }
    if (widget.onGroupExtraPropUpdate != null) {
      widget.onGroupExtraPropUpdate(
        widget.paddingLeft,
        widget.paddingRight,
        widget.paddingTop,
        widget.paddingBottom,
      );
    }
  }
}
