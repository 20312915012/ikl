import 'dart:io' as io;
import 'dart:typed_data';
import 'dart:ui';

import 'package:b_dep/b_dep.dart';
import 'package:b_dep/src/utils/variables.dart' as variables;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class BContainer extends BStatefulWidget {
  BContainer({
    Key key,
    String id,
    Widget child,
    double width,
    double height,
    double paddingLeft,
    double paddingRight,
    double paddingTop,
    double paddingBottom,
    bool isHide = false,
    this.margin,
    this.innerShadow,
    this.alignment,
    this.decoration,
    this.filePath,
    this.fileBytes,
    this.imageFill,
    this.imageFit,
    this.onClick,
    this.onTap0,
    this.onPropertiesUpdate,
    this.onRectExtraPropUpdate,
    this.onRectDefaultPropUpdate,
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

  EdgeInsets margin;
  final BoxShadow innerShadow;
  final Alignment alignment;
  final BoxDecoration decoration;
  Color imageFill;

  dynamic filePath;
  Uint8List fileBytes;
  final Function onClick;
  final Function onTap0;
  final Function onPropertiesUpdate;
  final Function onRectExtraPropUpdate, onRectDefaultPropUpdate;
  String imageFit;
  dynamic extraData;
  int index;

  @override
  BState<BStatefulWidget> createState() => _BContainerState();
}

class _BContainerState extends BState<BContainer> {
  SvgPicture svgPictureWidget;
  BAudioPlayer audioPlayerWidget;
  BVideoPlayer videoPlayerWidget;
  bool isUpdate = false;

  @override
  void initState() {
    super.initState();
    /*getApplicationDocumentsDirectory().then((value){
        setState(() {
          applicationDirectoryPath=value.absolute.path;
        });
      });*/
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
    BoxDecoration decoration;
    checkIsUpdate();
    if (isUpdate && widget.child == null) {
      isUpdate = false;
      PropertyUtils().updateProperties(widget);
    }
    if (widget.isHide) {
      return const SizedBox();
    }
    if (widget.filePath != null || widget.fileBytes != null) {
      DecorationImage image;
      //print("imagePath>> "+widget.filePath.toString());
      if (widget.fileBytes != null) {
        image = DecorationImage(image: MemoryImage(widget.fileBytes.buffer.asUint8List()), fit: getImageFit());
      } else if (widget.filePath is! String) {
        image = DecorationImage(image: MemoryImage(widget.filePath.buffer.asUint8List()), fit: getImageFit());
      } else if (widget.filePath is String) {
        if (!widget.filePath.contains(".") ||
            awsS3contentTypeMap[widget.filePath.toLowerCase().split(".").last] == null) {
          //https://picsum.photos/id/0/5616/3744
          if (widget.filePath.contains("https://picsum.photos")) {
            widget.filePath = widget.filePath.substring(0, widget.filePath.lastIndexOf("/"));
            widget.filePath = widget.filePath.substring(0, widget.filePath.lastIndexOf("/"));
            widget.filePath += "/200";
          }

          image = DecorationImage(image: NetworkImage(widget.filePath), fit: getImageFit());
        } else if (/*widget.filePath.toLowerCase().contains(".jpg")||
            widget.filePath.toLowerCase().contains(".jpeg")||
            widget.filePath.toLowerCase().contains(".png")||
            widget.filePath.toLowerCase().contains(".bmp")||
            widget.filePath.toLowerCase().contains(".gif")*/
            awsS3contentTypeMap[widget.filePath.toLowerCase().split(".").last].contains("image") &&
                !awsS3contentTypeMap[widget.filePath.toLowerCase().split(".").last].contains("svg")) {
          if (widget.filePath.toLowerCase().contains("http://") || widget.filePath.toLowerCase().contains("https://")) {
            image = DecorationImage(image: NetworkImage(widget.filePath), fit: getImageFit());
          } else if (widget.filePath[0].toString() == "/" ||
              widget.filePath.toLowerCase().contains("storage/emulated")) {
            //if(applicationDirectoryPath!=null){
            image = DecorationImage(image: FileImage(io.File(widget.filePath)), fit: getImageFit());
            //}
          }
          videoPlayerWidget = null;
          svgPictureWidget = null;
          audioPlayerWidget = null;
        } else if (widget.filePath.toLowerCase().contains(".svg")) {
          if (widget.filePath.toLowerCase().contains("http://") || widget.filePath.toLowerCase().contains("https://")) {
            svgPictureWidget = SvgPicture.network(
              widget.filePath,
              width: widget.width,
              height: widget.height,
              color: widget.imageFill,
              fit: getImageFit(),
            );
          } else if (widget.filePath[0].toString() == "/" ||
              widget.filePath.toLowerCase().contains("storage/emulated")) {
            svgPictureWidget = SvgPicture.file(
              io.File(widget.filePath),
              width: widget.width,
              height: widget.height,
              color: widget.imageFill,
              fit: getImageFit(),
            );
          } else if (widget.filePath.toLowerCase().contains("images/")) {
            svgPictureWidget = SvgPicture.asset(
              widget.filePath,
              width: widget.width,
              height: widget.height,
              color: widget.imageFill,
              fit: getImageFit(),
            );
          }
          image = null;
          videoPlayerWidget = null;
          audioPlayerWidget = null;
        } else if (awsS3contentTypeMap[widget.filePath.toLowerCase().split(".").last].contains("audio")) {
          audioPlayerWidget = BAudioPlayer(
            filePath: widget.filePath,
            width: widget.width,
            height: widget.height,
          );
          //print("audioPlayerWidget>>> "+audioPlayerWidget.toString());
          svgPictureWidget = null;
          videoPlayerWidget = null;
          image = null;
        } else if (awsS3contentTypeMap[widget.filePath.toLowerCase().split(".").last].contains("video")) {
          videoPlayerWidget = BVideoPlayer(
            filePath: widget.filePath,
            width: widget.width,
            height: widget.height,
          );
          audioPlayerWidget = null;
          svgPictureWidget = null;
          image = null;
        } else if (widget.filePath.toLowerCase().contains(".docx")) {
          image = DecorationImage(
              image: const NetworkImage(
                  "https://blup-files-1.s3.ap-south-1.amazonaws.com/internal-public-files/bcontainer_docx_dark_grey.png"),
              fit: getImageFit());
          svgPictureWidget = null;
          videoPlayerWidget = null;
          audioPlayerWidget = null;
        }
      }
      decoration = BoxDecoration(
          color: widget.decoration.color,
          border: widget.decoration.border,
          borderRadius: widget.decoration.borderRadius,
          boxShadow: widget.decoration.boxShadow,
          gradient: widget.decoration.gradient,
          image: image);
    } else if (widget.filePath == null && widget.decoration != null && widget.decoration.image != null) {
      if (widget.imageFit != null && widget.decoration.image.image is AssetImage) {
        var image = DecorationImage(
            image: AssetImage((widget.decoration.image.image as AssetImage).assetName), fit: getImageFit());
        decoration = BoxDecoration(
          image: image,
          color: widget.decoration.color,
          border: widget.decoration.border,
          borderRadius: widget.decoration.borderRadius,
          boxShadow: widget.decoration.boxShadow,
          gradient: widget.decoration.gradient,
        );
      } else {
        decoration = widget.decoration;
      }
    } else if (widget.decoration != null) {
      //decoration=widget.decoration;
      decoration = BoxDecoration(
        color: widget.decoration.color,
        border: widget.decoration.border,
        borderRadius: widget.decoration.borderRadius,
        boxShadow: widget.decoration.boxShadow,
        gradient: widget.decoration.gradient,
      );
    }
    return Padding(
        padding: EdgeInsets.only(
          left: widget.paddingLeft ?? 0,
          right: widget.paddingRight ?? 0,
          top: widget.paddingTop ?? 0,
          bottom: widget.paddingBottom ?? 0,
        ),
        child: getChildWidget(decoration));
  }

  Widget getChildWidget(BoxDecoration decoration) {
    if (widget.onClick == null && widget.onTap0 == null) {
      // print("audioPlayerWidget0> "+audioPlayerWidget.toString());
      return widget.innerShadow == null
          ? getContainerWidget(decoration)
          : (decoration == null
              ? InnerShadow(
                  shadow: widget.innerShadow,
                  child: getContainerWidget(decoration),
                )
              : getDecoratedInnerShadow(decoration)
      );
    } else {
      // var radius = (widget.decoration.borderRadius as BorderRadius)?.topRight?.y;
      return Container(
        width: widget.width,
        height: widget.height,
        //decoration: decoration,
        child: Stack(
          children: [
            widget.innerShadow == null
                ? Container(
                    decoration: decoration,
                  )
                : getDecoratedInnerShadow(decoration),
            ClipRRect(
              clipBehavior: Clip.hardEdge,
              borderRadius: widget.decoration.borderRadius,
              child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                      onTap: () {
                        PropertyUtils().updateProperties(widget);
                        if (widget.onTap0 != null) {
                          widget.onTap0();
                        }
                        if (widget.onClick != null) {
                          var str = PropertyUtils().getTextFromBTextChild(widget);
                          if (str != null && widget.index != null) {
                            widget.onClick(str, widget.index);
                          }
                          if (str != null) {
                            widget.onClick(str);
                          } else if (widget.index != null) {
                            widget.onClick(widget.index);
                          } else {
                            widget.onClick();
                          }
                        }
                      },
                      child: Container(
                        margin: widget.margin,
                        alignment: widget.alignment,
                        width: widget.width,
                        height: widget.height,
                        //decoration: decoration,
                        child: (svgPictureWidget ?? audioPlayerWidget ?? videoPlayerWidget ?? widget.child),
                      ))),
            ),
          ],
        ),
      );
    }
  }

  Widget getDecoratedInnerShadow(decoration){
    return DecoratedBox(
      decoration: decoration,
      child: ClipRRect(
        borderRadius: decoration.borderRadius,
        child: InnerShadow(
          shadow: widget.innerShadow,
          child: getContainerWidget(decoration),
        ),
      ),
    );
  }

  Widget getContainerWidget(BoxDecoration decoration) {
    return Container(
        alignment: widget.alignment,
        width: widget.width,
        height: widget.height,
        decoration: decoration,
        child: svgPictureWidget ?? audioPlayerWidget ?? videoPlayerWidget ?? widget.child);
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

  bool mIsHide;
  dynamic mFilePath;

  void checkIsUpdate() {
    if (mIsHide == null || mIsHide != widget.isHide) {
      mIsHide = widget.isHide;
      isUpdate = true;
    }
    if (mFilePath == null || mFilePath != widget.filePath) {
      mFilePath = widget.filePath;
      isUpdate = true;
    }
  }

  BoxFit getImageFit() {
    if (widget.imageFit != null) {
      for (BoxFit val in BoxFit.values) {
        if (val.toString().contains(widget.imageFit)) {
          return val;
        }
      }
    }
    return BoxFit.cover;
  }

  @override
  void updateValues() {
    if (widget.onRectDefaultPropUpdate != null) {
      widget.onRectDefaultPropUpdate(
        widget.width,
        widget.height,
        widget.isHide,
        widget.filePath,
        widget.fileBytes,
        widget.extraData,
      );
    }
    if (widget.onRectExtraPropUpdate != null) {
      widget.onRectExtraPropUpdate(
        widget.decoration.borderRadius,
        widget.decoration.color,
        widget.decoration.border.top.color,
        widget.decoration.border.top.width,
        widget.decoration.boxShadow.first.color,
        widget.decoration.boxShadow.first.offset.dx,
        widget.decoration.boxShadow.first.offset.dy,
        widget.decoration.boxShadow.first.blurRadius,
        widget.paddingLeft,
        widget.paddingRight,
        widget.paddingTop,
        widget.paddingBottom,
        widget.imageFill,
        widget.imageFit,
      );
    }
  }
}

class InnerShadow extends SingleChildRenderObjectWidget {
  const InnerShadow({
    Key key,
    this.shadow,
    Widget child,
  }) : super(key: key, child: child);

  final BoxShadow shadow;

  @override
  RenderInnerShadow createRenderObject(BuildContext context) {
    return RenderInnerShadow()
      ..color = shadow.color
      ..blur = shadow.blurRadius
      ..offset = shadow.offset;
  }

  @override
  void updateRenderObject(BuildContext context, RenderInnerShadow renderObject) {
    renderObject
      ..color = shadow.color
      ..blur = shadow.blurRadius
      ..offset = shadow.offset;
  }
}

class RenderInnerShadow extends RenderProxyBox {
  RenderInnerShadow({
    RenderBox child,
  }) : super(child);

  @override
  bool get alwaysNeedsCompositing => child != null;

  Color _color;
  double _blur;
  Offset _offset;

  Color get color => _color;

  set color(Color value) {
    if (_color == value) return;
    _color = value;
    markNeedsPaint();
  }

  double get blur => _blur;

  set blur(double value) {
    if (_blur == value) return;
    _blur = value;
    markNeedsPaint();
  }

  Offset get offset1 => _offset;

  set offset(Offset value) {
    if (_offset == value) return;
    _offset = value;
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;

    final Rect rectOuter = offset & size;
    final Rect rectInner = Rect.fromLTWH(
      offset.dx,
      offset.dy,
      size.width - offset1.dx,
      size.height - offset1.dy,
    );
    final Canvas canvas = context.canvas..saveLayer(rectOuter, Paint());
    context.paintChild(child, offset);
    final Paint shadowPaint = Paint()
      ..blendMode = BlendMode.srcATop
      ..imageFilter = ImageFilter.blur(sigmaX: blur, sigmaY: blur)
      ..colorFilter = ColorFilter.mode(color, BlendMode.srcOut);

    canvas
      ..saveLayer(rectOuter, shadowPaint)
      ..translate(_offset.dx, _offset.dy)
      ..saveLayer(rectInner, Paint());
    context.paintChild(child, offset);
    context.canvas
      ..restore()
      ..restore()
      ..restore();
  }
}