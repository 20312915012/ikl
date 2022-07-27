import 'package:b_dep/b_dep.dart';
import 'package:b_dep/src/frideos_flutter/frideos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:b_dep/src/utils/variables.dart' as variables;

class BSingleChildScrollView extends BStatefulWidget {
  BSingleChildScrollView({
    Key key,
    String id,
    this.scrollDirection,
    Widget child,
    this.childrenSingleScroll = true,
    double width,
    double height,
    this.innerWidth,
    this.innerHeight,
    double paddingLeft,
    double paddingRight,
    double paddingTop,
    double paddingBottom,
    bool isHide = false,
    this.onPropertiesUpdate,
    this.onScrollDefaultPropUpdate,
    this.onScrollExtraPropUpdate,
    this.extraData,
    this.index,
  }) : super(
          key: key,
          id: id,
          child: child,
          width: width,
          height: height,
          paddingLeft: paddingLeft,
          paddingRight: paddingRight,
          paddingTop: paddingTop,
          paddingBottom: paddingBottom,
          isHide: isHide,
        );

  final Axis scrollDirection;
  // final Widget child;
  bool childrenSingleScroll = true;
  // bool isHide;
  dynamic extraData;

  // double width;
  // double height;
  final double innerWidth;
  final double innerHeight;
  // double paddingLeft, paddingRight, paddingTop, paddingBottom;

  final Function onPropertiesUpdate;
  final Function onScrollDefaultPropUpdate;
  final Function onScrollExtraPropUpdate;
  int index;

  @override
  BState<BStatefulWidget> createState() => _BSingleChildScrollViewState();
}

class _BSingleChildScrollViewState extends BState<BSingleChildScrollView> {
  BuildContext inheritedDataProviderContext;
  ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.childrenSingleScroll = widget.childrenSingleScroll ?? true;
    if (widget.childrenSingleScroll) {
      setInitScrollListener();
    }
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
    var a = {
      "x": "0",
      "isScrollViewAtEnd": (widget.childrenSingleScroll) ? "false" : "null",
      "scrollViewAxis": widget.scrollDirection.toString()
    };
    StreamedValue<Map<String, String>> data1 = StreamedValue<Map<String, String>>();
    data1.value = a;
    PropertyUtils().updateProperties(widget);
    if (widget.isHide) {
      return const SizedBox();
    }

    return Padding(
      padding: EdgeInsets.only(
        left: widget.paddingLeft ?? 0,
        right: widget.paddingRight ?? 0,
        top: widget.paddingTop ?? 0,
        bottom: widget.paddingBottom ?? 0,
      ),
      child: InheritedScrollDataProvider<Map<String, String>>(
          data: data1,
          child: StreamedWidget(
              stream: data1.outStream,
              builder: (contextA, snapshot) {
                this.inheritedDataProviderContext = contextA;
                rebuildAllChildren(contextA);
                return Theme(
                  data: ThemeData(accentColor: Colors.white12),
                  child: SingleChildScrollView(
                    scrollDirection: widget.scrollDirection,
                    controller: controller,
                    child: widget.child,
                  ),
                );
              })),
    );
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

  void rebuildAllChildren(BuildContext context) {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }

  void setInitScrollListener() {
    controller.addListener(() {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        InheritedScrollDataProvider.of<Map<String, String>>(inheritedDataProviderContext).value["isScrollViewAtEnd"] =
            "true";
        InheritedScrollDataProvider.of<Map<String, String>>(inheritedDataProviderContext).value["scrollViewAxis"] =
            widget.scrollDirection.toString();
        InheritedScrollDataProvider.of<Map<String, String>>(inheritedDataProviderContext).refresh();
      } else {
        InheritedScrollDataProvider.of<Map<String, String>>(inheritedDataProviderContext).value["isScrollViewAtEnd"] =
            "false";
        InheritedScrollDataProvider.of<Map<String, String>>(inheritedDataProviderContext).value["scrollViewAxis"] =
            widget.scrollDirection.toString();
        InheritedScrollDataProvider.of<Map<String, String>>(inheritedDataProviderContext).refresh();
      }
    });
  }

  @override
  void updateValues() {
    if (widget.onScrollDefaultPropUpdate != null) {
      widget.onScrollDefaultPropUpdate(
        widget.width,
        widget.height,
        widget.isHide,
        widget.extraData,
      );
    }
    if (widget.onScrollExtraPropUpdate != null) {
      widget.onScrollExtraPropUpdate(
        widget.innerWidth,
        widget.innerHeight,
        widget.paddingLeft,
        widget.paddingRight,
        widget.paddingTop,
        widget.paddingBottom,
        widget.childrenSingleScroll,
      );
    }
  }
}
